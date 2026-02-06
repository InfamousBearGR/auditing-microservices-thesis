package auditConsumer

import groovy.util.logging.Slf4j
import kafkaService.KafkaService

/**
 * Kafka Consumer for Audit Logs
 * Consumes CDC events from Kafka and stores them in TimescaleDB
 */
@Slf4j
class AuditConsumer {
    static void main(String[] args) {
        KafkaService.consumeMessages()
    }
}