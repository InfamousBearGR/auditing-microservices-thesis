package com.example.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import reactor.core.publisher.Flux
import reactor.core.publisher.Sinks
import reactor.kafka.receiver.KafkaReceiver
import reactor.kafka.receiver.ReceiverOptions
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.common.serialization.StringDeserializer
import org.springframework.stereotype.Component
import jakarta.annotation.PostConstruct
import java.util.*

@SpringBootApplication
class SseApplication

fun main(args: Array<String>) {
    runApplication<SseApplication>(*args)
}

@Configuration
class KafkaConfig {
    @Bean
    fun receiverOptions(): ReceiverOptions<String, String> {
        val props = Properties()
        props[ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG] = System.getenv("KAFKA_BROKER") ?: "localhost:9092"
        props[ConsumerConfig.CLIENT_ID_CONFIG] = "sse-bridge"
        props[ConsumerConfig.GROUP_ID_CONFIG] = "sse-consumers"
        props[ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG] = StringDeserializer::class.java
        props[ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG] = StringDeserializer::class.java
        props[ConsumerConfig.AUTO_OFFSET_RESET_CONFIG] = "earliest"

        return ReceiverOptions.create<String, String>(props)
            .subscription(Collections.singleton("server.public.company"))
    }
}

@Component
class KafkaStreamBridge(private val receiverOptions: ReceiverOptions<String, String>) {

    private val sink: Sinks.Many<String> = Sinks.many().multicast().onBackpressureBuffer()

    @PostConstruct
    fun startConsuming() {
        println("Starting Kafka consumer...")
        KafkaReceiver.create(receiverOptions)
            .receive()
            .doOnSubscribe { println("Kafka receiver subscribed") }
            .doOnNext { record ->
                val rawValue = record.value()
                println("Received from Kafka (length=${rawValue.length}): $rawValue")

                // Parse to check if this is an actual CDC event (not snapshot/read)
                // We only want: c (create/insert), u (update), d (delete)
                // Skip: r (read/snapshot)
                val shouldProcess = try {
                    // Quick check for operation type without full JSON parsing
                    rawValue.contains("\"op\":\"c\"") ||
                    rawValue.contains("\"op\":\"u\"") ||
                    rawValue.contains("\"op\":\"d\"")
                } catch (e: Exception) {
                    println("Could not parse message, processing anyway: ${e.message}")
                    true
                }

                if (shouldProcess && rawValue.isNotBlank()) {
                    val result = sink.tryEmitNext(rawValue)
                    if (result.isFailure) {
                        println("Failed to emit to sink: $result")
                    } else {
                        println("Successfully emitted CDC event to sink")
                    }
                } else {
                    println("Skipping non-CDC event (snapshot/read/empty)")
                }
                record.receiverOffset().acknowledge()
            }
            .doOnError { e ->
                println("Error receiving from Kafka: ${e.message}")
                e.printStackTrace()
            }
            .retry()
            .subscribe(
                { },
                { e -> println("Fatal error in Kafka consumer: ${e.message}") },
                { println("Kafka consumer completed") }
            )
        println("Kafka consumer initialization complete")
    }

    fun getFlux(): Flux<String> = sink.asFlux()
}

@RestController
class StreamController(private val kafkaStreamBridge: KafkaStreamBridge) {

    @GetMapping("/stream", produces = ["text/event-stream"])
    fun streamChanges(): Flux<String> {
        println("New SSE client connected")

        // Merge the actual data stream with keepalive
        return Flux.merge(
            kafkaStreamBridge.getFlux()
                .map { value ->
                    println("Processing value from sink (length=${value.length})")
                    // Remove any existing "data:" prefix, trim ALL whitespace (including \n)
                    val cleanValue = value.trim().removePrefix("data:").trim()
                    println("After cleaning (length=${cleanValue.length}): $cleanValue")
                    // Only format if there's actual content
                    if (cleanValue.isNotEmpty()) {
                        "data: $cleanValue\n\n"
                    } else {
                        ""
                    }
                }
                .filter { it.isNotEmpty() }
                .doOnNext { println("Emitting data to SSE (length=${it.length})") },
        )
            .doOnSubscribe { println("SSE subscription started") }
            .doOnCancel { println("SSE client disconnected") }
            .doOnError { e -> println("SSE stream error: ${e.message}") }
    }
}
