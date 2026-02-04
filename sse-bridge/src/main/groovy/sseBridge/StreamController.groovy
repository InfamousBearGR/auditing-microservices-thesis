package sseBridge

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import reactor.core.publisher.Flux

@RestController
class StreamController {

    private static final Logger logger = LoggerFactory.getLogger(StreamController.class)

    private final KafkaStreamBridge kafkaStreamBridge

    StreamController(KafkaStreamBridge kafkaStreamBridge) {
        this.kafkaStreamBridge = kafkaStreamBridge
    }

    @GetMapping(path = "/stream", produces = "text/event-stream")
    Flux<String> streamChanges() {
        logger.info("New SSE client connected")

        return kafkaStreamBridge.getFlux()
                .map { value ->
                    logger.debug("Processing value from sink (length={})", value.length())
                    // Remove any existing "data:" prefix, trim ALL whitespace (including \n)
                    def cleanValue = value.trim()
                    if (cleanValue.startsWith("data:")) {
                        cleanValue = cleanValue.substring(5).trim()
                    }
                    logger.debug("After cleaning (length={}): {}", cleanValue.length(), cleanValue)
                    // Only format if there's actual content
                    if (!cleanValue.isEmpty()) {
                        return "data: " + cleanValue + "\n\n"
                    } else {
                        return ""
                    }
                }
                .filter { s -> !s.isEmpty() }
                .doOnNext { s -> logger.debug("Emitting data to SSE (length={})", s.length()) }
                .doOnSubscribe { subscription -> logger.info("SSE subscription started") }
                .doOnCancel { -> logger.info("SSE client disconnected") }
                .doOnError { e -> logger.error("SSE stream error: {}", e.getMessage(), e) }
    }
}
