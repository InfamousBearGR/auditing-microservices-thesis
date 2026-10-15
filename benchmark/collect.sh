#!/usr/bin/env bash
# ============================================================================
# Audit-method benchmark — metrics collector.
#
# After a scenario's load run, snapshots how much audit data each method
# produced and (for CDC) the end-to-end pipeline lag. Writes CSVs into the
# scenario's results dir. Reads directly from the running DB containers.
#
# Usage: ./collect.sh <scenario> <outdir>
#   scenario : baseline | cdc | triggers | envers | cdc-idle | cdc-slot | cdc-failover
#   outdir   : directory to write the CSVs into
#
# Outputs
#   storage.csv             per audit table: rows, on-disk bytes (heap / toast /
#                           index split), live / dead tuples, tuples ever inserted,
#                           and the size after VACUUM FULL (compact_bytes)
#   lag.csv                 (cdc*) audit-store lag percentiles: ingested_at − changed_at
#   lag_timeseries.csv      (cdc*) the same lag per 1-second bucket of commit time
#   integrity.csv           (cdc-failover) missing / duplicated events vs triggers
#   storage_compressed.csv  (cdc) hypertable sizes after TimescaleDB compression
#
# Why dead tuples and compact size: a synchronous audit row (trigger / Envers) is
# written inside the user's transaction, so when that transaction rolls back the
# audit row stays behind as a dead tuple and keeps occupying space until VACUUM
# reuses it (VACUUM never shrinks the table). The on-disk size therefore grows with
# the number of FAILED mutations, not only with the audit rows that exist. CDC only
# ever sees committed changes. total_bytes is what the method really costs on disk;
# compact_bytes (after VACUUM FULL) isolates the size of the stored representation.
#
# Container names (compose): mainDb (source), timescaledb (audit store).
# ============================================================================
set -euo pipefail

SCENARIO="${1:?usage: collect.sh <scenario> <outdir>}"
OUTDIR="${2:?usage: collect.sh <scenario> <outdir>}"
mkdir -p "$OUTDIR"

MAIN_DB_C="${MAIN_DB_CONTAINER:-mainDb}"
AUDIT_DB_C="${AUDIT_DB_CONTAINER:-timescaledb}"
# Backends publish their table statistics (n_dead_tup, ...) at most every ~10 s
# while idle (PostgreSQL ≥ 15), so give the API's pooled connections time to flush.
STATS_SETTLE_S="${STATS_SETTLE_S:-12}"
COMPACT="${COMPACT:-1}"   # 1 = also measure the size after VACUUM FULL

main_psql() { docker exec -i "$MAIN_DB_C" psql -U admin -d mainDb -tAF',' -c "$1"; }
audit_psql() { docker exec -i "$AUDIT_DB_C" psql -U admin -d auditdb -tAF',' -c "$1"; }

STORAGE_CSV="$OUTDIR/storage.csv"
echo "scenario,method,audit_table,row_count,total_bytes,total_pretty,heap_bytes,toast_bytes,index_bytes,live_tuples,dead_tuples,inserted_tuples,compact_bytes" > "$STORAGE_CSV"

case "$SCENARIO" in
    triggers|envers|cdc|cdc-failover)
        echo "  waiting ${STATS_SETTLE_S}s for table statistics to settle"
        sleep "$STATS_SETTLE_S" ;;
esac

# Emit one storage row per audit table matching $pattern in the given DB.
# $1=runner (main_psql|audit_psql) $2=method-label $3=LIKE-pattern (ILIKE)
#
# Size: pg_total_relation_size() on a TimescaleDB hypertable only measures the
# (empty) parent relation — the rows live in chunk tables under
# _timescaledb_internal — so for hypertables we use hypertable_detailed_size(),
# which sums the parent, all chunks, their indexes and toast. Plain tables
# (triggers / Envers in mainDb) use the catalog size functions directly.
collect_storage() {
    local runner="$1" method="$2" pattern="$3"
    local tables has_ts
    tables=$($runner "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename ILIKE '$pattern' ORDER BY tablename;")
    # Two separate probes: a query that names timescaledb_information.* would
    # fail to even parse in mainDb, where the extension is not installed.
    has_ts=$($runner "SELECT 1 FROM pg_extension WHERE extname='timescaledb';")
    for t in $tables; do
        [ -z "$t" ] && continue
        local cnt is_ht="" sizes stats total heap toast idx live dead ins pretty compact=""
        cnt=$($runner "SELECT count(*) FROM \"$t\";")
        if [ "$has_ts" = "1" ]; then
            is_ht=$($runner "SELECT 1 FROM timescaledb_information.hypertables WHERE hypertable_schema='public' AND hypertable_name='$t';")
        fi
        if [ "$is_ht" = "1" ]; then
            # total,heap,toast,index
            sizes=$($runner "SELECT total_bytes, table_bytes, toast_bytes, index_bytes FROM hypertable_detailed_size('\"$t\"');")
            stats=$($runner "SELECT coalesce(sum(n_live_tup),0), coalesce(sum(n_dead_tup),0), coalesce(sum(n_tup_ins),0)
                             FROM pg_stat_user_tables WHERE relid IN (SELECT c::oid FROM show_chunks('\"$t\"') c);")
        else
            sizes=$($runner "SELECT pg_total_relation_size(c.oid), pg_relation_size(c.oid),
                                    COALESCE(pg_total_relation_size(NULLIF(c.reltoastrelid, 0)), 0), pg_indexes_size(c.oid)
                             FROM pg_class c WHERE c.oid = '\"$t\"'::regclass;")
            stats=$($runner "SELECT coalesce(n_live_tup,0), coalesce(n_dead_tup,0), coalesce(n_tup_ins,0)
                             FROM pg_stat_user_tables WHERE relid = '\"$t\"'::regclass;")
        fi
        IFS=',' read -r total heap toast idx <<< "$sizes"
        IFS=',' read -r live dead ins <<< "${stats:-,,}"
        pretty=$($runner "SELECT pg_size_pretty(${total:-0}::bigint);")
        if [ "$COMPACT" = "1" ]; then
            # VACUUM cannot run inside a transaction block → one psql call per relation.
            if [ "$is_ht" = "1" ]; then
                for ch in $($runner "SELECT c::text FROM show_chunks('\"$t\"') c;"); do
                    $runner "VACUUM FULL $ch;" >/dev/null 2>&1 || echo "  WARN: VACUUM FULL $ch failed" >&2
                done
                compact=$($runner "SELECT hypertable_size('\"$t\"');")
            else
                $runner "VACUUM FULL \"$t\";" >/dev/null 2>&1 || echo "  WARN: VACUUM FULL $t failed" >&2
                compact=$($runner "SELECT pg_total_relation_size('\"$t\"');")
            fi
        fi
        echo "$SCENARIO,$method,$t,$cnt,${total:-},$pretty,${heap:-},${toast:-},${idx:-},${live:-},${dead:-},${ins:-},${compact:-}" >> "$STORAGE_CSV"
    done
}

case "$SCENARIO" in
    triggers)
        collect_storage main_psql triggers '%\_trigger\_audit' ;;
    envers)
        collect_storage main_psql envers '%\_aud'   # entity revision tables (company_aud, ...)
        collect_storage main_psql envers 'revinfo' ;;
    cdc|cdc-failover)
        collect_storage audit_psql cdc '%\_audit' ;;
    baseline|cdc-idle|cdc-slot)
        : ;;  # no audit store to measure (baseline: none; cdc-idle/cdc-slot: overhead controls)
    *)
        echo "unknown scenario: $SCENARIO" >&2; exit 1 ;;
esac
echo "  wrote $STORAGE_CSV"

# ── CDC end-to-end lag (ms) across every *_audit table ──────────────────────
if [ "$SCENARIO" = "cdc" ] || [ "$SCENARIO" = "cdc-failover" ]; then
    LAG_CSV="$OUTDIR/lag.csv"
    TS_CSV="$OUTDIR/lag_timeseries.csv"
    echo "scenario,sample_rows,lag_p50_ms,lag_p95_ms,lag_p99_ms,lag_max_ms" > "$LAG_CSV"
    echo "second,events,lag_p50_ms,lag_p99_ms,lag_max_ms" > "$TS_CSV"
    local_tables=$(audit_psql "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename ILIKE '%\\_audit' ORDER BY tablename;")
    union=""
    for t in $local_tables; do
        [ -z "$t" ] && continue
        [ -n "$union" ] && union="$union UNION ALL "
        union="$union SELECT changed_at, extract(epoch FROM (ingested_at - changed_at))*1000 AS lag_ms FROM \"$t\" WHERE ingested_at IS NOT NULL"
    done
    if [ -n "$union" ]; then
        audit_psql "
            WITH l AS ($union)
            SELECT '$SCENARIO',
                   count(*),
                   round(percentile_disc(0.50) WITHIN GROUP (ORDER BY lag_ms)::numeric, 2),
                   round(percentile_disc(0.95) WITHIN GROUP (ORDER BY lag_ms)::numeric, 2),
                   round(percentile_disc(0.99) WITHIN GROUP (ORDER BY lag_ms)::numeric, 2),
                   round(max(lag_ms)::numeric, 2)
            FROM l;" >> "$LAG_CSV"
        # Per-second view (commit time relative to the first audited change): shows
        # when the audit store fell behind and how long it took to catch up — the
        # failover outage windows in faults.log use the same k6-relative clock only
        # approximately, so both are kept as absolute epoch seconds too.
        audit_psql "
            WITH l AS ($union),
                 t0 AS (SELECT min(changed_at) AS t0 FROM l)
            SELECT floor(extract(epoch FROM (l.changed_at - t0.t0)))::int AS sec,
                   count(*),
                   round(percentile_disc(0.50) WITHIN GROUP (ORDER BY lag_ms)::numeric, 2),
                   round(percentile_disc(0.99) WITHIN GROUP (ORDER BY lag_ms)::numeric, 2),
                   round(max(lag_ms)::numeric, 2)
            FROM l, t0
            GROUP BY 1 ORDER BY 1;" >> "$TS_CSV"
        audit_psql "WITH l AS ($union) SELECT 'first_change_epoch_ms=' || round(extract(epoch FROM min(changed_at))*1000) FROM l;" \
            > "$OUTDIR/lag_timeseries_t0.txt"
    fi
    echo "  wrote $LAG_CSV, $TS_CSV"
fi

# ── cdc-failover: exact loss / duplicate count against the trigger ground truth ─
# In cdc-failover the DB triggers run in parallel with CDC on the same workload,
# so <t>_trigger_audit in mainDb holds exactly one row per committed row-level
# change (rows of rolled-back transactions are dead tuples, not counted).
# change_id in the CDC audit rows is the WAL LSN of the change (unique per row
# change), so:  duplicates = rows − distinct(change_id)   (at-least-once redelivery
# after the consumer crash)  and  missing = trigger_rows − distinct(change_id).
if [ "$SCENARIO" = "cdc-failover" ]; then
    INT_CSV="$OUTDIR/integrity.csv"
    echo "scenario,table,trigger_rows,cdc_rows,cdc_distinct_changes,duplicates,missing" > "$INT_CSV"
    for t in company person legal_entity member company_stocks company_capital; do
        trig=$(main_psql "SELECT count(*) FROM ${t}_trigger_audit;" || echo 0)
        rows=$(audit_psql "SELECT count(*) FROM ${t}_audit;" || echo 0)
        dist=$(audit_psql "SELECT count(DISTINCT change_id) FROM ${t}_audit;" || echo 0)
        dup=$(( rows - dist )); miss=$(( trig - dist ))
        echo "$SCENARIO,$t,$trig,$rows,$dist,$dup,$miss" >> "$INT_CSV"
    done
    echo "  wrote $INT_CSV"
fi

# ── CDC compressed audit storage (TimescaleDB native compression) ───────────
# Runs AFTER storage.csv/lag.csv are written (those reflect the uncompressed,
# row-store hypertables; with COMPACT=1 the chunks were just VACUUM FULLed, which
# changes nothing for insert-only CDC chunks). For every public *_audit hypertable:
# enable compression (no segmentby, orderby changed_at DESC), compress every
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
