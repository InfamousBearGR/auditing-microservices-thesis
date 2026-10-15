package sseBridge.event

import com.fasterxml.jackson.annotation.JsonGetter
import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonSetter
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.node.ObjectNode
import groovy.transform.ToString

import java.time.Instant

@ToString(includeNames = true)
@JsonIgnoreProperties(ignoreUnknown = true)
class EventBaseModel implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L

    JsonNode before

    JsonNode after

    EventType eventType

    long timestamp

    /**
     * When the change was COMMITTED in the source database: Debezium's
     * payload.source.ts_ms. This is the same instant the audit consumer stores
     * as changed_at, so SSE and audit-store latencies share one reference point.
     */
    String changedAt

    /**
     * When Debezium processed the change: the envelope's payload.ts_ms
     * (commit → capturedAt = WAL decoding + Debezium queueing).
     */
    String capturedAt

    Long changeId

    String sourceTopic

    String changeReason

    @JsonGetter("changedAt")
    String getChangedAt() {
        return changedAt
    }

    @JsonGetter("capturedAt")
    String getCapturedAt() {
        return capturedAt
    }

    @JsonGetter("changeId")
    Long getChangeId() {
        return changeId
    }

    @JsonSetter("op")
    void setOp(String op) {
        switch (op) {
            case "c":
                this.eventType = EventType.INSERT
                break
            case "u":
                this.eventType = EventType.UPDATE
                break
            case "d":
                this.eventType = EventType.DELETE
                break
            default:
                // Ignore unknown operation types (e.g. "r" = snapshot read)
                break
        }
    }

    @JsonSetter("before")
    void setBefore(JsonNode before) {
        if (before instanceof ObjectNode) {
            this.changeReason = before.has("change_reason") ? before.get("change_reason").asText() : null
            ((ObjectNode) before).remove("last_user_id")
            ((ObjectNode) before).remove("id")
            ((ObjectNode) before).remove("change_reason")
        }
        this.before = before
    }

    @JsonSetter("after")
    void setAfter(JsonNode after) {
        if (after instanceof ObjectNode) {
            this.changeReason = after.has("change_reason") ? after.get("change_reason").asText() : null
            ((ObjectNode) after).remove("last_user_id")
            ((ObjectNode) after).remove("id")
            ((ObjectNode) after).remove("change_reason")
        }
        this.after = after
    }

    /** Envelope payload.ts_ms — when Debezium processed the event (NOT the commit time). */
    @JsonSetter("ts_ms")
    void setCapturedAtMillis(long tsMs) {
        this.capturedAt = Instant.ofEpochMilli(tsMs).toString()
    }

    /** payload.source: LSN → changeId, source.ts_ms (commit time) → changedAt. */
    @JsonSetter("source")
    void setSource(JsonNode source) {
        if (source == null || source.isNull()) {
            return
        }
        this.changeId = source.has("lsn") && !source.get("lsn").isNull() ? source.get("lsn").asLong() : null
        if (source.has("ts_ms") && !source.get("ts_ms").isNull()) {
            this.changedAt = Instant.ofEpochMilli(source.get("ts_ms").asLong()).toString()
        }
    }
}
