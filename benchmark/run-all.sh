#!/usr/bin/env bash
# ============================================================================
# Audit-method benchmark — orchestrator.
#
# Runs the SAME fixed k6 workload under isolated scenarios and collects
# per-method metrics, so the thesis can attribute write-path overhead and audit
# volume to each method:
#
#   baseline     — no auditing            (triggers disabled, no CDC, Envers off)
#   cdc          — Debezium CDC pipeline  (Kafka + Debezium + audit-consumer + SSE bridge)
#   triggers     — synchronous DB triggers
#   envers       — Hibernate Envers       (api booted with prod,envers profile)
#
# Overhead-decomposition controls (optional, see thesis §5.3 / §5.6):
#   cdc-idle     — the whole CDC stack is RUNNING but NO connector is registered:
#                  no replication slot, no logical decoding, no events. Measures the
#                  pure resource-contention cost of the extra processes on one host.
#   cdc-slot     — connector registered and streaming into Kafka, but NO audit
#                  consumer and NO audit DB. Adds the cost of logical decoding +
#                  Debezium + Kafka traffic on top of cdc-idle.
#   cdc-failover — the cdc pipeline with FAULT INJECTION during the workload
#                  (audit-consumer SIGKILLed, then a Kafka broker stopped) and the
#                  DB triggers enabled in parallel as ground truth, so that lost /
#                  duplicated events can be counted exactly (integrity.csv).
#
# Each scenario starts from a clean stack (down -v) so the source DB is
# identical. Results land in benchmark/results/<scenario>/.
#
# Env knobs:
#   SCENARIOS   default "baseline cdc triggers envers"
#   VUS         default 10
#   VU_LEVELS   default ""   (e.g. "8 64": run the whole scenario set once per
#                             VU level into results/vus-<n>/ and write
#                             comparison-by-vus.md; overrides VUS)
#   TOTAL_OPS   default 2000
#   K6_IMAGE    default grafana/k6
#   CDC_DRAIN_S default 20   (seconds to let the async consumer catch up)
#   REPEATS     default 1    (>1: run every scenario N times, round-robin, into
#                             results/<scenario>/run-<k>/; summarize.py then
#                             reports the median across runs + the spread)
#   RESULTS_DIR default benchmark/results (override to write a variant run
#                             elsewhere without wiping the main results)
#   COMPRESS_SEGMENTBY default "" = no segmentby (cdc compressed-size
#                             measurement in collect.sh)
#   SSE_PROBE   default 1    (cdc / cdc-failover: also start sse-bridge and the
#                             SSE latency probe → <scenario>/sse_lag.csv)
#   PROBE_IMAGE default python:3.12-alpine
#   Fault injection (cdc-failover only), seconds relative to the k6 start:
#   FAULT_CONSUMER_AT default 60   FAULT_CONSUMER_DOWN_S default 20
#   FAULT_BROKER_AT   default 120  FAULT_BROKER_DOWN_S   default 30
#   FAULT_BROKER      default kafka-1
#
# Run from anywhere: ./benchmark/run-all.sh
# ============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SCENARIOS="${SCENARIOS:-baseline cdc triggers envers}"
VUS="${VUS:-10}"
VU_LEVELS="${VU_LEVELS:-}"
TOTAL_OPS="${TOTAL_OPS:-2000}"
K6_IMAGE="${K6_IMAGE:-grafana/k6}"
CDC_DRAIN_S="${CDC_DRAIN_S:-20}"
REPEATS="${REPEATS:-1}"
RESULTS_DIR="${RESULTS_DIR:-$REPO_ROOT/benchmark/results}"
SSE_PROBE="${SSE_PROBE:-1}"
PROBE_IMAGE="${PROBE_IMAGE:-python:3.12-alpine}"
FAULT_CONSUMER_AT="${FAULT_CONSUMER_AT:-60}"
FAULT_CONSUMER_DOWN_S="${FAULT_CONSUMER_DOWN_S:-20}"
FAULT_BROKER_AT="${FAULT_BROKER_AT:-120}"
FAULT_BROKER_DOWN_S="${FAULT_BROKER_DOWN_S:-30}"
FAULT_BROKER="${FAULT_BROKER:-kafka-1}"
ENTITIES=(company person legal_entity member company_stocks company_capital)
BENCH_API_KEY="bench_api_key"

DC="docker compose"
log() { printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }
ts() { date '+%Y-%m-%dT%H:%M:%S%z'; }

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

# Any broker that is up can answer the consumer-group query (kafka-1 may be the
# one that is down in cdc-failover).
consumer_total_lag() {
    local b
    for b in kafka-1 kafka-2 kafka-3; do
        if out=$(docker exec "$b" /opt/kafka/bin/kafka-consumer-groups.sh \
                --bootstrap-server localhost:9092 --describe --group audit_consumer_group 2>/dev/null); then
            echo "$out" | awk 'NR>1 && $6 ~ /^[0-9]+$/ {s+=$6} END {print s+0}'
            return 0
        fi
    done
    echo ""
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

truncate_trigger_audit() {
    for t in "${ENTITIES[@]}"; do
        main_psql "TRUNCATE TABLE ${t}_trigger_audit;" >/dev/null
    done
    echo "  trigger audit tables truncated"
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

wait_for_sse_bridge() {
    log "waiting for sse-bridge"
    for i in $(seq 1 60); do
        # 401 = up but no key; anything but 000 means the port answers.
        code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/stream/company || true)
        [ "$code" != "000" ] && [ "$code" != "" ] && { echo "  sse-bridge up ($code)"; return 0; }
        sleep 3
    done
    echo "  sse-bridge did not come up" >&2; return 1
}

seed_bench_api_key() {
    # The seeded sample_api_key_123 only has company+person; the probe needs all six.
    audit_psql "INSERT INTO user_api_account (api_key, access, last_updated, date_created)
                SELECT '$BENCH_API_KEY', '{\"company\": true, \"person\": true, \"legal_entity\": true, \"member\": true, \"company_stocks\": true, \"company_capital\": true}', now(), now()
                WHERE NOT EXISTS (SELECT 1 FROM user_api_account WHERE api_key = '$BENCH_API_KEY');" >/dev/null
    echo "  bench API key seeded"
}

compose_net() { docker inspect mainDb -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}'; }

start_sse_probe() { # $1 = result dir, $2 = scenario label
    local rdir="$1" sc="$2" net
    net=$(compose_net)
    docker rm -f sse-probe >/dev/null 2>&1 || true
    docker run -d --name sse-probe --network "$net" --user "$(id -u):$(id -g)" \
        -e SSE_URL=http://sse-bridge:8080 -e API_KEY="$BENCH_API_KEY" -e OUT_DIR=/out -e SCENARIO="$sc" \
        -v "$REPO_ROOT/benchmark":/b -v "$rdir":/out \
        "$PROBE_IMAGE" python /b/sse_probe.py >/dev/null
    sleep 3
    echo "  sse-probe started"
}

stop_sse_probe() {
    # SIGTERM → the probe writes sse_lag.csv on exit; give it up to 20 s.
    if docker ps -q -f name='^sse-probe$' | grep -q .; then
        docker stop -t 20 sse-probe >/dev/null 2>&1 || true
        docker logs sse-probe 2>&1 | tail -n 3 | sed 's/^/  /' || true
        docker rm -f sse-probe >/dev/null 2>&1 || true
    fi
}

run_k6() { # $1 = result dir
    local rdir="$1"
    local net
    net=$(compose_net)
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

# ── fault injection (cdc-failover) ──────────────────────────────────────────
# Timeline relative to the k6 start. Each event is appended to <rdir>/faults.log
# with a timestamp so the lag samples can be correlated with the outage windows.
fault_schedule() { # $1 = result dir
    local flog="$1/faults.log" t0 now
    t0=$(date +%s)
    : > "$flog"
    sleep_until() { # $1 = seconds after t0
        now=$(date +%s); local d=$(( t0 + $1 - now )); [ "$d" -gt 0 ] && sleep "$d"; return 0
    }
    if [ "$FAULT_CONSUMER_AT" -ge 0 ]; then
        sleep_until "$FAULT_CONSUMER_AT"
        echo "$(ts) +$(( $(date +%s) - t0 ))s KILL audit-consumer (SIGKILL — crash, no shutdown hook)" | tee -a "$flog"
        docker kill --signal=SIGKILL audit-consumer >/dev/null 2>&1 || true
        sleep 5
        # restart: unless-stopped may bring it back on its own — record what actually happened
        echo "$(ts) +$(( $(date +%s) - t0 ))s audit-consumer state: $(docker inspect -f '{{.State.Status}} (restarts={{.RestartCount}})' audit-consumer 2>/dev/null)" | tee -a "$flog"
        sleep_until $(( FAULT_CONSUMER_AT + FAULT_CONSUMER_DOWN_S ))
        echo "$(ts) +$(( $(date +%s) - t0 ))s START audit-consumer" | tee -a "$flog"
        docker start audit-consumer >/dev/null 2>&1 || true
    fi
    if [ "$FAULT_BROKER_AT" -ge 0 ]; then
        sleep_until "$FAULT_BROKER_AT"
        echo "$(ts) +$(( $(date +%s) - t0 ))s KILL $FAULT_BROKER (SIGKILL — broker crash)" | tee -a "$flog"
        docker kill --signal=SIGKILL "$FAULT_BROKER" >/dev/null 2>&1 || true
        sleep_until $(( FAULT_BROKER_AT + FAULT_BROKER_DOWN_S ))
        echo "$(ts) +$(( $(date +%s) - t0 ))s START $FAULT_BROKER" | tee -a "$flog"
        docker start "$FAULT_BROKER" >/dev/null 2>&1 || true
    fi
    echo "$(ts) +$(( $(date +%s) - t0 ))s fault schedule complete" | tee -a "$flog"
}

heal_faults() {
    # Whatever happened, leave every container running before draining/collecting.
    docker start audit-consumer >/dev/null 2>&1 || true
    docker start "$FAULT_BROKER" >/dev/null 2>&1 || true
    sleep 10
}

run_scenario() { # $1 = scenario, $2 = result dir
    local sc="$1"
    local rdir="$2"
    rm -rf "$rdir"; mkdir -p "$rdir"

    log "SCENARIO: $sc — resetting stack"
    $DC down -v --remove-orphans >/dev/null 2>&1 || true
    docker rm -f sse-probe >/dev/null 2>&1 || true

    local probe=0
    case "$sc" in
        cdc|cdc-failover)
            # audit-consumer is started LATER (after the connector creates the topics) —
            # a pattern-subscribed consumer that starts before its topics exist gets an
            # empty partition assignment and won't pick them up until metadata refresh.
            # snapshot.mode=initial (default) so Debezium pre-creates all topics — a
            # pattern-subscribed consumer started afterwards then gets a real partition
            # assignment. The seed-snapshot rows are drained then TRUNCATED below, so the
            # measured cdc volume/lag reflects only the post-truncate k6 workload.
            BR_API_PROFILES=prod $DC up -d --no-build \
                mainDb auditDb kafka-1 kafka-2 kafka-3 debezium debezium-setup business-registry-api
            [ "$SSE_PROBE" = "1" ] && probe=1
            ;;
        cdc-idle)
            # Whole CDC stack, but NO debezium-setup → no connector, no slot, no decoding.
            BR_API_PROFILES=prod $DC up -d --no-build \
                mainDb auditDb kafka-1 kafka-2 kafka-3 debezium business-registry-api audit-consumer
            ;;
        cdc-slot)
            # Connector streams into Kafka; nobody consumes, no audit DB.
            BR_API_PROFILES=prod $DC up -d --no-build \
                mainDb kafka-1 kafka-2 kafka-3 debezium debezium-setup business-registry-api
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
        triggers)     set_triggers ENABLE ;;
        cdc-failover) set_triggers ENABLE ;;   # ground truth for the integrity check
        *)            set_triggers DISABLE ;;
    esac
    wait_for_api

    case "$sc" in
        cdc|cdc-failover)
            wait_for_cdc
            log "starting audit-consumer (topics now exist)"
            BR_API_PROFILES=prod $DC up -d --no-build audit-consumer >/dev/null 2>&1
            wait_consumer_idle 90    # let it consume the initial snapshot
            truncate_cdc_audit       # drop snapshot rows so volume = k6 workload only
            [ "$sc" = "cdc-failover" ] && truncate_trigger_audit
            if [ "$probe" = "1" ]; then
                log "starting sse-bridge + SSE latency probe"
                $DC up -d --no-build sse-bridge >/dev/null 2>&1
                wait_for_sse_bridge
                seed_bench_api_key
                start_sse_probe "$rdir" "$sc"
            fi
            ;;
        cdc-slot)
            wait_for_cdc ;;
    esac

    if [ "$sc" = "cdc-failover" ]; then
        log "k6 + fault injection (consumer kill at +${FAULT_CONSUMER_AT}s for ${FAULT_CONSUMER_DOWN_S}s, $FAULT_BROKER stop at +${FAULT_BROKER_AT}s for ${FAULT_BROKER_DOWN_S}s)"
        fault_schedule "$rdir" &
        local fpid=$!
        run_k6 "$rdir"
        wait "$fpid" || true
        heal_faults
    else
        run_k6 "$rdir"
    fi

    case "$sc" in
        cdc|cdc-failover)
            log "draining async CDC pipeline (lag→0, max ${CDC_DRAIN_S}s)"
            wait_consumer_idle "$CDC_DRAIN_S"
            [ "$probe" = "1" ] && stop_sse_probe
            ;;
    esac

    log "collecting metrics for $sc"
    "$REPO_ROOT/benchmark/collect.sh" "$sc" "$rdir"
}

run_matrix() { # $1 = results dir for this VU level
    local rd="$1"
    if [ "$REPEATS" -le 1 ]; then
        for sc in $SCENARIOS; do
            run_scenario "$sc" "$rd/$sc"
        done
    else
        # Round-robin (run 1 of every scenario, then run 2, ...) so slow drift of the
        # host (thermal, caches, other load) spreads evenly across the scenarios.
        for sc in $SCENARIOS; do rm -rf "$rd/$sc"; done
        for k in $(seq 1 "$REPEATS"); do
            for sc in $SCENARIOS; do
                log "REPEAT $k/$REPEATS"
                run_scenario "$sc" "$rd/$sc/run-$k"
            done
        done
    fi
}

# ── build all required images once up front ─────────────────────────────────
log "building images"
$DC build business-registry-api audit-consumer sse-bridge
docker pull -q "$PROBE_IMAGE" >/dev/null 2>&1 || true

PY="$(command -v python3 || command -v python || true)"
summarise() { # $1 = results dir
    if [ -n "$PY" ]; then
        "$PY" "$REPO_ROOT/benchmark/summarize.py" "$1" || \
            echo "  (summarize.py failed — raw CSV/JSON still in $1)"
    else
        echo "  (no python found — run: python3 benchmark/summarize.py $1)"
    fi
}

if [ -n "$VU_LEVELS" ]; then
    for lvl in $VU_LEVELS; do
        VUS="$lvl"
        log "VU LEVEL: $VUS"
        run_matrix "$RESULTS_DIR/vus-$lvl"
    done
else
    run_matrix "$RESULTS_DIR"
fi

log "tearing down"
$DC down -v --remove-orphans >/dev/null 2>&1 || true
docker rm -f sse-probe >/dev/null 2>&1 || true

log "summarising"
if [ -n "$VU_LEVELS" ]; then
    for lvl in $VU_LEVELS; do summarise "$RESULTS_DIR/vus-$lvl"; done
    summarise "$RESULTS_DIR"      # writes comparison-by-vus.md across the levels
else
    summarise "$RESULTS_DIR"
fi

log "DONE — results in $RESULTS_DIR"
