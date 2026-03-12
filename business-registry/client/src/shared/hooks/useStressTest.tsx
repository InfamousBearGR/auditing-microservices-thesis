import { useCallback, useRef, useState } from "react";
import { httpClient } from "src/shared/services/httpClient/httpClient";
import { ParametricDto } from "src/shared/types/types";

// ────────────────────────────────────────────────────────────────
// Random helpers
// ────────────────────────────────────────────────────────────────
const ri = (min: number, max: number) =>
  Math.floor(Math.random() * (max - min + 1)) + min;

const pick = <T,>(arr: T[]): T => arr[ri(0, arr.length - 1)];

const rStr = (prefix: string) =>
  `${prefix}_${Math.random().toString(36).substring(2, 7)}`;

/** Generates a valid 9-digit Greek AFM that passes the checksum algorithm. */
const rAfm = (): string => {
  const digits = Array.from({ length: 8 }, () => ri(0, 9));
  let sum = 0;
  for (let i = 0; i < 8; i++) {
    sum += digits[i] * (1 << (8 - i)); // v << (8-i) matches the Groovy algorithm
  }
  const check = (sum % 11) % 10;
  return [...digits, check].join("");
};

/** Generates a registry number that is exactly 12 numeric digits (no leading zeros). */
const rRegNum = (): string =>
  String(100_000_000_000 + Math.floor(Math.random() * 900_000_000_000));

const rPhone = () => `69${String(ri(10_000_000, 99_999_999))}`;

const rDate = (y1: number, y2: number): string => {
  const t1 = new Date(y1, 0, 1).getTime();
  const t2 = new Date(y2, 11, 31).getTime();
  return new Date(t1 + Math.random() * (t2 - t1)).toISOString().split("T")[0];
};

/** Generates a future date (today … today + maxYears).
 *  Used for fields that must NOT be in the past (e.g. member dateTo). */
const rFutureDate = (maxYears = 5): string => {
  const today = Date.now();
  const max = new Date(new Date().getFullYear() + maxYears, 11, 31).getTime();
  return new Date(today + Math.random() * (max - today)).toISOString().split("T")[0];
};

const rPostal = () => String(ri(10_000, 99_999));

// ────────────────────────────────────────────────────────────────
// Types
// ────────────────────────────────────────────────────────────────
interface GeoOption {
  regionId: number;
  prefectureId: number;
  municipalityId: number;
}

interface ParametricCache {
  countries: ParametricDto[];
  legalTypes: ParametricDto[];
  companyStatuses: ParametricDto[];
  currencies: ParametricDto[];
  stockTypes: ParametricDto[];
  memberRelations: ParametricDto[];
  geoOptions: GeoOption[];
}

// ────────────────────────────────────────────────────────────────
// Hook
// ────────────────────────────────────────────────────────────────
export const useStressTest = () => {
  const [isRunning, setIsRunning] = useState(false);
  const [opCount, setOpCount] = useState(0);

  const isRunningRef = useRef(false);
  const cacheRef = useRef<ParametricCache | null>(null);
  const companyIds = useRef<number[]>([]);
  const personIds = useRef<number[]>([]);
  const leIds = useRef<number[]>([]);

  // ── build parametric cache ──────────────────────────────────
  const buildCache = useCallback(async (): Promise<ParametricCache> => {
    const [cRes, rRes, ltRes, csRes, curRes, stRes, mrRes] = await Promise.all([
      httpClient.get<ParametricDto[]>("/api/country/translations"),
      httpClient.get<ParametricDto[]>("/api/region/translations"),
      httpClient.get<ParametricDto[]>("/api/legalType/translations"),
      httpClient.get<ParametricDto[]>("/api/companyStatus/translations"),
      httpClient.get<ParametricDto[]>("/api/currency/translations"),
      httpClient.get<ParametricDto[]>("/api/stockType/translations"),
      httpClient.get<ParametricDto[]>("/api/memberRelation/translations"),
    ]);

    const regions = rRes.data.slice(0, 4);
    const geoOptions: GeoOption[] = [];

    for (const reg of regions) {
      try {
        const prefRes = await httpClient.get<ParametricDto[]>(
          `/api/prefecture/translations/${reg.id}`,
        );
        for (const pref of prefRes.data.slice(0, 3)) {
          try {
            const munRes = await httpClient.get<ParametricDto[]>(
              `/api/municipality/translations/${pref.id}`,
            );
            for (const mun of munRes.data.slice(0, 3)) {
              geoOptions.push({
                regionId: reg.id,
                prefectureId: pref.id,
                municipalityId: mun.id,
              });
            }
          } catch {
            /* skip */
          }
        }
      } catch {
        /* skip */
      }
    }

    return {
      countries: cRes.data,
      legalTypes: ltRes.data,
      companyStatuses: csRes.data,
      currencies: curRes.data,
      stockTypes: stRes.data,
      memberRelations: mrRes.data,
      geoOptions,
    };
  }, []);

  // ── seed entity id lists from current index ─────────────────
  const seedIds = useCallback(async () => {
    const [cos, pos, les] = await Promise.all([
      httpClient.get<{ id: number }[]>("/api/company/index"),
      httpClient.get<{ id: number }[]>("/api/person/index"),
      httpClient.get<{ id: number }[]>("/api/legalEntity/index"),
    ]);
    companyIds.current = cos.data.map((x) => x.id);
    personIds.current = pos.data.map((x) => x.id);
    leIds.current = les.data.map((x) => x.id);
  }, []);

  // ── single random operation ──────────────────────────────────
  const runOneOp = useCallback(async () => {
    const cache = cacheRef.current;
    if (!cache || !cache.geoOptions.length) return;

    const geo = pick(cache.geoOptions);
    const country = pick(cache.countries);
    const changeReason = `stress-test @ ${new Date().toISOString()}`;

    // weights: company 25%, person 25%, legalEntity 20%, member 15%, capital 15%
    const wheel = ["company", "company", "company", "person", "person", "person",
      "legalEntity", "legalEntity", "legalEntity", "member", "member", "capital", "capital"];
    const entity = pick(wheel);

    // weights: create 60%, update 25%, delete 15%
    const opWheel = ["create", "create", "create", "create", "create",
      "create", "update", "update", "update", "delete", "delete"];
    const op = pick(opWheel);

    try {
      // ── COMPANY ──────────────────────────────────────────────
      if (entity === "company") {
        if (op === "create") {
          const res = await httpClient.post<{ id: number }>("/api/company/create", {
            name: rStr("Company"),
            city: rStr("City"),
            street: rStr("Street"),
            streetNumber: String(ri(1, 999)),
            postalCode: rPostal(),
            afm: rAfm(),
            legalTypeId: pick(cache.legalTypes).id,
            dateIncorporated: rDate(1980, 2024),
            registryNumber: rRegNum(),
            companyStatusId: pick(cache.companyStatuses).id,
            regionId: geo.regionId,
            prefectureId: geo.prefectureId,
            municipalityId: geo.municipalityId,
            countryId: country.id,
            changeReason,
          });
          if (res.data?.id) companyIds.current.push(res.data.id);
        } else if (op === "update" && companyIds.current.length > 0) {
          const id = pick(companyIds.current);
          await httpClient.put(`/api/company/update/${id}`, {
            name: rStr("CompanyUpd"),
            city: rStr("City"),
            street: rStr("Street"),
            streetNumber: String(ri(1, 999)),
            postalCode: rPostal(),
            afm: rAfm(),
            legalTypeId: pick(cache.legalTypes).id,
            dateIncorporated: rDate(1980, 2024),
            registryNumber: rRegNum(),
            companyStatusId: pick(cache.companyStatuses).id,
            regionId: geo.regionId,
            prefectureId: geo.prefectureId,
            municipalityId: geo.municipalityId,
            countryId: country.id,
            changeReason,
          });
        } else if (op === "delete" && companyIds.current.length > 0) {
          const id = pick(companyIds.current);
          await httpClient.delete(`/api/company/delete/${id}`, {
            data: { changeReason },
          });
          companyIds.current = companyIds.current.filter((i) => i !== id);
        }
      }

      // ── PERSON ───────────────────────────────────────────────
      else if (entity === "person") {
        if (op === "create") {
          const res = await httpClient.post<{ id: number }>("/api/person/create", {
            name: rStr("Name"),
            surname: rStr("Surname"),
            afm: rAfm(),
            city: rStr("City"),
            street: rStr("Street"),
            streetNumber: String(ri(1, 999)),
            postalCode: rPostal(),
            birthDate: rDate(1950, 2000),
            birthPlace: rStr("Place"),
            identityNumber: rStr("ID"),
            phoneNumber: rPhone(),
            regionId: geo.regionId,
            prefectureId: geo.prefectureId,
            municipalityId: geo.municipalityId,
            countryId: country.id,
            changeReason,
          });
          if (res.data?.id) personIds.current.push(res.data.id);
        } else if (op === "update" && personIds.current.length > 0) {
          const id = pick(personIds.current);
          await httpClient.put(`/api/person/update/${id}`, {
            name: rStr("NameUpd"),
            surname: rStr("SurnameUpd"),
            afm: rAfm(),
            city: rStr("City"),
            street: rStr("Street"),
            streetNumber: String(ri(1, 999)),
            postalCode: rPostal(),
            birthDate: rDate(1950, 2000),
            birthPlace: rStr("Place"),
            identityNumber: rStr("ID"),
            phoneNumber: rPhone(),
            regionId: geo.regionId,
            prefectureId: geo.prefectureId,
            municipalityId: geo.municipalityId,
            countryId: country.id,
            changeReason,
          });
        } else if (op === "delete" && personIds.current.length > 0) {
          const id = pick(personIds.current);
          await httpClient.delete(`/api/person/delete/${id}`, {
            data: { changeReason },
          });
          personIds.current = personIds.current.filter((i) => i !== id);
        }
      }

      // ── LEGAL ENTITY ─────────────────────────────────────────
      else if (entity === "legalEntity") {
        if (op === "create") {
          const res = await httpClient.post<{ id: number }>("/api/legalEntity/create", {
            registryNumber: rStr("LER"),
            businessName: rStr("Business"),
            phoneNumber: rPhone(),
            afm: rAfm(),
            city: rStr("City"),
            street: rStr("Street"),
            streetNumber: String(ri(1, 999)),
            postalCode: rPostal(),
            regionId: geo.regionId,
            prefectureId: geo.prefectureId,
            municipalityId: geo.municipalityId,
            countryId: country.id,
            changeReason,
          });
          if (res.data?.id) leIds.current.push(res.data.id);
        } else if (op === "update" && leIds.current.length > 0) {
          const id = pick(leIds.current);
          await httpClient.put(`/api/legalEntity/update/${id}`, {
            registryNumber: rStr("LER"),
            businessName: rStr("BusinessUpd"),
            phoneNumber: rPhone(),
            afm: rAfm(),
            city: rStr("City"),
            street: rStr("Street"),
            streetNumber: String(ri(1, 999)),
            postalCode: rPostal(),
            regionId: geo.regionId,
            prefectureId: geo.prefectureId,
            municipalityId: geo.municipalityId,
            countryId: country.id,
            changeReason,
          });
        } else if (op === "delete" && leIds.current.length > 0) {
          const id = pick(leIds.current);
          await httpClient.delete(`/api/legalEntity/delete/${id}`, {
            data: { changeReason },
          });
          leIds.current = leIds.current.filter((i) => i !== id);
        }
      }

      // ── MEMBER ───────────────────────────────────────────────
      else if (entity === "member" && companyIds.current.length > 0) {
        const companyId = pick(companyIds.current);

        // Decide whether to use a person or a legal entity
        let usePerson = Math.random() > 0.4 && personIds.current.length > 0;

        // Legal entity members require a representativeOfMemberId; fetch existing
        // members for this company to obtain one, falling back to person if none.
        let representativeOfMemberId: number | null = null;
        if (!usePerson && leIds.current.length > 0) {
          try {
            const membersRes = await httpClient.get<{ id: number }[]>(
              `/api/member/index/${companyId}`,
            );
            if (membersRes.data.length > 0) {
              representativeOfMemberId = pick(membersRes.data).id;
            } else {
              usePerson = true;
            }
          } catch {
            usePerson = true;
          }
        } else {
          usePerson = true;
        }

        // Final guard: if there are no person IDs available, skip this op
        if (usePerson && personIds.current.length === 0) return;

        const personId = usePerson ? pick(personIds.current) : null;
        const legalEntityId =
          !usePerson && leIds.current.length > 0 ? pick(leIds.current) : null;

        // Exactly one of representedIndividual / representedTogether must be true
        const representedIndividual = Math.random() > 0.5;
        const representedTogether = !representedIndividual;

        if (personId !== null || legalEntityId !== null) {
          await httpClient.post("/api/member/create", {
            active: Math.random() > 0.2,
            dateFrom: rDate(2000, 2024),
            dateTo: rFutureDate(5),
            percentageOfOwnership: String(ri(1, 100)),
            personId,
            legalEntityId,
            companyId,
            representativeOfMemberId,
            representedIndividual,
            representedTogether,
            memberRelationId: pick(cache.memberRelations).id,
            changeReason,
          });
        }
      }

      // ── COMPANY CAPITAL / STOCKS ─────────────────────────────
      else if (entity === "capital" && companyIds.current.length > 0) {
        const companyId = pick(companyIds.current);
        const numStocks = ri(1, 3);
        const stocks = Array.from({ length: numStocks }, () => ({
          companyId,
          stockTypeId: pick(cache.stockTypes).id,
          amount: ri(100, 50_000),
          nominalPrice: String(ri(1, 500)),
          toBeDeleted: false,
        }));
        // totalAmount must exactly match Σ(nominalPrice × amount) to pass server validation
        const totalAmount = stocks.reduce(
          (sum, s) => sum + parseInt(s.nominalPrice) * s.amount,
          0,
        );
        await httpClient.put("/api/capital/update", {
          companyId,
          totalAmount: String(totalAmount),
          currencyId: pick(cache.currencies).id,
          changeReason,
          stocks,
        });
      }

      setOpCount((c) => c + 1);
    } catch {
      /* silently ignore – constraint violations are expected during stress */
    }
  }, []);

  // ── async loop ───────────────────────────────────────────────
  const runLoop = useCallback(async () => {
    while (isRunningRef.current) {
      await runOneOp();
      // random delay 150 – 600 ms
      await new Promise<void>((r) => setTimeout(r, ri(150, 600)));
    }
  }, [runOneOp]);

  // ── public API ───────────────────────────────────────────────
  const start = useCallback(async () => {
    isRunningRef.current = true;
    setIsRunning(true);
    setOpCount(0);

    if (!cacheRef.current) {
      try {
        cacheRef.current = await buildCache();
      } catch (e) {
        console.error("[StressTest] Failed to build parametric cache:", e);
        isRunningRef.current = false;
        setIsRunning(false);
        return;
      }
    }

    try {
      await seedIds();
    } catch {
      /* non-fatal */
    }

    runLoop();
  }, [buildCache, seedIds, runLoop]);

  const stop = useCallback(() => {
    isRunningRef.current = false;
    setIsRunning(false);
  }, []);

  const toggle = useCallback(() => {
    if (isRunningRef.current) stop();
    else start();
  }, [start, stop]);

  return { isRunning, opCount, toggle };
};

