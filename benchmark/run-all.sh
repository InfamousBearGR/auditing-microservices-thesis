#!/usr/bin/env bash
# ============================================================================
# Audit-method benchmark — orchestrator.
#
# Runs the SAME fixed k6 workload under 4 isolated scenarios and collects
# per-method metrics, so the thesis can attribute write-path overhead and audit
# volume to each method:
#
#   baseline  — no auditing            (triggers disabled, no CDC, Envers off)
#   cdc       — Debezium CDC pipeline  (Kafka + Debezium + audit-consumer)
#   triggers  — synchronous DB triggers
#   envers    — Hibernate Envers       (api booted with prod,envers profile)
#
# Each scenario starts from a clean stack (down -v) so the source DB is
# identical. Results land in benchmark/results/<scenario>/.
#
# Env knobs:
#   SCENARIOS   default "baseline cdc triggers envers"
#   VUS         default 10
#   TOTAL_OPS   default 2000
#   K6_IMAGE    default grafana/k6
#   CDC_DRAIN_S default 20   (seconds to let the async consumer catch up)
#   REPEATS     default 1    (>1: run every scenario N times, round-robin, into
#                             results/<scenario>/run-<k>/; summarize.py then
#                             reports the median across runs + the spread)
#
# Run from anywhere: ./benchmark/run-all.sh
# ============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SCENARIOS="${SCENARIOS:-baseline cdc triggers envers}"
VUS="${VUS:-10}"
TOTAL_OPS="${TOTAL_OPS:-2000}"
K6_IMAGE="${K6_IMAGE:-grafana/k6}"
CDC_DRAIN_S="${CDC_DRAIN_S:-20}"
REPEATS="${REPEATS:-1}"
RESULTS_DIR="$REPO_ROOT/benchmark/results"
ENTITIES=(company person legal_entity member company_stocks company_capital)

DC="docker compose"
log() { printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }

main_psql() { docker exec -i mainDb psql -U admin -d mainDb -tAc "$1"; }
audit_psql() { docker exec -i timescaledb psql -U admin -d auditdb -tAc "$1"; }

wait_for_cdc() {
    # Debezium Connect REST + connector registration + replication-slot creation
    # must complete before k6, or the workload's WAL changes predate the slot and
    # are never captured. Poll the connector to RUNNING.
    log "waiting for Debezium connector 'audit-connector' RUNNING"
    for i in $(seq 1 60); do
        st=$(curl -s http://localhost:8083/connectors/audit-connector/status 2>/dev/null || true)
        if echo "$st" | grep -q '"state":"FAILED"'; then
            echo "  connector/task FAILED:"; echo "$st" >&2; return 1
        fi
        if echo "$st" | grep -q '"state":"RUNNING"'; then echo "  connector running"; sleep 8; return 0; fi
        sleep 3
    done
    echo "  connector not RUNNING in time" >&2; return 1
}

consumer_total_lag() {
    docker exec kafka-1 /opt/kafka/bin/kafka-consumer-groups.sh \
        --bootstrap-server localhost:9092 --describe --group audit_consumer_group 2>/dev/null \
        | awk 'NR>1 && $6 ~ /^[0-9]+$/ {s+=$6} END {print s+0}'
}

wait_consumer_idle() { # $1 = max seconds
    # Require SUSTAINED zero lag (3 consecutive reads) — a single lag=0 can happen in
    # a momentary gap while Debezium is still PRODUCING snapshot messages, which would
    # truncate too early and leak snapshot rows into the measurement.
    local max="${1:-60}" waited=0 lag zeros=0
    log "waiting for audit-consumer to drain (sustained lag→0, max ${max}s)"
    while [ "$waited" -lt "$max" ]; do
        lag=$(consumer_total_lag)
        if [ "${lag:-1}" = "0" ]; then
            zeros=$((zeros + 1))
            [ "$zeros" -ge 3 ] && { echo "  consumer caught up"; return 0; }
        else
            zeros=0
        fi
        sleep 4; waited=$((waited + 4))
    done
    echo "  consumer still has lag=$(consumer_total_lag) after ${max}s"
}

truncate_cdc_audit() {
    # Drop the initial-snapshot rows so the cdc scenario's audit volume reflects
    # ONLY the k6 workload (parity with triggers/envers, which start empty).
    local tables
    tables=$(audit_psql "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename ILIKE '%\\_audit';")
    for t in $tables; do
        [ -z "$t" ] && continue
        audit_psql "TRUNCATE TABLE \"$t\";" >/dev/null
    done
    echo "  cdc audit tables truncated (post-snapshot)"
}

set_triggers() { # $1 = ENABLE|DISABLE
    for t in "${ENTITIES[@]}"; do
        main_psql "ALTER TABLE $t $1 TRIGGER ${t}_audit_trigger;" >/dev/null
    done
    echo "  triggers ${1,,}d"
}

wait_for_api() {
    # /actuator/health is secured (403); /api/auth/status is public and returns 200 once up.
    log "waiting for business-registry-api"
    for i in $(seq 1 60); do
        code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8084/api/auth/status || true)
        [ "$code" = "200" ] && { echo "  api up"; return 0; }
        sleep 3
    done
    echo "  api did not become healthy" >&2; return 1
}

wait_for_db() {
    log "waiting for mainDb"
    for i in $(seq 1 40); do
        docker exec mainDb pg_isready -U admin -d mainDb >/dev/null 2>&1 && { sleep 2; echo "  db up"; return 0; }
        sleep 2
    done
    echo "  mainDb not ready" >&2; return 1
}

run_k6() { # $1 = result dir
    local rdir="$1"
    local net
    net=$(docker inspect mainDb -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}')
    mkdir -p "$rdir"
    log "k6: $VUS VUs x $TOTAL_OPS ops (net=$net)"
    # Run k6 as the host user so it can write k6-summary.json into the mounted dir.
    docker run --rm --network "$net" --user "$(id -u):$(id -g)" \
        -e BASE_URL=http://business-registry-api:8084 \
        -e USERNAME=admin -e PASSWORD=testPassword \
        -e VUS="$VUS" -e TOTAL_OPS="$TOTAL_OPS" -e RESULT_FILE=/out/k6-summary.json \
        -v "$REPO_ROOT/benchmark":/b -v "$rdir":/out \
        "$K6_IMAGE" run /b/load.js
}

run_scenario() { # $1 = scenario, $2 = result dir
    local sc="$1"
    local rdir="$2"
    rm -rf "$rdir"; mkdir -p "$rdir"

    log "SCENARIO: $sc — resetting stack"
    $DC down -v --remove-orphans >/dev/null 2>&1 || true

    case "$sc" in
        cdc)
            # audit-consumer is started LATER (after the connector creates the topics) —
            # a pattern-subscribed consumer that starts before its topics exist gets an
            # empty partition assignment and won't pick them up until metadata refresh.
            # snapshot.mode=initial (default) so Debezium pre-creates all topics — a
            # pattern-subscribed consumer started afterwards then gets a real partition
            # assignment. The seed-snapshot rows are drained then TRUNCATED below, so the
            # measured cdc volume/lag reflects only the post-truncate k6 workload.
            BR_API_PROFILES=prod $DC up -d --no-build \
                mainDb auditDb kafka-1 kafka-2 kafka-3 debezium debezium-setup business-registry-api
            ;;
        envers)
            BR_API_PROFILES=prod,envers $DC up -d --no-build mainDb business-registry-api
            ;;
        *) # baseline, triggers
            BR_API_PROFILES=prod $DC up -d --no-build mainDb business-registry-api
            ;;
    esac

    wait_for_db
    case "$sc" in
        triggers) set_triggers ENABLE ;;
        *)        set_triggers DISABLE ;;
    esac
    wait_for_api

    if [ "$sc" = "cdc" ]; then
        wait_for_cdc
        log "starting audit-consumer (topics now exist)"
        BR_API_PROFILES=prod $DC up -d --no-build audit-consumer >/dev/null 2>&1
        wait_consumer_idle 90    # let it consume the initial snapshot
        truncate_cdc_audit       # drop snapshot rows so volume = k6 workload only
    fi

    run_k6 "$rdir"

    if [ "$sc" = "cdc" ]; then
        log "draining async CDC pipeline (lag→0, max ${CDC_DRAIN_S}s)"
        wait_consumer_idle "$CDC_DRAIN_S"
    fi

    log "collecting metrics for $sc"
    "$REPO_ROOT/benchmark/collect.sh" "$sc" "$rdir"
}

# ── build all required images once up front ─────────────────────────────────
log "building images"
$DC build business-registry-api audit-consumer

if [ "$REPEATS" -le 1 ]; then
    for sc in $SCENARIOS; do
        run_scenario "$sc" "$RESULTS_DIR/$sc"
    done
else
    # Round-robin (run 1 of every scenario, then run 2, ...) so slow drift of the
    # host (thermal, caches, other load) spreads evenly across the scenarios.
    for sc in $SCENARIOS; do rm -rf "$RESULTS_DIR/$sc"; done
    for k in $(seq 1 "$REPEATS"); do
        for sc in $SCENARIOS; do
            log "REPEAT $k/$REPEATS"
            run_scenario "$sc" "$RESULTS_DIR/$sc/run-$k"
        done
    done
fi

log "tearing down"
$DC down -v --remove-orphans >/dev/null 2>&1 || true

log "summarising"
PY="$(command -v python3 || command -v python || true)"
if [ -n "$PY" ]; then
    "$PY" "$REPO_ROOT/benchmark/summarize.py" "$RESULTS_DIR" || \
        echo "  (summarize.py failed — raw CSV/JSON still in $RESULTS_DIR)"
else
    echo "  (no python found — run: python3 benchmark/summarize.py benchmark/results)"
fi

log "DONE — results in $RESULTS_DIR"
