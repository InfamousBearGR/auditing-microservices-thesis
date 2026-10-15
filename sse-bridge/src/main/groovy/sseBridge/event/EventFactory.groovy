package sseBridge.event

import com.fasterxml.jackson.databind.DeserializationFeature
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class EventFactory {
    private static final Logger log = LoggerFactory.getLogger(EventFactory.class)
    private static final ObjectMapper objectMapper = new ObjectMapper()
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)

    private EventFactory() {
        // Private constructor to prevent instantiation
    }

    static EventBaseModel getEvent(byte[] data) throws IOException {
        JsonNode node = objectMapper.readTree(data)
        if (log.isDebugEnabled()) {
            // DEBUG only: logging every full event at INFO costs I/O + CPU on the hot path
            log.debug("Raw JSON node: {}", node.toString())
        }
        if (node.has("payload")) {
            node = node.get("payload")
        }
        EventBaseModel event = objectMapper.treeToValue(node, EventBaseModel.class)

        if (event == null || event.eventType == null) {
            return null
        }

        return event
    }
}
