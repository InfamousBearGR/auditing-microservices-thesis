// ============================================================================
// Audit-method benchmark — load generator (k6).
//
// Drives a fixed, reproducible CRUD workload against business-registry-api,
// identical across all 4 scenarios (baseline / cdc / triggers / envers), so the
// per-method write-path overhead and audit volume are comparable. Mirrors the
// entity/op mix and synthetic-data rules of the client stress-test
// (business-registry/client/src/shared/hooks/useStressTest.tsx).
//
// Env knobs (all optional):
//   BASE_URL    default http://business-registry-api:8084
//   USERNAME    default admin
//   PASSWORD    default testPassword
//   VUS         default 10        (concurrent virtual users)
//   TOTAL_OPS   default 2000      (total mutations across all VUs — the fixed workload)
//   RESULT_FILE default summary.json (handleSummary target, written by k6 in-container)
//
// Run (from the compose network):
//   docker run --rm --network <net> -e BASE_URL=... -v "$PWD/benchmark":/b \
//     grafana/k6 run /b/load.js
// ============================================================================

import http from 'k6/http';
import { check } from 'k6';
import { Trend, Counter } from 'k6/metrics';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.1.0/index.js';

const BASE = __ENV.BASE_URL || 'http://business-registry-api:8084';
const USERNAME = __ENV.USERNAME || 'admin';          // used by setup() to fetch reference data
const PASSWORD = __ENV.PASSWORD || 'testPassword';
// Each VU logs in as its own user (bench<__VU>) — the app enforces one session
// per user, so VUs must NOT share a login. Users bench1..bench64 are seeded in
// mainDb/init.sql. Self-login lets k6's per-VU cookie jar manage the session.
const VU_USER_PREFIX = __ENV.VU_USER_PREFIX || 'bench';
const VU_PASSWORD = __ENV.VU_PASSWORD || 'testPassword';
const VUS = parseInt(__ENV.VUS || '10');
const TOTAL_OPS = parseInt(__ENV.TOTAL_OPS || '2000');
const RESULT_FILE = __ENV.RESULT_FILE || 'summary.json';

export const options = {
    summaryTrendStats: ['avg', 'min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
    scenarios: {
        workload: {
            executor: 'shared-iterations',
            vus: VUS,
            iterations: TOTAL_OPS,
            maxDuration: '30m',
        },
    },
};

// Per-op latency trends + success/error counters.
const latCreate = new Trend('op_create_ms', true);
const latUpdate = new Trend('op_update_ms', true);
const latDelete = new Trend('op_delete_ms', true);
const okCounter = new Counter('mutations_ok');
const errCounter = new Counter('mutations_err');

// ── synthetic-data helpers (ported from useStressTest.tsx) ──────────────────
const ri = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const pick = (arr) => arr[ri(0, arr.length - 1)];
const rStr = (p) => `${p}_${Math.random().toString(36).substring(2, 7)}`;
const rAfm = () => {
    const d = Array.from({ length: 8 }, () => ri(0, 9));
    let sum = 0;
    for (let i = 0; i < 8; i++) sum += d[i] * (1 << (8 - i));
    return [...d, (sum % 11) % 10].join('');
};
const rRegNum = () => String(100000000000 + Math.floor(Math.random() * 900000000000));
const rPhone = () => `69${String(ri(10000000, 99999999))}`;
const rPostal = () => String(ri(10000, 99999));
const pad = (n) => String(n).padStart(2, '0');
const rDate = (y1, y2) => {
    const y = ri(y1, y2), m = ri(1, 12), day = ri(1, 28);
    return `${y}-${pad(m)}-${pad(day)}`;
};
const rFutureDate = () => rDate(2026, 2031);

function jsonPost(path, body) { return http.post(`${BASE}${path}`, JSON.stringify(body), { headers: { 'Content-Type': 'application/json' } }); }
function jsonPut(path, body) { return http.put(`${BASE}${path}`, JSON.stringify(body), { headers: { 'Content-Type': 'application/json' } }); }
function jsonDel(path, body) { return http.del(`${BASE}${path}`, JSON.stringify(body), { headers: { 'Content-Type': 'application/json' } }); }

// ── setup: log in as admin, build the parametric reference cache + seed ids ──
export function setup() {
    const res = jsonPost('/api/auth/login', { username: USERNAME, password: PASSWORD });
    if (res.status !== 200) throw new Error(`login failed (${res.status}) for ${USERNAME} @ ${BASE}`);

    const g = (p) => { const r = http.get(`${BASE}${p}`); return r.status === 200 ? r.json() : []; };
    const countries = g('/api/country/translations');
    const regions = g('/api/region/translations');
    const legalTypes = g('/api/legalType/translations');
    const companyStatuses = g('/api/companyStatus/translations');
    const currencies = g('/api/currency/translations');
    const stockTypes = g('/api/stockType/translations');
    const memberRelations = g('/api/memberRelation/translations');

    const geoOptions = [];
    for (const reg of regions.slice(0, 4)) {
        const prefs = g(`/api/prefecture/translations/${reg.id}`);
        for (const pref of prefs.slice(0, 3)) {
            const muns = g(`/api/municipality/translations/${pref.id}`);
            for (const mun of muns.slice(0, 3)) {
                geoOptions.push({ regionId: reg.id, prefectureId: pref.id, municipalityId: mun.id });
            }
        }
    }

    const ids = (p) => g(p).map((x) => x.id);
    return {
        cache: { countries, legalTypes, companyStatuses, currencies, stockTypes, memberRelations, geoOptions },
        seeds: {
            companies: ids('/api/company/index'),
            persons: ids('/api/person/index'),
            legalEntities: ids('/api/legalEntity/index'),
        },
    };
}

// ── per-VU state (module scope is per-VU in k6) ─────────────────────────────
let initialised = false;
let companyIds = null, personIds = null, leIds = null;

function record(op, res) {
    const ms = res.timings.duration;
    if (op === 'create') latCreate.add(ms);
    else if (op === 'update') latUpdate.add(ms);
    else if (op === 'delete') latDelete.add(ms);
    const ok = res.status >= 200 && res.status < 300;
    if (ok) okCounter.add(1); else errCounter.add(1);
    check(res, { 'mutation 2xx': () => ok });
}

export default function (data) {
    if (!initialised) {
        initialised = true;
        companyIds = data.seeds.companies.slice();
        personIds = data.seeds.persons.slice();
        leIds = data.seeds.legalEntities.slice();
    }
    // Re-login every iteration: the app's SessionAuthenticationFilter +
    // maximumSessions(1) expires the session after its first authenticated
    // state-change, so one login per mutation is required. Each VU uses its own
    // user (bench<__VU>) to avoid evicting other VUs. Login cost is uniform across
    // all scenarios and excluded from the op_* latency trends, so it does not
    // distort the per-method comparison.
    check(jsonPost('/api/auth/login', { username: `${VU_USER_PREFIX}${__VU}`, password: VU_PASSWORD }),
        { 'vu login 200': (r) => r.status === 200 });

    const c = data.cache;
    if (!c.geoOptions.length) return;
    const geo = pick(c.geoOptions);
    const country = pick(c.countries);
    const changeReason = `benchmark @ vu${__VU} it${__ITER}`;

    const entity = pick(['company', 'company', 'company', 'person', 'person', 'person',
        'legalEntity', 'legalEntity', 'legalEntity', 'member', 'member', 'capital', 'capital']);
    const op = pick(['create', 'create', 'create', 'create', 'create', 'create',
        'update', 'update', 'update', 'delete', 'delete']);

    if (entity === 'company') {
        if (op === 'create') {
            const res = jsonPost('/api/company/create', {
                name: rStr('Company'), city: rStr('City'), street: rStr('Street'),
                streetNumber: String(ri(1, 999)), postalCode: rPostal(), afm: rAfm(),
                legalTypeId: pick(c.legalTypes).id, dateIncorporated: rDate(1980, 2024),
                registryNumber: rRegNum(), companyStatusId: pick(c.companyStatuses).id,
                regionId: geo.regionId, prefectureId: geo.prefectureId,
                municipalityId: geo.municipalityId, countryId: country.id, changeReason,
            });
            record('create', res); // create returns ResponseEntity<Void> — no body/id to read
        } else if (op === 'update' && companyIds.length) {
            const id = pick(companyIds);
            record('update', jsonPut(`/api/company/update/${id}`, {
                name: rStr('CompanyUpd'), city: rStr('City'), street: rStr('Street'),
                streetNumber: String(ri(1, 999)), postalCode: rPostal(), afm: rAfm(),
                legalTypeId: pick(c.legalTypes).id, dateIncorporated: rDate(1980, 2024),
                registryNumber: rRegNum(), companyStatusId: pick(c.companyStatuses).id,
                regionId: geo.regionId, prefectureId: geo.prefectureId,
                municipalityId: geo.municipalityId, countryId: country.id, changeReason,
            }));
        } else if (op === 'delete' && companyIds.length) {
            const id = pick(companyIds);
            record('delete', jsonDel(`/api/company/delete/${id}`, { changeReason }));
            companyIds = companyIds.filter((i) => i !== id);
        }
    } else if (entity === 'person') {
        if (op === 'create') {
            const res = jsonPost('/api/person/create', {
                name: rStr('Name'), surname: rStr('Surname'), afm: rAfm(), city: rStr('City'),
                street: rStr('Street'), streetNumber: String(ri(1, 999)), postalCode: rPostal(),
                birthDate: rDate(1950, 2000), birthPlace: rStr('Place'), identityNumber: rStr('ID'),
                phoneNumber: rPhone(), regionId: geo.regionId, prefectureId: geo.prefectureId,
                municipalityId: geo.municipalityId, countryId: country.id, changeReason,
            });
            record('create', res);
        } else if (op === 'update' && personIds.length) {
            const id = pick(personIds);
            record('update', jsonPut(`/api/person/update/${id}`, {
                name: rStr('NameUpd'), surname: rStr('SurnameUpd'), afm: rAfm(), city: rStr('City'),
                street: rStr('Street'), streetNumber: String(ri(1, 999)), postalCode: rPostal(),
                birthDate: rDate(1950, 2000), birthPlace: rStr('Place'), identityNumber: rStr('ID'),
                phoneNumber: rPhone(), regionId: geo.regionId, prefectureId: geo.prefectureId,
                municipalityId: geo.municipalityId, countryId: country.id, changeReason,
            }));
        } else if (op === 'delete' && personIds.length) {
            const id = pick(personIds);
            record('delete', jsonDel(`/api/person/delete/${id}`, { changeReason }));
            personIds = personIds.filter((i) => i !== id);
        }
    } else if (entity === 'legalEntity') {
        if (op === 'create') {
            const res = jsonPost('/api/legalEntity/create', {
                registryNumber: rStr('LER'), businessName: rStr('Business'), phoneNumber: rPhone(),
                afm: rAfm(), city: rStr('City'), street: rStr('Street'), streetNumber: String(ri(1, 999)),
                postalCode: rPostal(), regionId: geo.regionId, prefectureId: geo.prefectureId,
                municipalityId: geo.municipalityId, countryId: country.id, changeReason,
            });
            record('create', res);
        } else if (op === 'update' && leIds.length) {
            const id = pick(leIds);
            record('update', jsonPut(`/api/legalEntity/update/${id}`, {
                registryNumber: rStr('LER'), businessName: rStr('BusinessUpd'), phoneNumber: rPhone(),
                afm: rAfm(), city: rStr('City'), street: rStr('Street'), streetNumber: String(ri(1, 999)),
                postalCode: rPostal(), regionId: geo.regionId, prefectureId: geo.prefectureId,
                municipalityId: geo.municipalityId, countryId: country.id, changeReason,
            }));
        } else if (op === 'delete' && leIds.length) {
            const id = pick(leIds);
            record('delete', jsonDel(`/api/legalEntity/delete/${id}`, { changeReason }));
            leIds = leIds.filter((i) => i !== id);
        }
    } else if (entity === 'member' && companyIds.length && personIds.length) {
        const res = jsonPost('/api/member/create', {
            active: Math.random() > 0.2, dateFrom: rDate(2000, 2024), dateTo: rFutureDate(),
            percentageOfOwnership: String(ri(1, 100)), personId: pick(personIds), legalEntityId: null,
            companyId: pick(companyIds), representativeOfMemberId: null,
            representedIndividual: true, representedTogether: false,
            memberRelationId: pick(c.memberRelations).id, changeReason,
        });
        record('create', res);
    } else if (entity === 'capital' && companyIds.length) {
        const companyId = pick(companyIds);
        const stocks = Array.from({ length: ri(1, 3) }, () => ({
            companyId, stockTypeId: pick(c.stockTypes).id, amount: ri(100, 50000),
            nominalPrice: String(ri(1, 500)), toBeDeleted: false,
        }));
        const totalAmount = stocks.reduce((s, x) => s + parseInt(x.nominalPrice) * x.amount, 0);
        record('update', jsonPut('/api/capital/update', {
            companyId, totalAmount: String(totalAmount), currencyId: pick(c.currencies).id,
            changeReason, stocks,
        }));
    }
}

export function handleSummary(data) {
    return {
        [RESULT_FILE]: JSON.stringify(data, null, 2),
        stdout: textSummary(data, { indent: ' ', enableColors: false }),
    };
}
