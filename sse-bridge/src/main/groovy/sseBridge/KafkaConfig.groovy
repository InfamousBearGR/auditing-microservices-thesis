package sseBridge

import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.common.serialization.StringDeserializer
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import reactor.kafka.receiver.ReceiverOptions

@Configuration
class KafkaConfig {

    private static final Logger logger = LoggerFactory.getLogger(KafkaConfig.class)

    @Bean
    ReceiverOptions<String, String> receiverOptions() {
        Map<String, Object> props = [:]
        def kafkaBroker = System.getenv("KAFKA_BROKER") ?: "localhost:9092"
        
        props[ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG] = kafkaBroker
        props[ConsumerConfig.CLIENT_ID_CONFIG] = "sse-bridge"
        props[ConsumerConfig.GROUP_ID_CONFIG] = "sse-consumers"
        props[ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG] = StringDeserializer.class
        props[ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG] = StringDeserializer.class
        props[ConsumerConfig.AUTO_OFFSET_RESET_CONFIG] = "earliest"

        logger.info("Configuring Kafka receiver with broker: {}", kafkaBroker)
        logger.debug("Kafka consumer configuration: clientId=sse-bridge, groupId=sse-consumers, topic=server.public.company")

        return ReceiverOptions.<String, String>create(props)
                .subscription(['server.public.company'])
    }
}
