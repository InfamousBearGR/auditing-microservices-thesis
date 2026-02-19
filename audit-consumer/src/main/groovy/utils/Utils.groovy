package utils

import auditConsumer.AuditConsumer
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.node.ObjectNode
import groovy.util.logging.Slf4j

@Slf4j
class Utils {
    private static final Properties properties = new Properties()
    private static final ObjectMapper objectMapper = new ObjectMapper()

    static String getEnv(String key, String defaultValue) {
        System.getenv(key) ?: defaultValue
    }

    static JsonNode removeItemFromJsonNode(JsonNode node, String fieldName) {
        if (node != null && node.has(fieldName) && node instanceof ObjectNode) {
            ((ObjectNode) node).remove(fieldName)
            return node
        }
        return node
    }

    static String getStringFromJsonNode(JsonNode node, String fieldName) {
        if (node != null && node.has(fieldName) && !node.get(fieldName).isNull()) {
            return node.get(fieldName).asText()
        }
        return null
    }

    static Long getLongFromJsonNode(JsonNode node, String fieldName) {
        if (node != null && node.has(fieldName) && !node.get(fieldName).isNull()) {
            return node.get(fieldName).asLong()
        }
        return null
    }

    static String jsonNodeToString(JsonNode node) {
        if (node == null || node.isNull()) {
            return null
        } else {
            objectMapper.writeValueAsString(node)
        }
    }

    static JsonNode stringToJsonNode(String jsonString) {
        if (jsonString == null || jsonString.isEmpty()) {
            return null
        } else {
            objectMapper.readTree(jsonString)
        }
    }

    static Properties getProperties() {
        try {
            String envProfile = getEnv('GROOVY_PROFILES_ACTIVE', 'dev')
            String applicationFile
            switch (envProfile) {
                case 'dev':
                    log.info("Loading application-dev.properties")
                    applicationFile = "application-dev.properties"
                    break
                case 'prod':
                    log.info("Loading application-prod.properties")
                    applicationFile = "application-prod.properties"
                    break
                default:
                    log.warn("Unknown environment profile: ${getEnv('GROOVY_PROFILES_ACTIVE', 'dev')}, defaulting to dev")
                    applicationFile = "application-dev.properties"
            }
            InputStream input = AuditConsumer.class.getClassLoader().getResourceAsStream(applicationFile)
            if (input != null) {
                properties.load(input)
            } else {
                log.warn("application.properties not found, using defaults or environment variables")
            }
        } catch (IOException ex) {
            log.error("Error loading application.properties", ex)
        }
        return properties
    }
}
