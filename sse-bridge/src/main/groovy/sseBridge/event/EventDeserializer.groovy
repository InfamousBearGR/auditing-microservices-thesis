package sseBridge.event


import org.apache.kafka.common.serialization.Deserializer
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class EventDeserializer implements Deserializer<EventBaseModel> {
    private static final Logger log = LoggerFactory.getLogger(EventDeserializer.class)

    @Override
    void configure(Map<String, ?> configs, boolean isKey) {
        // No config needed
    }

    @Override
    EventBaseModel deserialize(String topic, byte[] data) {
        if (data == null) {
            return null // Handle Kafka tombstone records gracefully
        }
        try {
            return EventFactory.getEvent(data)
        } catch (Exception e) {
            // Log the error and return null (or a specific ErrorEvent) to prevent consumer crash
            log.error("Failed to deserialize event from topic " + topic + ": " + e.getMessage())
            return null
        }
    }

    @Override
    void close() {
        // No resources to close
    }
}
