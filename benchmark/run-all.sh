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
# Overhead-decomposition controls (see thesis §5.3 / §5.6):
#   cdc-idle     — the whole CDC stack is RUNNING but NO connector is registered:
#                  no replication slot, no logical decoding, no events. Measures the
#                  pure resource-contention cost of the extra processes on one host.
#   cdc-slot     — connector registered and streaming into Kafka, but NO audit
#                  consumer and NO audit DB. Adds the cost of logical decoding +
#                  Debezium + Kafka traffic on top of cdc-idle.
#   cdc-failover — the cdc pipeline with FAULT INJECTION during the workload
#                  (audit-consumer SIGKILLed, then a Kafka broker SIGKILLed) and the
#                  DB triggers enabled in parallel as ground truth, so that lost /
#                  duplicated events can be counted exactly (integrity.csv). Runs
#                  at a FIXED arrival rate (FAILOVER_RATE) so the workload lasts
#                  long enough to cover the fault schedule.
#   history      — History API: streams HISTORY_ROWS synthetic audit rows as JSON
#                  and as Parquet, recording time, size and the service's peak
#                  memory (history.csv); also checks both API-key headers.
#
# Every scenario starts from a clean stack (down -v): mainDb comes up first, is
# bulk-seeded (benchmark/sql/seed.sql, BENCH_SEED_ROWS rows per core entity) with
# every audit method still off, and only then are the scenario's services started.
#
# Env knobs:
#   SMOKE       default 0    1 = quick correctness run: every scenario ONCE with a
#                            small load into benchmark/results-smoke, then
#                            smoke_check.py verifies every output (exit code ≠ 0
#                            on failure). Any knob below still overrides.
#   SCENARIOS   default "baseline cdc triggers envers"
#   VUS         default 10
#   VU_LEVELS   default ""   (e.g. "8 64": run the whole scenario set once per
#                             VU level into results/vus-<n>/ and write
#                             comparison-by-vus.md; overrides VUS)
#   TOTAL_OPS   default 2000 (iterations = mutation attempts per run)
#   RATE        default ""   ops/s; empty = closed model (VUS loop flat out);
#                            set = open model (constant arrival rate, TOTAL_OPS/RATE s)
#   FAILOVER_RATE default 50 ops/s used by cdc-failover when RATE is empty
#   BENCH_SEED_ROWS default 2000  extra companies / persons / legal entities
#   PARTITION_IDS default 1  1 = each VU updates/deletes only its own ids (load.js)
#   LOGIN_EVERY_ITERATION default 0  1 = legacy load model (login before every op)
#   K6_IMAGE    default grafana/k6
#   CDC_DRAIN_S default 20   (seconds to let the async consumer catch up)
#   REPEATS     default 1    (>1: run every scenario N times, round-robin, into
#                             results/<scenario>/run-<k>/; summarize.py then
#                             reports the median across runs + the spread + tests)
#   RESULTS_DIR default benchmark/results (override to write a variant run
#                             elsewhere without wiping the main results)
#   COMPRESS_SEGMENTBY default "" = no segmentby (cdc compressed-size
#                             measurement in collect.sh)
#   SSE_PROBE   default 1    (cdc / cdc-failover: also start sse-bridge and the
#                             SSE latency probe → <scenario>/sse_lag.csv)
#   PROBE_IMAGE default python:3.12-alpine
#   HISTORY_ROWS default 500000 (history scenario)
#   Fault injection (cdc-failover only), seconds relative to the k6 start:
#   FAULT_CONSUMER_AT default 60   FAULT_CONSUMER_DOWN_S default 20
#   FAULT_BROKER_AT   default 120  FAULT_BROKER_DOWN_S   default 30
#   FAULT_BROKER      default kafka-1 | coordinator (the SSE bridge's group
#                             coordinator) | controller (the active KRaft controller)
#
# Run from anywhere: ./benchmark/run-all.sh
# ============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

SMOKE="${SMOKE:-0}"
if [ "$SMOKE" = "1" ]; then
    # Small, fast settings: every scenario once, just enough load to exercise every
    # code path (≈ 25–35 min in total, mostly container start-up).
    : "${SCENARIOS:=baseline cdc cdc-idle cdc-slot triggers envers cdc-failover history}"
    : "${REPEATS:=1}"
    : "${VUS:=8}"
    : "${TOTAL_OPS:=600}"
    : "${CDC_DRAIN_S:=90}"
    : "${BENCH_SEED_ROWS:=300}"
    : "${HISTORY_ROWS:=20000}"
    : "${FAILOVER_RATE:=10}"          # 600 ops at 10/s → 60 s of load
    : "${FAULT_CONSUMER_AT:=10}"
    : "${FAULT_CONSUMER_DOWN_S:=10}"
    : "${FAULT_BROKER_AT:=25}"
    : "${FAULT_BROKER_DOWN_S:=20}"
    : "${RESULTS_DIR:=$REPO_ROOT/benchmark/results-smoke}"
fi

SCENARIOS="${SCENARIOS:-baseline cdc triggers envers}"
VUS="${VUS:-10}"
VU_LEVELS="${VU_LEVELS:-}"
TOTAL_OPS="${TOTAL_OPS:-2000}"
RATE="${RATE:-}"
FAILOVER_RATE="${FAILOVER_RATE:-50}"
BENCH_SEED_ROWS="${BENCH_SEED_ROWS:-2000}"
PARTITION_IDS="${PARTITION_IDS:-1}"
LOGIN_EVERY_ITERATION="${LOGIN_EVERY_ITERATION:-0}"
K6_IMAGE="${K6_IMAGE:-grafana/k6}"
CDC_DRAIN_S="${CDC_DRAIN_S:-20}"
REPEATS="${REPEATS:-1}"
RESULTS_DIR="${RESULTS_DIR:-$REPO_ROOT/benchmark/results}"
SSE_PROBE="${SSE_PROBE:-1}"
PROBE_IMAGE="${PROBE_IMAGE:-python:3.12-alpine}"
HISTORY_ROWS="${HISTORY_ROWS:-500000}"
FAULT_CONSUMER_AT="${FAULT_CONSUMER_AT:-60}"
FAULT_CONSUMER_DOWN_S="${FAULT_CONSUMER_DOWN_S:-20}"
FAULT_BROKER_AT="${FAULT_BROKER_AT:-120}"
FAULT_BROKER_DOWN_S="${FAULT_BROKER_DOWN_S:-30}"
FAULT_BROKER="${FAULT_BROKER:-kafka-1}"
FAULT_BROKER_NAME="$FAULT_BROKER"   # resolved per failover run (coordinator / controller)
ENTITIES=(company person legal_entity member company_stocks company_capital)
BENCH_API_KEY="bench_api_key"

DC="docker compose"
log() { printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }
warn() { printf '\033[1;33m  WARN: %s\033[0m\n' "$*" >&2; }
ts() { date '+%Y-%m-%dT%H:%M:%S%z'; }

main_psql() { docker exec -i mainDb psql -U admin -d mainDb -tAc "$1"; }
audit_psql() { docker exec -i timescaledb psql -U admin -d auditdb -tAc "$1"; }

wait_for_cdc() {
    # Debezium Connect REST + connector registration + replication-slot creation
    # must complete before k6, or the workload's WAL changes predate the slot and
    # are never captured. Poll the connector to RUNNING.
    log "waiting for Debezium connector 'audit-connector' RUNNING"
    for i in $(seq 1 80); do
        st=$(curl -s http://localhost:8083/connectors/audit-connector/status 2>/dev/null || true)
        if echo "$st" | grep -q '"state":"FAILED"'; then
            echo "  connector/task FAILED:"; echo "$st" >&2; return 1
        fi
        if echo "$st" | grep -q '"state":"RUNNING"'; then echo "  connector running"; sleep 8; return 0; fi
        sleep 3
    done
    echo "  connector not RUNNING in time" >&2; return 1
}

# Any broker that is up can answer admin queries (one may be down in cdc-failover).
kafka_admin() { # $@ = command line after /opt/kafka/bin/
    local b
    for b in kafka-1 kafka-2 kafka-3; do
        if out=$(docker exec "$b" /opt/kafka/bin/"$@" 2>/dev/null); then
            echo "$out"; return 0
        fi
    done
    return 1
}

consumer_total_lag() {
    local out
    if out=$(kafka_admin kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group audit_consumer_group); then
        echo "$out" | awk 'NR>1 && $6 ~ /^[0-9]+$/ {s+=$6} END {print s+0}'
    else
        echo ""
    fi
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
    for i in $(seq 1 80); do
        code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8084/api/auth/status || true)
        [ "$code" = "200" ] && { echo "  api up"; return 0; }
        sleep 3
    done
    echo "  api did not become healthy" >&2; return 1
}

# The postgres image first runs the init scripts on a TEMPORARY server that listens
# only on the Unix socket, then restarts the real one. pg_isready over the socket says
# "ready" during that phase (and a query sent then is killed by the restart), so probe
# over TCP — only the final server listens there.
wait_for_db() {
    log "waiting for mainDb"
    for i in $(seq 1 60); do
        docker exec mainDb pg_isready -h 127.0.0.1 -U admin -d mainDb >/dev/null 2>&1 && { sleep 1; echo "  db up"; return 0; }
        sleep 2
    done
    echo "  mainDb not ready" >&2; return 1
}

wait_for_auditdb() {
    log "waiting for auditDb"
    for i in $(seq 1 60); do
        if docker exec timescaledb pg_isready -h 127.0.0.1 -U admin -d auditdb >/dev/null 2>&1 \
           && [ "$(audit_psql "SELECT 1 FROM pg_tables WHERE tablename='user_api_account';" 2>/dev/null)" = "1" ]; then
            sleep 1; echo "  auditDb up"; return 0
        fi
        sleep 2
    done
    echo "  auditDb not ready" >&2; return 1
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

seed_source_db() { # $1 = result dir — bulk seed + export the id lists for load.js
    local rdir="$1"
    log "seeding mainDb: +$BENCH_SEED_ROWS companies / persons / legal entities"
    if [ "$BENCH_SEED_ROWS" -gt 0 ]; then
        docker exec -i mainDb psql -U admin -d mainDb -q -v ON_ERROR_STOP=1 -v rows="$BENCH_SEED_ROWS" \
            < "$REPO_ROOT/benchmark/sql/seed.sql" >/dev/null
    fi
    main_psql "SELECT json_build_object(
                 'companies',     (SELECT coalesce(json_agg(id ORDER BY id), '[]') FROM company),
                 'persons',       (SELECT coalesce(json_agg(id ORDER BY id), '[]') FROM person),
                 'legalEntities', (SELECT coalesce(json_agg(id ORDER BY id), '[]') FROM legal_entity));" \
        > "$rdir/seed_ids.json"
    echo "  $(main_psql "SELECT count(*) FROM company") companies, $(main_psql "SELECT count(*) FROM person") persons, $(main_psql "SELECT count(*) FROM legal_entity") legal entities"
}

compose_net() { docker inspect mainDb -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null \
                || docker inspect timescaledb -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}'; }

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

run_k6() { # $1 = result dir, $2 = arrival rate ("" = closed model)
    local rdir="$1" rate="${2:-}"
    local net
    net=$(compose_net)
    mkdir -p "$rdir"
    if [ -n "$rate" ]; then
        log "k6: $TOTAL_OPS ops at ${rate}/s (open model, ≤$VUS VUs, net=$net)"
    else
        log "k6: $VUS VUs x $TOTAL_OPS ops (closed model, net=$net)"
    fi
    # Run k6 as the host user so it can write k6-summary.json into the mounted dir.
    docker run --rm --network "$net" --user "$(id -u):$(id -g)" \
        -e BASE_URL=http://business-registry-api:8084 \
        -e USERNAME=admin -e PASSWORD=testPassword \
        -e VUS="$VUS" -e TOTAL_OPS="$TOTAL_OPS" -e RATE="${rate:-0}" \
        -e PARTITION_IDS="$PARTITION_IDS" -e LOGIN_EVERY_ITERATION="$LOGIN_EVERY_ITERATION" \
        -e SEED_IDS_FILE=/out/seed_ids.json -e RESULT_FILE=/out/k6-summary.json \
        -v "$REPO_ROOT/benchmark":/b -v "$rdir":/out \
        "$K6_IMAGE" run /b/load.js
}

# Versions of everything that ran, for the thesis' reproducibility section.
write_versions() { # $1 = result dir
    local rdir="$1" f="$1/versions.txt"
    {
        echo "date: $(ts)"
        echo "host: $(uname -srm)"
        command -v lscpu >/dev/null && lscpu | grep -E '^(Model name|CPU\(s\)):' | sed 's/  */ /g'
        command -v free >/dev/null && free -g | awk '/^Mem:/ {print "memory_gb: " $2}'
        echo "docker: $(docker version --format '{{.Server.Version}}' 2>/dev/null)"
        echo "compose: $(docker compose version --short 2>/dev/null)"
        echo "-- images (repo:tag@id)"
        docker ps --format '{{.Names}} {{.Image}}' | while read -r name image; do
            echo "$name $image $(docker image inspect -f '{{.Id}}' "$image" 2>/dev/null | cut -c1-19)"
        done
        echo "k6: $(docker run --rm "$K6_IMAGE" version 2>/dev/null | head -1)"
        docker ps -q -f name='^mainDb$' | grep -q . && echo "mainDb: $(main_psql 'SHOW server_version;')"
        if docker ps -q -f name='^timescaledb$' | grep -q .; then
            echo "auditDb: $(audit_psql 'SHOW server_version;') timescaledb $(audit_psql "SELECT extversion FROM pg_extension WHERE extname='timescaledb';")"
        fi
        docker ps -q -f name='^debezium$' | grep -q . && echo "debezium-connect: $(curl -s http://localhost:8083/ 2>/dev/null)"
        docker ps -q -f name='^kafka-1$' | grep -q . && \
            echo "kafka: $(docker exec kafka-1 sh -c 'ls /opt/kafka/libs | grep -E "^kafka-clients-.*\.jar$"' 2>/dev/null)"
        echo "-- load model"
        echo "VUS=$VUS TOTAL_OPS=$TOTAL_OPS RATE=${RATE:-} FAILOVER_RATE=$FAILOVER_RATE BENCH_SEED_ROWS=$BENCH_SEED_ROWS PARTITION_IDS=$PARTITION_IDS LOGIN_EVERY_ITERATION=$LOGIN_EVERY_ITERATION"
    } > "$f" 2>/dev/null || true
}

# ── fault injection (cdc-failover) ──────────────────────────────────────────
record_cluster_state() { # $1 = output file
    {
        echo "# $(ts)"
        echo "## KRaft quorum"
        kafka_admin kafka-metadata-quorum.sh --bootstrap-server localhost:9092 describe --status || echo "(unavailable)"
        for g in audit_consumer_group sse-bridge-group; do
            echo "## consumer group $g (coordinator / state)"
            kafka_admin kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group "$g" --state || echo "(unavailable)"
        done
        echo "## partition leaders of the event topics"
        kafka_admin kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic 'server.public.(company|person|legal_entity|member|company_stocks|company_capital)' \
            || kafka_admin kafka-topics.sh --bootstrap-server localhost:9092 --describe | grep -E 'server\.public\.' || echo "(unavailable)"
    } > "$1" 2>&1 || true
}

resolve_fault_broker() {
    local name="" grp
    case "$FAULT_BROKER" in
        coordinator)
            grp="sse-bridge-group"; [ "$SSE_PROBE" = "1" ] || grp="audit_consumer_group"
            name=$(kafka_admin kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group "$grp" --state \
                   | awk 'NR>1 && $2 ~ /:/ {split($2, a, ":"); print a[1]; exit}') || true ;;
        controller)
            name=$(kafka_admin kafka-metadata-quorum.sh --bootstrap-server localhost:9092 describe --status \
                   | awk -F': *' '/^LeaderId/ {print "kafka-" $2; exit}') || true ;;
        *)
            name="$FAULT_BROKER" ;;
    esac
    case "$name" in
        kafka-1|kafka-2|kafka-3) echo "$name" ;;
        *) warn "could not resolve FAULT_BROKER=$FAULT_BROKER (got '$name'); using kafka-1"; echo "kafka-1" ;;
    esac
}

# Timeline relative to the k6 start. Each event is appended to <rdir>/faults.log
# with a timestamp so the lag samples can be correlated with the outage windows.
fault_schedule() { # $1 = result dir
    local flog="$1/faults.log" t0 now
    t0=$(date +%s)
    echo "$(ts) +0s k6 start (epoch_s=$t0); broker under test: $FAULT_BROKER_NAME (FAULT_BROKER=$FAULT_BROKER)" | tee -a "$flog"
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
        echo "$(ts) +$(( $(date +%s) - t0 ))s KILL $FAULT_BROKER_NAME (SIGKILL — broker crash)" | tee -a "$flog"
        docker kill --signal=SIGKILL "$FAULT_BROKER_NAME" >/dev/null 2>&1 || true
        sleep_until $(( FAULT_BROKER_AT + FAULT_BROKER_DOWN_S ))
        echo "$(ts) +$(( $(date +%s) - t0 ))s START $FAULT_BROKER_NAME" | tee -a "$flog"
        docker start "$FAULT_BROKER_NAME" >/dev/null 2>&1 || true
    fi
    echo "$(ts) +$(( $(date +%s) - t0 ))s fault schedule complete" | tee -a "$flog"
}

heal_faults() {
    # Whatever happened, leave every container running before draining/collecting.
    docker start audit-consumer >/dev/null 2>&1 || true
    docker start "$FAULT_BROKER_NAME" >/dev/null 2>&1 || true
    sleep 10
}

# ── history scenario ────────────────────────────────────────────────────────
history_container() { $DC ps -q history-api 2>/dev/null | head -1; }

wait_for_history_api() {
    for i in $(seq 1 60); do
        code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8081/swagger/index.html || true)
        [ "$code" = "200" ] && return 0
        sleep 1
    done
    echo "  history-api did not come up" >&2; return 1
}

history_rss_kb() { # VmHWM (peak RSS since process start) / VmRSS of PID 1 in the container
    docker exec "$(history_container)" sh -c "grep -E '^$1:' /proc/1/status" 2>/dev/null | awk '{print $2}'
}

run_history() { # $1 = result dir
    local rdir="$1" out="$1/history.csv" tmp
    tmp=$(mktemp -d)
    log "history: seeding $HISTORY_ROWS synthetic audit rows into company_audit"
    $DC up -d --no-build auditDb
    wait_for_auditdb
    seed_bench_api_key
    audit_psql "INSERT INTO company_audit (before, after, operation_type, changed_at, changed_by_user_id, parent_id,
                                           change_id, business_change_id, change_reason)
                SELECT b, b || jsonb_build_object('street_number', ((g + 1) % 300)::text), 'UPDATE',
                       timestamptz '2026-01-01 00:00:00+00' + g * interval '10 milliseconds', 1, (g % 5000) + 1,
                       g, g, 'history benchmark'
                FROM generate_series(1, $HISTORY_ROWS) AS g,
                     LATERAL (SELECT jsonb_build_object(
                         'name', 'Εταιρεία ' || g, 'afm', lpad((g % 1000000000)::text, 9, '0'),
                         'gemi_number', lpad(g::text, 12, '0'), 'city', 'Αθήνα', 'street', 'Λεωφόρος Συγγρού',
                         'street_number', (g % 300)::text, 'postal_code', '11745', 'country_id', 154,
                         'region_id', 9, 'prefecture_id', 5, 'municipality_id', 186, 'legal_type_id', 2,
                         'company_status_id', 3, 'date_incorporated', '2015-03-15') AS b) x;" >/dev/null
    audit_psql "ANALYZE company_audit;" >/dev/null
    local rows bytes_db
    rows=$(audit_psql "SELECT count(*) FROM company_audit;")
    bytes_db=$(audit_psql "SELECT hypertable_size('company_audit');")
    echo "  $rows rows, $(audit_psql "SELECT pg_size_pretty(hypertable_size('company_audit'));") in auditDb"

    $DC up -d --no-build history-api
    wait_for_history_api
    echo "scenario,request,http_code,rows,bytes,seconds,ttfb_seconds,rss_start_kb,rss_peak_kb,valid,db_rows,db_bytes" > "$out"

    local url="http://localhost:8081"
    local q_all="changeIdFrom=0&changeIdTo=9223372036854775807&topic=company"
    measure() { # $1=label $2=path?query $3=header $4=expected_code
        local label="$1" path="$2" header="$3" expect="$4" res code size secs ttfb rss0 rss1 valid=0 nrows=""
        docker restart "$(history_container)" >/dev/null; wait_for_history_api
        rss0=$(history_rss_kb VmRSS)
        if [ -n "$header" ]; then
            res=$(curl -s -o "$tmp/$label.out" -H "$header" -w '%{http_code} %{size_download} %{time_total} %{time_starttransfer}' "$url/$path")
        else
            res=$(curl -s -o "$tmp/$label.out" -w '%{http_code} %{size_download} %{time_total} %{time_starttransfer}' "$url/$path")
        fi
        read -r code size secs ttfb <<< "$res"
        rss1=$(history_rss_kb VmHWM)
        case "$label" in
            json_*)
                # grep exits 1 on zero matches — must not trip `set -o pipefail` for an empty result
                nrows=$( { grep -o '"change_id":' "$tmp/$label.out" || true; } | wc -l | tr -d ' ') ;;
            parquet_*)
                if [ "$(head -c 4 "$tmp/$label.out")" = "PAR1" ] && [ "$(tail -c 4 "$tmp/$label.out")" = "PAR1" ]; then nrows="parquet"; fi ;;
        esac
        if [ "$code" = "$expect" ]; then
            case "$label" in
                json_full)         if [ "$nrows" = "$rows" ]; then valid=1; fi ;;
                json_small)        if [ "$nrows" = "10" ]; then valid=1; fi ;;
                json_stocks_topic) if [ -n "$nrows" ]; then valid=1; fi ;;
                parquet_full)      if [ "$nrows" = "parquet" ]; then valid=1; fi ;;
                *)                 valid=1 ;;
            esac
        fi
        echo "history,$label,$code,${nrows:-},$size,$secs,$ttfb,${rss0:-},${rss1:-},$valid,$rows,$bytes_db" >> "$out"
        echo "  $label: HTTP $code, $size bytes, ${secs}s, peak RSS ${rss1:-?} kB (start ${rss0:-?} kB), valid=$valid"
    }
    measure json_full         "getHistoryByChangeIdRange?$q_all"        "X-API-Key: $BENCH_API_KEY"             200
    measure parquet_full      "exportHistoryByChangeIdRange?$q_all"     "Authorization: Bearer $BENCH_API_KEY"  200
    measure json_small        "getHistoryByChangeIdRange?changeIdFrom=1&changeIdTo=10&topic=company" "Authorization: Bearer $BENCH_API_KEY" 200
    measure json_stocks_topic "getHistoryByChangeIdRange?changeIdFrom=0&changeIdTo=10&topic=company_stocks" "X-API-Key: $BENCH_API_KEY" 200
    measure auth_missing      "getHistoryByChangeIdRange?changeIdFrom=1&changeIdTo=10&topic=company" "" 401
    rm -rf "$tmp"
    echo "  wrote $out"
}

run_scenario() { # $1 = scenario, $2 = result dir
    local sc="$1"
    local rdir="$2"
    rm -rf "$rdir"; mkdir -p "$rdir"

    log "SCENARIO: $sc — resetting stack"
    $DC down -v --remove-orphans >/dev/null 2>&1 || true
    docker rm -f sse-probe >/dev/null 2>&1 || true

    if [ "$sc" = "history" ]; then
        run_history "$rdir"
        write_versions "$rdir"
        return 0
    fi

    # 1. source DB alone: seed it while every audit method is still off.
    $DC up -d --no-build mainDb
    wait_for_db
    set_triggers DISABLE
    seed_source_db "$rdir"

    # 2. the scenario's services.
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
                auditDb kafka-1 kafka-2 kafka-3 debezium debezium-setup business-registry-api
            [ "$SSE_PROBE" = "1" ] && probe=1
            ;;
        cdc-idle)
            # Whole CDC stack, but NO debezium-setup → no connector, no slot, no decoding.
            BR_API_PROFILES=prod $DC up -d --no-build \
                auditDb kafka-1 kafka-2 kafka-3 debezium business-registry-api audit-consumer
            ;;
        cdc-slot)
            # Connector streams into Kafka; nobody consumes, no audit DB.
            BR_API_PROFILES=prod $DC up -d --no-build \
                kafka-1 kafka-2 kafka-3 debezium debezium-setup business-registry-api
            ;;
        envers)
            BR_API_PROFILES=prod,envers $DC up -d --no-build business-registry-api
            ;;
        baseline|triggers)
            BR_API_PROFILES=prod $DC up -d --no-build business-registry-api
            ;;
        *)
            echo "unknown scenario: $sc" >&2; return 1 ;;
    esac

    case "$sc" in
        triggers)     set_triggers ENABLE ;;
        cdc-failover) set_triggers ENABLE ;;   # ground truth for the integrity check
    esac
    wait_for_api

    case "$sc" in
        cdc|cdc-failover)
            wait_for_cdc
            log "starting audit-consumer (topics now exist)"
            BR_API_PROFILES=prod $DC up -d --no-build audit-consumer >/dev/null 2>&1
            wait_consumer_idle 120   # let it consume the initial snapshot (incl. the seed rows)
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

    write_versions "$rdir"

    if [ "$sc" = "cdc-failover" ]; then
        local frate="${RATE:-$FAILOVER_RATE}" dur fend
        dur=$(awk -v n="$TOTAL_OPS" -v r="$frate" 'BEGIN { d = n / r; printf "%d", (d == int(d)) ? d : int(d) + 1 }')
        fend=$(( FAULT_CONSUMER_AT + FAULT_CONSUMER_DOWN_S ))
        [ $(( FAULT_BROKER_AT + FAULT_BROKER_DOWN_S )) -gt "$fend" ] && fend=$(( FAULT_BROKER_AT + FAULT_BROKER_DOWN_S ))
        if [ "$fend" -ge "$dur" ]; then
            warn "fault schedule ends at +${fend}s but the workload lasts only ${dur}s (TOTAL_OPS=$TOTAL_OPS at ${frate}/s) — raise TOTAL_OPS or lower FAILOVER_RATE"
        fi
        record_cluster_state "$rdir/cluster_before.txt"
        FAULT_BROKER_NAME=$(resolve_fault_broker)
        log "k6 (${frate}/s for ${dur}s) + fault injection (consumer kill at +${FAULT_CONSUMER_AT}s for ${FAULT_CONSUMER_DOWN_S}s, $FAULT_BROKER_NAME kill at +${FAULT_BROKER_AT}s for ${FAULT_BROKER_DOWN_S}s)"
        : > "$rdir/faults.log"
        fault_schedule "$rdir" &
        local fpid=$!
        run_k6 "$rdir" "$frate"
        wait "$fpid" || true
        heal_faults
        record_cluster_state "$rdir/cluster_after.txt"
    else
        run_k6 "$rdir" "$RATE"
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

FAILED_SCENARIOS=""
# Run one scenario in a subshell with errexit ON inside it: a failing step aborts
# that scenario only — it is marked with a FAILED file (reported by smoke_check.py)
# and the run continues with the next scenario, the summary and the checks.
run_scenario_guarded() { # $1 = scenario, $2 = result dir
    local rc
    set +e
    ( set -e; run_scenario "$1" "$2" )
    rc=$?
    set -e
    if [ "$rc" -ne 0 ]; then
        warn "scenario $1 FAILED (exit $rc) — continuing; see the log above"
        mkdir -p "$2" && echo "exit $rc at $(ts)" > "$2/FAILED"
        FAILED_SCENARIOS="$FAILED_SCENARIOS $1"
        docker rm -f sse-probe >/dev/null 2>&1 || true
    fi
    return 0
}

run_matrix() { # $1 = results dir for this VU level
    local rd="$1"
    if [ "$REPEATS" -le 1 ]; then
        for sc in $SCENARIOS; do
            run_scenario_guarded "$sc" "$rd/$sc"
        done
    else
        # Round-robin (run 1 of every scenario, then run 2, ...) so slow drift of the
        # host (thermal, caches, other load) spreads evenly across the scenarios.
        for sc in $SCENARIOS; do rm -rf "$rd/$sc"; done
        for k in $(seq 1 "$REPEATS"); do
            for sc in $SCENARIOS; do
                log "REPEAT $k/$REPEATS"
                run_scenario_guarded "$sc" "$rd/$sc/run-$k"
            done
        done
    fi
}

# ── build all required images once up front ─────────────────────────────────
log "building images"
$DC build business-registry-api audit-consumer sse-bridge history-api
docker pull -q "$PROBE_IMAGE" >/dev/null 2>&1 || true
mkdir -p "$RESULTS_DIR"

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

[ -n "$FAILED_SCENARIOS" ] && warn "failed scenarios:$FAILED_SCENARIOS"
if [ -n "$PY" ]; then
    log "checking outputs (smoke_check.py)"
    if "$PY" "$REPO_ROOT/benchmark/smoke_check.py" "$RESULTS_DIR"; then
        log "DONE — all checks passed — results in $RESULTS_DIR"
        [ "$SMOKE" = "1" ] && [ -n "$FAILED_SCENARIOS" ] && exit 1
    else
        log "DONE WITH FAILED CHECKS — see above; results in $RESULTS_DIR"
        [ "$SMOKE" = "1" ] && exit 1
    fi
else
    log "DONE — results in $RESULTS_DIR"
fi
