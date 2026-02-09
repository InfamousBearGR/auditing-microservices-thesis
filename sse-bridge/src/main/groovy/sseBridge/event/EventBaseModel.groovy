package sseBridge.event

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonSetter
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.node.ObjectNode
import groovy.transform.ToString

@ToString(includeNames = true)
@JsonIgnoreProperties(ignoreUnknown = true)
class EventBaseModel implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L

    JsonNode before

    JsonNode after

    EventType eventType

    long timestamp

    long changed_at
    
    String sourceTopic

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
            ((ObjectNode) before).remove("last_user_id")
        }
        this.before = before
    }

    @JsonSetter("after")
    void setAfter(JsonNode after) {
        if (after instanceof ObjectNode) {
            ((ObjectNode) after).remove("last_user_id")
        }
        this.after = after
    }

    @JsonSetter("ts_ms")
    void setChangedAt(long ts_ms) {
        this.changed_at = ts_ms
    }
}
