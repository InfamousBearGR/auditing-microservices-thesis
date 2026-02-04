package sseBridge

import jakarta.annotation.PostConstruct
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import reactor.core.publisher.Flux
import reactor.core.publisher.Sinks
import reactor.kafka.receiver.KafkaReceiver
import reactor.kafka.receiver.ReceiverOptions

@Component
class KafkaStreamBridge {

    private static final Logger logger = LoggerFactory.getLogger(KafkaStreamBridge.class)

    private final ReceiverOptions<String, String> receiverOptions
    private final Sinks.Many<String> sink

    KafkaStreamBridge(ReceiverOptions<String, String> receiverOptions) {
        this.receiverOptions = receiverOptions
        this.sink = Sinks.many().multicast().onBackpressureBuffer()
    }

    @PostConstruct
    void startConsuming() {
        logger.info("Starting Kafka consumer...")
        KafkaReceiver.create(receiverOptions)
                .receive()
                .doOnSubscribe { subscription -> logger.info("Kafka receiver subscribed") }
                .doOnNext { record ->
                    def rawValue = record.value()
                    logger.debug("Received from Kafka (length={}): {}", rawValue.length(), rawValue)

                    // Parse to check if this is an actual CDC event (not snapshot/read)
                    // We only want: c (create/insert), u (update), d (delete)
                    // Skip: r (read/snapshot)
                    boolean shouldProcess
                    try {
                        // Quick check for operation type without full JSON parsing
                        shouldProcess = rawValue.contains("\"op\":\"c\"") ||
                                        rawValue.contains("\"op\":\"u\"") ||
                                        rawValue.contains("\"op\":\"d\"")
                    } catch (Exception e) {
                        logger.warn("Could not parse message, processing anyway: {}", e.getMessage())
                        shouldProcess = true
                    }

                    if (shouldProcess && !rawValue.isBlank()) {
                        def result = sink.tryEmitNext(rawValue)
                        if (result.isFailure()) {
                            logger.error("Failed to emit to sink: {}", result)
                        } else {
                            logger.debug("Successfully emitted CDC event to sink")
                        }
                    } else {
                        logger.debug("Skipping non-CDC event (snapshot/read/empty)")
                    }
                    record.receiverOffset().acknowledge()
                }
                .doOnError { e ->
                    logger.error("Error receiving from Kafka: {}", e.getMessage(), e)
                }
                .retry()
                .subscribe(
                        { next -> },
                        { error -> logger.error("Fatal error in Kafka consumer: {}", error.getMessage(), error) },
                        { -> logger.info("Kafka consumer completed") }
                )
        logger.info("Kafka consumer initialization complete")
    }

    Flux<String> getFlux() {
        return sink.asFlux()
    }
}
