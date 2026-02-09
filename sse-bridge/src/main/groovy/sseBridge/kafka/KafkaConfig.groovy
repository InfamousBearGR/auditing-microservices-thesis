package sseBridge.kafka

import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.common.serialization.StringDeserializer
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import reactor.kafka.receiver.KafkaReceiver
import reactor.kafka.receiver.ReceiverOptions
import sseBridge.event.EventDeserializer

import java.util.regex.Pattern

@Configuration
class KafkaConfig {

    private static final Logger logger = LoggerFactory.getLogger(KafkaConfig.class)

    @Value('${kafka.bootstrap.servers}')
    private String bootstrapServers

    @Value('${kafka.client.event.topic}')
    private String topicName

    @Value('${kafka.client.id}')
    private String kafkaClientId

    @Value('${kafka.session.timeout.ms}')
    private String sessionTimeoutMsConfig

    @Value('${kafka.default.api.timeout.ms}')
    private String defaultApiTimeoutMsConfig

    @Value('${kafka.request.timeout.ms}')
    private String requestTimeoutMsConfig

    @Value('${kafka.reconnect.backoff.max.ms}')
    private String reconnectBackOffMaxMs

    @Value('${kafka.reconnect.backoff.ms}')
    private String reconnectBackOffMs

    @Value('${kafka.retry.backoff.ms}')
    private String retryBackOffMs

    @Bean
    KafkaReceiver receiverOptions() {
        UUID uuid = UUID.randomUUID()
        // Use environment variable if set, otherwise use property
        String effectiveBootstrapServers = System.getenv("KAFKA_BROKER") ?: bootstrapServers
        
        Map<String, Object> configProps = new HashMap<>()
        configProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, effectiveBootstrapServers)
        configProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class)
        configProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, EventDeserializer.class)
        configProps.put(ConsumerConfig.CLIENT_ID_CONFIG, kafkaClientId)
        configProps.put(ConsumerConfig.GROUP_ID_CONFIG, uuid.toString())
        configProps.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, true)
        configProps.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest")

        configProps.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, sessionTimeoutMsConfig)
        configProps.put(ConsumerConfig.DEFAULT_API_TIMEOUT_MS_CONFIG, defaultApiTimeoutMsConfig)
        configProps.put(ConsumerConfig.REQUEST_TIMEOUT_MS_CONFIG, requestTimeoutMsConfig)
        configProps.put(ConsumerConfig.RECONNECT_BACKOFF_MAX_MS_CONFIG, reconnectBackOffMaxMs)
        configProps.put(ConsumerConfig.RECONNECT_BACKOFF_MS_CONFIG, reconnectBackOffMs)
        configProps.put(ConsumerConfig.RETRY_BACKOFF_MS_CONFIG, retryBackOffMs)

        logger.info("Configuring Kafka receiver with broker: {}", effectiveBootstrapServers)
        logger.debug("Kafka consumer configuration: clientId={}, groupId={}, topicPattern={}", kafkaClientId, uuid, "server.public.*")

        return KafkaReceiver.create(
                ReceiverOptions.create(configProps).subscription(Pattern.compile(topicName))
        )
    }
}
