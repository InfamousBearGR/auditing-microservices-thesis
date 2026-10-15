// ============================================================================
// Audit-method benchmark — load generator (k6).
//
// Drives a fixed, reproducible CRUD workload against business-registry-api,
// identical across all scenarios (baseline / cdc / triggers / envers / ...), so
// the per-method write-path overhead and audit volume are comparable. Mirrors the
// entity/op mix and synthetic-data rules of the client stress-test
// (business-registry/client/src/shared/hooks/useStressTest.tsx).
//
// Every iteration performs EXACTLY ONE mutation attempt:
//   entity  company / person / legalEntity (weight 3 each), member / capital (2 each)
//   op      create 6 : update 3 : delete 2   (member = create, capital = update)
//   An update/delete with no id left to act on falls back to a create, so the
//   number of mutation attempts never depends on how fast a VU's ids run out.
//
// Authentication: each VU logs in ONCE as its own user bench<__VU> and keeps the
// session; it re-logs in (and retries the mutation once) only if the API rejects
// the session (401/403, or a 200 "session has been expired" page from Spring
// Security's concurrent-session control). Logins are counted (vu_logins,
// vu_relogins) and timed (login_ms) separately from the op_* latency trends.
// LOGIN_EVERY_ITERATION=1 restores the old behaviour (one login per mutation).
// The bench users carry a cheap Argon2id hash (see mainDb/init.sql), so even
// with per-iteration logins password hashing no longer dominates the host CPU.
//
// Ids: with PARTITION_IDS=1 (default) each VU updates/deletes only its own,
// disjoint share of the seeded ids (index % VUS), so VUs never race to update a
// row another VU already deleted; failed mutations are then genuine validation /
// constraint failures, not artefacts of the load generator.
//
// Env knobs (all optional):
//   BASE_URL              default http://business-registry-api:8084
//   USERNAME / PASSWORD   default admin / testPassword  (setup(): reference data)
//   VU_USER_PREFIX        default bench      VU_PASSWORD default testPassword
//   VUS                   default 10         concurrent VUs (≤ 64 bench users)
//   TOTAL_OPS             default 2000       total iterations = mutation attempts
//   RATE                  default 0          0 → closed model (shared-iterations,
//                                            VUS loop as fast as the API answers);
//                                            >0 → open model (constant-arrival-rate,
//                                            RATE iterations/s for TOTAL_OPS/RATE s)
//   SEED_IDS_FILE         default ""         JSON {companies,persons,legalEntities}
//                                            written by run-all.sh; else ids are
//                                            fetched from the API in setup()
//   PARTITION_IDS         default 1          1 = disjoint id share per VU
//   LOGIN_EVERY_ITERATION default 0          1 = legacy: log in before every mutation
//   RESULT_FILE           default summary.json (handleSummary target)
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
// mainDb/init.sql.
const VU_USER_PREFIX = __ENV.VU_USER_PREFIX || 'bench';
const VU_PASSWORD = __ENV.VU_PASSWORD || 'testPassword';
const VUS = parseInt(__ENV.VUS || '10');
const TOTAL_OPS = parseInt(__ENV.TOTAL_OPS || '2000');
const RATE = parseFloat(__ENV.RATE || '0');
const PARTITION_IDS = (__ENV.PARTITION_IDS || '1') === '1';
const LOGIN_EVERY_ITERATION = (__ENV.LOGIN_EVERY_ITERATION || '0') === '1';
const RESULT_FILE = __ENV.RESULT_FILE || 'summary.json';
const SEED_IDS_FILE = __ENV.SEED_IDS_FILE || '';

// open() is only allowed in the init context; k6 caches the file per test run.
const SEED_FROM_FILE = SEED_IDS_FILE ? JSON.parse(open(SEED_IDS_FILE)) : null;

const DURATION_S = RATE > 0 ? Math.max(1, Math.ceil(TOTAL_OPS / RATE)) : 0;

export const options = {
    summaryTrendStats: ['avg', 'min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
    scenarios: {
        workload: RATE > 0
            ? {
                executor: 'constant-arrival-rate',
                rate: RATE,
                timeUnit: '1s',
                duration: `${DURATION_S}s`,
                preAllocatedVUs: VUS,
                maxVUs: VUS,
            }
            : {
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
const latLogin = new Trend('login_ms', true);
const okCounter = new Counter('mutations_ok');
const errCounter = new Counter('mutations_err');
const err4xx = new Counter('mutations_err_4xx');
const err5xx = new Counter('mutations_err_5xx');
const attempts = new Counter('mutation_attempts');
const logins = new Counter('vu_logins');
const relogins = new Counter('vu_relogins');
const loginFailures = new Counter('vu_login_failures');
const fallbacks = new Counter('op_fallback_to_create');
// How the API rejected a session (diagnostics for vu_relogins).
const rejected403 = new Counter('session_rejected_403');
const rejected401 = new Counter('session_rejected_401');
const rejectedExpiredPage = new Counter('session_rejected_expired_page');

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
// A date 30 days – 5 years after TODAY (the API rejects a member "date to" in the past;
// a fixed year range starts failing as the calendar year advances).
const rFutureDate = () => new Date(Date.now() + ri(30, 1825) * 86400000).toISOString().slice(0, 10);

const JSON_HEADERS = { headers: { 'Content-Type': 'application/json' } };
function jsonPost(path, body) { return http.post(`${BASE}${path}`, JSON.stringify(body), JSON_HEADERS); }
function jsonPut(path, body) { return http.put(`${BASE}${path}`, JSON.stringify(body), JSON_HEADERS); }
function jsonDel(path, body) { return http.del(`${BASE}${path}`, JSON.stringify(body), JSON_HEADERS); }

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
    if (!geoOptions.length || !countries.length || !legalTypes.length || !companyStatuses.length) {
        throw new Error('reference data could not be loaded from the API — aborting (no mutations would be generated)');
    }

    let seeds;
    if (SEED_FROM_FILE) {
        seeds = {
            companies: SEED_FROM_FILE.companies || [],
            persons: SEED_FROM_FILE.persons || [],
            legalEntities: SEED_FROM_FILE.legalEntities || [],
            source: 'file',
        };
    } else {
        const ids = (p) => g(p).map((x) => x.id);
        seeds = {
            companies: ids('/api/company/index'),
            persons: ids('/api/person/index'),
            legalEntities: ids('/api/legalEntity/index'),
            source: 'api',
        };
    }
    console.log(`setup: ${seeds.companies.length} companies, ${seeds.persons.length} persons, ` +
        `${seeds.legalEntities.length} legal entities (ids from ${seeds.source}); ` +
        `executor=${RATE > 0 ? `constant-arrival-rate ${RATE}/s x ${DURATION_S}s` : 'shared-iterations'}, ` +
        `partition=${PARTITION_IDS}, loginEveryIteration=${LOGIN_EVERY_ITERATION}`);
    return {
        cache: { countries, legalTypes, companyStatuses, currencies, stockTypes, memberRelations, geoOptions },
        seeds,
    };
}

// ── per-VU state (module scope is per-VU in k6) ─────────────────────────────
let initialised = false;
let loggedIn = false;
let errorsLogged = 0;
let companyIds = null, personIds = null, leIds = null;

// VU k (1-based) owns the ids at positions i with i % VUS === (k-1) % VUS.
function share(ids) {
    if (!PARTITION_IDS) return ids.slice();
    const slot = (__VU - 1) % VUS;
    return ids.filter((_, i) => i % VUS === slot);
}

function login(clearCookies) {
    if (clearCookies) {
        // Drop the rejected session cookie so the login starts a fresh session.
        try { http.cookieJar().clear(BASE); } catch (e) { /* older k6: ignore */ }
    }
    const r = jsonPost('/api/auth/login', { username: `${VU_USER_PREFIX}${__VU}`, password: VU_PASSWORD });
    latLogin.add(r.timings.duration);
    logins.add(1);
    const ok = r.status === 200;
    check(r, { 'vu login 200': () => ok });
    if (!ok) {
        loginFailures.add(1);
        if (errorsLogged < 3) {
            errorsLogged++;
            console.warn(`VU ${__VU}: login failed with HTTP ${r.status}: ${String(r.body).substring(0, 200)}`);
        }
    }
    loggedIn = ok;
    return ok;
}

// Did the API reject the request because the session is gone? Spring Security
// answers 403 for an unauthenticated request (no entry point configured) and its
// ConcurrentSessionFilter writes a 200 text body for an expired session.
function sessionRejected(res) {
    if (res.status === 403) { rejected403.add(1); return true; }
    if (res.status === 401) { rejected401.add(1); return true; }
    if (res.status === 200 && typeof res.body === 'string' && res.body.indexOf('session has been expired') >= 0) {
        rejectedExpiredPage.add(1);
        return true;
    }
    return false;
}

function record(op, res) {
    const ms = res.timings.duration;
    if (op === 'create') latCreate.add(ms);
    else if (op === 'update') latUpdate.add(ms);
    else if (op === 'delete') latDelete.add(ms);
    const ok = res.status >= 200 && res.status < 300;
    if (ok) {
        okCounter.add(1);
    } else {
        errCounter.add(1);
        if (res.status >= 500 || res.status === 0) err5xx.add(1); else err4xx.add(1);
        if (errorsLogged < 3) {
            errorsLogged++;
            console.warn(`VU ${__VU}: ${op} failed with HTTP ${res.status}: ${String(res.body).substring(0, 200)}`);
        }
    }
    check(res, { 'mutation 2xx': () => ok });
    return ok;
}

// Send one mutation; on a rejected session log in again and retry ONCE. Only the
// final attempt is recorded, so op_* latencies never include a login.
function mutate(op, send) {
    attempts.add(1);
    if (!loggedIn && !login(true)) {
        errCounter.add(1);
        err4xx.add(1);
        return false;
    }
    let res = send();
    if (sessionRejected(res)) {
        relogins.add(1);
        if (!login(true)) {
            errCounter.add(1);
            err4xx.add(1);
            return false;
        }
        res = send();
    }
    return record(op, res);
}

const ENTITIES = ['company', 'company', 'company', 'person', 'person', 'person',
    'legalEntity', 'legalEntity', 'legalEntity', 'member', 'member', 'capital', 'capital'];
const OPS = ['create', 'create', 'create', 'create', 'create', 'create',
    'update', 'update', 'update', 'delete', 'delete'];

function companyBody(c, geo, country, changeReason, upd) {
    return {
        name: rStr(upd ? 'CompanyUpd' : 'Company'), city: rStr('City'), street: rStr('Street'),
        streetNumber: String(ri(1, 999)), postalCode: rPostal(), afm: rAfm(),
        legalTypeId: pick(c.legalTypes).id, dateIncorporated: rDate(1980, 2024),
        registryNumber: rRegNum(), companyStatusId: pick(c.companyStatuses).id,
        regionId: geo.regionId, prefectureId: geo.prefectureId,
        municipalityId: geo.municipalityId, countryId: country.id, changeReason,
    };
}

function personBody(geo, country, changeReason, upd) {
    return {
        name: rStr(upd ? 'NameUpd' : 'Name'), surname: rStr(upd ? 'SurnameUpd' : 'Surname'), afm: rAfm(),
        city: rStr('City'), street: rStr('Street'), streetNumber: String(ri(1, 999)), postalCode: rPostal(),
        birthDate: rDate(1950, 2000), birthPlace: rStr('Place'), identityNumber: rStr('ID'),
        phoneNumber: rPhone(), regionId: geo.regionId, prefectureId: geo.prefectureId,
        municipalityId: geo.municipalityId, countryId: country.id, changeReason,
    };
}

function legalEntityBody(geo, country, changeReason, upd) {
    return {
        registryNumber: rStr('LER'), businessName: rStr(upd ? 'BusinessUpd' : 'Business'), phoneNumber: rPhone(),
        afm: rAfm(), city: rStr('City'), street: rStr('Street'), streetNumber: String(ri(1, 999)),
        postalCode: rPostal(), regionId: geo.regionId, prefectureId: geo.prefectureId,
        municipalityId: geo.municipalityId, countryId: country.id, changeReason,
    };
}

export default function (data) {
    if (!initialised) {
        initialised = true;
        companyIds = share(data.seeds.companies);
        personIds = share(data.seeds.persons);
        leIds = share(data.seeds.legalEntities);
    }
    if (LOGIN_EVERY_ITERATION) {
        // Legacy behaviour: a fresh login before every mutation.
        login(false);
    }

    const c = data.cache;
    const geo = pick(c.geoOptions);
    const country = pick(c.countries);
    const changeReason = `benchmark @ vu${__VU} it${__ITER}`;

    let entity = pick(ENTITIES);
    let op = pick(OPS);

    // member / capital need a company (and a person) of this VU; otherwise create a company.
    if ((entity === 'member' && (!companyIds.length || !personIds.length)) ||
        (entity === 'capital' && !companyIds.length)) {
        fallbacks.add(1);
        entity = 'company';
        op = 'create';
    }
    const own = entity === 'company' ? companyIds : entity === 'person' ? personIds
        : entity === 'legalEntity' ? leIds : null;
    if (own && (op === 'update' || op === 'delete') && !own.length) {
        fallbacks.add(1);
        op = 'create';
    }

    if (entity === 'company') {
        if (op === 'create') {
            // create returns ResponseEntity<Void> — no body/id to read
            mutate('create', () => jsonPost('/api/company/create', companyBody(c, geo, country, changeReason, false)));
        } else if (op === 'update') {
            const id = pick(companyIds);
            mutate('update', () => jsonPut(`/api/company/update/${id}`, companyBody(c, geo, country, changeReason, true)));
        } else {
            const id = pick(companyIds);
            mutate('delete', () => jsonDel(`/api/company/delete/${id}`, { changeReason }));
            companyIds = companyIds.filter((i) => i !== id);
        }
    } else if (entity === 'person') {
        if (op === 'create') {
            mutate('create', () => jsonPost('/api/person/create', personBody(geo, country, changeReason, false)));
        } else if (op === 'update') {
            const id = pick(personIds);
            mutate('update', () => jsonPut(`/api/person/update/${id}`, personBody(geo, country, changeReason, true)));
        } else {
            const id = pick(personIds);
            mutate('delete', () => jsonDel(`/api/person/delete/${id}`, { changeReason }));
            personIds = personIds.filter((i) => i !== id);
        }
    } else if (entity === 'legalEntity') {
        if (op === 'create') {
            mutate('create', () => jsonPost('/api/legalEntity/create', legalEntityBody(geo, country, changeReason, false)));
        } else if (op === 'update') {
            const id = pick(leIds);
            mutate('update', () => jsonPut(`/api/legalEntity/update/${id}`, legalEntityBody(geo, country, changeReason, true)));
        } else {
            const id = pick(leIds);
            mutate('delete', () => jsonDel(`/api/legalEntity/delete/${id}`, { changeReason }));
            leIds = leIds.filter((i) => i !== id);
        }
    } else if (entity === 'member') {
        const body = {
            active: Math.random() > 0.2, dateFrom: rDate(2000, 2024), dateTo: rFutureDate(),
            percentageOfOwnership: String(ri(1, 100)), personId: pick(personIds), legalEntityId: null,
            companyId: pick(companyIds), representativeOfMemberId: null,
            representedIndividual: true, representedTogether: false,
            memberRelationId: pick(c.memberRelations).id, changeReason,
        };
        mutate('create', () => jsonPost('/api/member/create', body));
    } else { // capital
        const companyId = pick(companyIds);
        const stocks = Array.from({ length: ri(1, 3) }, () => ({
            companyId, stockTypeId: pick(c.stockTypes).id, amount: ri(100, 50000),
            nominalPrice: String(ri(1, 500)), toBeDeleted: false,
        }));
        const totalAmount = stocks.reduce((s, x) => s + parseInt(x.nominalPrice) * x.amount, 0);
        const body = {
            companyId, totalAmount: String(totalAmount), currencyId: pick(c.currencies).id,
            changeReason, stocks,
        };
        mutate('update', () => jsonPut('/api/capital/update', body));
    }
}

export function handleSummary(data) {
    // Record the load model next to the metrics so summarize.py can report it.
    data.bench = {
        vus: VUS, totalOps: TOTAL_OPS, rate: RATE, durationS: DURATION_S,
        executor: RATE > 0 ? 'constant-arrival-rate' : 'shared-iterations',
        partitionIds: PARTITION_IDS, loginEveryIteration: LOGIN_EVERY_ITERATION,
        seedSource: SEED_FROM_FILE ? 'file' : 'api',
    };
    return {
        [RESULT_FILE]: JSON.stringify(data, null, 2),
        stdout: textSummary(data, { indent: ' ', enableColors: false }),
    };
}
