-- ============================================================================
-- Audit-method benchmark — bulk seed of the source registry (run by run-all.sh).
--
-- The init.sql sample data has only 15 companies / 30 persons / 30 legal
-- entities. With dozens of concurrent VUs updating and deleting that handful of
-- rows, most mutations failed because another VU had already deleted the row.
-- This script adds :rows companies, persons and legal entities (copies of the
-- sample rows with unique names / ΑΦΜ / Γ.Ε.ΜΗ. numbers and the same, valid
-- reference ids) so each VU gets its own disjoint share of ids (load.js).
--
-- Run BEFORE the audit methods are switched on: session_replication_role =
-- replica skips every ordinary trigger (audit triggers, timestamp triggers), and
-- the CDC connector is registered only afterwards, so the seed rows land in the
-- initial snapshot that the benchmark drains and truncates.
--
-- psql -v rows=2000 -f seed.sql
-- ============================================================================
\set ON_ERROR_STOP on
BEGIN;
SET LOCAL session_replication_role = replica;

WITH base AS (SELECT row_number() OVER (ORDER BY id) AS rn, * FROM company),
     n AS (SELECT count(*) AS cnt FROM base)
INSERT INTO company (name, city, street, country_id, prefecture_id, municipality_id, street_number, region_id,
                     postal_code, afm, legal_type_id, date_incorporated, gemi_number, company_status_id,
                     last_user_id, change_reason, date_created, last_updated)
SELECT b.name || ' #' || g, b.city, b.street, b.country_id, b.prefecture_id, b.municipality_id, b.street_number,
       b.region_id, b.postal_code, lpad((200000000 + g)::text, 9, '0'), b.legal_type_id, b.date_incorporated,
       lpad((300000000000 + g)::text, 12, '0'), b.company_status_id, b.last_user_id, 'benchmark seed', now(), now()
FROM generate_series(1, :rows) AS g
         JOIN base b ON b.rn = ((g - 1) % (SELECT cnt FROM n)) + 1;

WITH base AS (SELECT row_number() OVER (ORDER BY id) AS rn, * FROM person),
     n AS (SELECT count(*) AS cnt FROM base)
INSERT INTO person (name, surname, afm, city, street, country_id, prefecture_id, municipality_id, street_number,
                    region_id, postal_code, birth_date, birth_place, identity_number, phone_number,
                    last_user_id, change_reason, date_created, last_updated)
SELECT b.name, b.surname || ' #' || g, lpad((400000000 + g)::text, 9, '0'), b.city, b.street, b.country_id,
       b.prefecture_id, b.municipality_id, b.street_number, b.region_id, b.postal_code, b.birth_date, b.birth_place,
       'BS' || g, b.phone_number, b.last_user_id, 'benchmark seed', now(), now()
FROM generate_series(1, :rows) AS g
         JOIN base b ON b.rn = ((g - 1) % (SELECT cnt FROM n)) + 1;

WITH base AS (SELECT row_number() OVER (ORDER BY id) AS rn, * FROM legal_entity),
     n AS (SELECT count(*) AS cnt FROM base)
INSERT INTO legal_entity (gemi_number, business_name, phone_number, afm, city, street, country_id, prefecture_id,
                          municipality_id, street_number, region_id, postal_code, last_user_id, change_reason,
                          date_created, last_updated)
SELECT lpad((500000000000 + g)::text, 12, '0'), b.business_name || ' #' || g, b.phone_number,
       lpad((600000000 + g)::text, 9, '0'), b.city, b.street, b.country_id, b.prefecture_id, b.municipality_id,
       b.street_number, b.region_id, b.postal_code, b.last_user_id, 'benchmark seed', now(), now()
FROM generate_series(1, :rows) AS g
         JOIN base b ON b.rn = ((g - 1) % (SELECT cnt FROM n)) + 1;

COMMIT;
ANALYZE company;
ANALYZE person;
ANALYZE legal_entity;
