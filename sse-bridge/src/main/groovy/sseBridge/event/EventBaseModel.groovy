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

    String changedAt

    Long changeId

    String sourceTopic

    String changeReason

    @JsonGetter("changedAt")
    String getChangedAt() {
        return changedAt
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
                // Ignore unknown operation types
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

    @JsonSetter("ts_ms")
    void setChangedAt(long ts_ms) {
        this.changedAt = Instant.ofEpochMilli(ts_ms).toString()
    }

    @JsonSetter("source")
    void setChangeId(JsonNode source) {
        this.changeId = source.has("lsn") ? source.get("lsn").asLong() : null
    }
}
