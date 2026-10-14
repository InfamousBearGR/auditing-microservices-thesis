#!/usr/bin/env bash
# ============================================================================
# Audit-method benchmark — metrics collector.
#
# After a scenario's load run, snapshots how much audit data each method
# produced (hypertable-aware, see collect_storage) and (for CDC) the
# end-to-end pipeline lag. Writes CSVs into the
# scenario's results dir. Reads directly from the running DB containers.
#
# Usage: ./collect.sh <scenario> <outdir>
#   scenario : baseline | cdc | triggers | envers   (labels the output)
#   outdir   : directory to write storage.csv / lag.csv (+ storage_compressed.csv for cdc) into
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
#
# Size: pg_total_relation_size() on a TimescaleDB hypertable only measures the
# (empty) parent relation — the rows live in chunk tables under
# _timescaledb_internal — so for hypertables we must use hypertable_size(),
# which sums the parent, all chunks, their indexes and toast. Plain tables
# (triggers / Envers in mainDb) keep pg_total_relation_size().
collect_storage() {
    local runner="$1" method="$2" pattern="$3"
    local tables
    tables=$($runner "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename ILIKE '$pattern' ORDER BY tablename;")
    for t in $tables; do
        [ -z "$t" ] && continue
        local cnt bytes pretty
        cnt=$($runner "SELECT count(*) FROM \"$t\";")
        # Two separate probes: a query that names timescaledb_information.* would
        # fail to even parse in mainDb, where the extension is not installed.
        local is_ht
        is_ht=$($runner "SELECT 1 FROM pg_extension WHERE extname='timescaledb';")
        if [ "$is_ht" = "1" ]; then
            is_ht=$($runner "SELECT 1 FROM timescaledb_information.hypertables WHERE hypertable_schema='public' AND hypertable_name='$t';")
        fi
        if [ "$is_ht" = "1" ]; then
            bytes=$($runner "SELECT hypertable_size('\"$t\"');")
        else
            bytes=$($runner "SELECT pg_total_relation_size('\"$t\"');")
        fi
        pretty=$($runner "SELECT pg_size_pretty(${bytes:-0}::bigint);")
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

# ── CDC compressed audit storage (TimescaleDB native compression) ───────────
# Runs AFTER storage.csv/lag.csv are written (those reflect the uncompressed,
# row-store hypertables). For every public *_audit hypertable: enable
# compression (no segmentby, orderby changed_at DESC), compress every
# chunk, then re-measure hypertable_size(). Also records TimescaleDB's own
# hypertable_compression_stats() before/after totals. 0-row tables are kept.
# COMPRESS_SEGMENTBY (env, default empty = no segmentby, one segment stream
# per chunk) optionally names a segmentby column. The settings used are
# recorded in <outdir>/compression_settings.txt.
# Failures here are logged but never abort the benchmark run.
if [ "$SCENARIO" = "cdc" ]; then
    COMP_CSV="$OUTDIR/storage_compressed.csv"
    SEGMENTBY="${COMPRESS_SEGMENTBY:-}"
    ORDERBY="changed_at DESC"
    printf 'segmentby=%s\norderby=%s\n' "$SEGMENTBY" "$ORDERBY" > "$OUTDIR/compression_settings.txt"
    echo "scenario,method,audit_table,row_count,uncompressed_bytes,compressed_bytes,ratio,stats_before_bytes,stats_after_bytes" > "$COMP_CSV"
    ts_ver=$(audit_psql "SELECT extversion FROM pg_extension WHERE extname='timescaledb';" || true)
    echo "  compressing *_audit hypertables (timescaledb ${ts_ver:-?}, segmentby='$SEGMENTBY', orderby='$ORDERBY')"
    ht_tables=$(audit_psql "SELECT hypertable_name FROM timescaledb_information.hypertables WHERE hypertable_schema='public' AND hypertable_name ILIKE '%\\_audit' ORDER BY 1;" || true)
    for t in $ht_tables; do
        [ -z "$t" ] && continue
        cnt=$(audit_psql "SELECT count(*) FROM \"$t\";" || echo "")
        unc=$(audit_psql "SELECT hypertable_size('\"$t\"');" || echo "")
        if ! audit_psql "ALTER TABLE \"$t\" SET (timescaledb.compress, timescaledb.compress_orderby = '$ORDERBY', timescaledb.compress_segmentby = '$SEGMENTBY');" >/dev/null \
           || ! audit_psql "SELECT compress_chunk(c, if_not_compressed => true) FROM show_chunks('\"$t\"') c;" >/dev/null; then
            echo "  WARN: compression failed for $t" >&2
        fi
        comp=$(audit_psql "SELECT hypertable_size('\"$t\"');" || echo "")
        stats=$(audit_psql "SELECT coalesce(sum(before_compression_total_bytes),0), coalesce(sum(after_compression_total_bytes),0) FROM hypertable_compression_stats('\"$t\"');" || echo ",")
        ratio=$(awk -v u="${unc:-0}" -v c="${comp:-0}" 'BEGIN { if (c > 0) printf "%.2f", u / c }')
        echo "$SCENARIO,cdc,$t,$cnt,$unc,$comp,$ratio,$stats" >> "$COMP_CSV"
    done
    echo "  wrote $COMP_CSV"
fi
