package sseBridge.config

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import io.r2dbc.postgresql.codec.Json
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.convert.converter.Converter
import org.springframework.data.convert.ReadingConverter
import org.springframework.data.convert.WritingConverter
import org.springframework.data.r2dbc.convert.R2dbcCustomConversions
import org.springframework.data.r2dbc.dialect.PostgresDialect

@Configuration
class R2dbcConfiguration {

    private final ObjectMapper objectMapper = new ObjectMapper()

    @Bean
    R2dbcCustomConversions r2dbcCustomConversions() {
        List<Converter<?, ?>> converters = [
            new JsonToJsonNodeConverter(objectMapper),
            new JsonNodeToJsonConverter(objectMapper)
        ]
        return R2dbcCustomConversions.of(PostgresDialect.INSTANCE, converters)
    }

    @ReadingConverter
    static class JsonToJsonNodeConverter implements Converter<Json, JsonNode> {

        private final ObjectMapper objectMapper

        JsonToJsonNodeConverter(ObjectMapper objectMapper) {
            this.objectMapper = objectMapper
        }

        @Override
        JsonNode convert(Json json) {
            try {
                return objectMapper.readTree(json.asArray())
            } catch (Exception e) {
                throw new RuntimeException("Failed to convert Json to JsonNode", e)
            }
        }
    }

    @WritingConverter
    static class JsonNodeToJsonConverter implements Converter<JsonNode, Json> {

        private final ObjectMapper objectMapper

        JsonNodeToJsonConverter(ObjectMapper objectMapper) {
            this.objectMapper = objectMapper
        }

        @Override
        Json convert(JsonNode jsonNode) {
            try {
                return Json.of(objectMapper.writeValueAsString(jsonNode))
            } catch (Exception e) {
                throw new RuntimeException("Failed to convert JsonNode to Json", e)
            }
        }
    }
}
