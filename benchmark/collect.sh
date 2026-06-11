#!/usr/bin/env bash
# ============================================================================
# Audit-method benchmark — metrics collector.
#
# After a scenario's load run, snapshots how much audit data each method
# produced and (for CDC) the end-to-end pipeline lag. Writes CSVs into the
# scenario's results dir. Reads directly from the running DB containers.
#
# Usage: ./collect.sh <scenario> <outdir>
#   scenario : baseline | cdc | triggers | envers   (labels the output)
#   outdir   : directory to write storage.csv / lag.csv into
#
# Container names (compose): mainDb (source), timescaledb (audit store).
# ============================================================================
set -euo pipefail

SCENARIO="${1:?usage: collect.sh <scenario> <outdir>}"
OUTDIR="${2:?usage: collect.sh <scenario> <outdir>}"
mkdir -p "$OUTDIR"

MAIN_DB_C="${MAIN_DB_CONTAINER:-mainDb}"
AUDIT_DB_C="${AUDIT_DB_CONTAINER:-timescaledb}"

main_psql() { docker exec -i "$MAIN_DB_C" psql -U admin -d mainDb -tAF',' -c "$1"; }
audit_psql() { docker exec -i "$AUDIT_DB_C" psql -U admin -d auditdb -tAF',' -c "$1"; }

STORAGE_CSV="$OUTDIR/storage.csv"
echo "scenario,method,audit_table,row_count,total_bytes,total_pretty" > "$STORAGE_CSV"

# Emit one storage row per audit table matching $pattern in the given DB.
# $1=runner (main_psql|audit_psql) $2=method-label $3=LIKE-pattern (ILIKE)
collect_storage() {
    local runner="$1" method="$2" pattern="$3"
    local tables
    tables=$($runner "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename ILIKE '$pattern' ORDER BY tablename;")
    for t in $tables; do
        [ -z "$t" ] && continue
        local cnt bytes pretty
        cnt=$($runner "SELECT count(*) FROM \"$t\";")
        bytes=$($runner "SELECT pg_total_relation_size('\"$t\"');")
        pretty=$($runner "SELECT pg_size_pretty(pg_total_relation_size('\"$t\"'));")
        echo "$SCENARIO,$method,$t,$cnt,$bytes,$pretty" >> "$STORAGE_CSV"
    done
}

case "$SCENARIO" in
    triggers)
        collect_storage main_psql triggers '%\_trigger\_audit' ;;
    envers)
        collect_storage main_psql envers '%\_aud'   # entity revision tables (company_aud, ...)
        collect_storage main_psql envers 'revinfo' ;;
    cdc)
        collect_storage audit_psql cdc '%\_audit' ;;
    baseline)
        : ;;  # baseline writes no audit data
    *)
        echo "unknown scenario: $SCENARIO" >&2; exit 1 ;;
esac

# ── CDC end-to-end lag (ms) across every *_audit table ──────────────────────
if [ "$SCENARIO" = "cdc" ]; then
    LAG_CSV="$OUTDIR/lag.csv"
    echo "scenario,sample_rows,lag_p50_ms,lag_p95_ms,lag_p99_ms,lag_max_ms" > "$LAG_CSV"
    local_tables=$(audit_psql "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename ILIKE '%\\_audit' ORDER BY tablename;")
    union=""
    for t in $local_tables; do
        [ -z "$t" ] && continue
        [ -n "$union" ] && union="$union UNION ALL "
        union="$union SELECT extract(epoch FROM (ingested_at - changed_at))*1000 AS lag_ms FROM \"$t\" WHERE ingested_at IS NOT NULL"
    done
    if [ -n "$union" ]; then
        audit_psql "
            WITH l AS ($union)
            SELECT 'cdc',
                   count(*),
                   round(percentile_disc(0.50) WITHIN GROUP (ORDER BY lag_ms)::numeric, 2),
                   round(percentile_disc(0.95) WITHIN GROUP (ORDER BY lag_ms)::numeric, 2),
                   round(percentile_disc(0.99) WITHIN GROUP (ORDER BY lag_ms)::numeric, 2),
                   round(max(lag_ms)::numeric, 2)
            FROM l;" >> "$LAG_CSV"
    fi
    echo "  wrote $LAG_CSV"
fi

echo "  wrote $STORAGE_CSV"
