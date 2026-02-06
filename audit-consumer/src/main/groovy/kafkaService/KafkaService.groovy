package kafkaService

import com.fasterxml.jackson.databind.JsonNode
import databaseService.DatabaseService
import groovy.util.logging.Slf4j
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.common.errors.WakeupException
import org.apache.kafka.common.serialization.StringDeserializer
import utils.Utils

import java.sql.Connection
import java.sql.SQLException
import java.sql.Timestamp
import java.time.Duration
import java.util.concurrent.atomic.AtomicBoolean
import java.util.regex.Pattern

@Slf4j
class KafkaService {
    private static final Properties properties = Utils.getProperties()
    private static final String KAFKA_GROUP = Utils.getEnv('KAFKA_GROUP', properties.getProperty('kafka.group'))
    private static final String KAFKA_BROKER = Utils.getEnv('KAFKA_BROKER', properties.getProperty('kafka.broker'))
    private static final String KAFKA_TOPIC = Utils.getEnv('KAFKA_TOPIC', properties.getProperty('kafka.topic'))

    static KafkaConsumer<String, String> createKafkaConsumer() {
        log.info('Kafka Broker: {}', KAFKA_BROKER)
        Properties props = new Properties()
        props[ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG] = KAFKA_BROKER
        props[ConsumerConfig.GROUP_ID_CONFIG] = KAFKA_GROUP
        props[ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG] = StringDeserializer.name
        props[ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG] = StringDeserializer.name
        props[ConsumerConfig.AUTO_OFFSET_RESET_CONFIG] = 'earliest'
        props[ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG] = 'false'

        new KafkaConsumer<>(props)
    }

    static void processMessage(Connection connection, ConsumerRecord<String, String> record) {
        // Parse the Debezium CDC message
        JsonNode rootNode = Utils.stringToJsonNode(record.value())
        JsonNode payload = rootNode.has("payload") ? rootNode.get("payload") : rootNode

        if (payload == null || payload.isNull()) {
            log.debug('Skipping null payload')
            return
        }

        JsonNode before = payload.get("before")
        JsonNode after = payload.get("after")
        String op = payload.has("op") ? payload.get("op").asText() : ""

        String operationType
        switch (op) {
            case "c": operationType = "INSERT"; break
            case "u": operationType = "UPDATE"; break
            case "d": operationType = "DELETE"; break
            case "r": operationType = "INSERT"; break
            default: operationType = "UNKNOWN"
        }

        // Extract changed_by_user_id
        Integer changedByUserId = Utils.getIntFromJsonNode(after, "last_user_id") ?: Utils.getIntFromJsonNode(before, "last_user_id") ?: 0
        Integer parentId = Utils.getIntFromJsonNode(after, "id") ?: Utils.getIntFromJsonNode(before, "id") ?: 0
        Timestamp operationTimestamp = new Timestamp(Utils.getLongFromJsonNode(payload.get("source"), "ts_ms"))
        // Insert into audit table

        String beforeJson = Utils.jsonNodeToString(before)
        String afterJson = Utils.jsonNodeToString(after)

        String topic = record.topic()
        String tableName = topic.substring(topic.lastIndexOf('.') + 1)
        String auditTableName = tableName + "_audit"

        DatabaseService.insertAuditLog(
                connection,
                auditTableName,
                beforeJson,
                afterJson,
                operationType,
                operationTimestamp,
                changedByUserId,
                parentId
        )
    }

    static consumeMessages() {
        log.info('Starting Audit Consumer...')

        log.info('Kafka Topic: {}', KAFKA_TOPIC)

        // Create Kafka consumer
        KafkaConsumer<String, String> consumer = createKafkaConsumer()
        AtomicBoolean running = new AtomicBoolean(true)

        // Subscribe to topic
        consumer.subscribe(Pattern.compile(KAFKA_TOPIC))
        log.info('✓ Connected to Kafka, consuming from topic pattern: {}', KAFKA_TOPIC)


        // Consume messages
        Runtime.runtime.addShutdownHook(new Thread({
            log.info('Shutting down...')
            running.set(false)
            try {
                consumer.wakeup()
            } catch (Exception e) {
                log.error('Error during shutdown: {}', e.message)
            }
        }))


        try {
            // Prepare statement once for performance
            log.info('✓ Starting message consumption loop...')
            while (running.get()) {
                def records = consumer.poll(Duration.ofMillis(1000))

                if (records.count() > 0) {
                    log.debug('Received {} records', records.count())
                }

                Connection connection = null
                try {
                    if (records.count() > 0) {
                        connection = DatabaseService.getConnection()
                    }

                    records.each { ConsumerRecord<String, String> record ->
                        try {
                            log.debug('Processing message from partition {} offset {}', record.partition(), record.offset())
                            processMessage(connection, record)
                        } catch (SQLException e) {
                            log.error('✗ Database error processing message from partition {} offset {}: {}',
                                    record.partition(), record.offset(), e.message, e)
                            throw e
                        } catch (Exception e) {
                            log.error('✗ Error processing message from partition {} offset {}: {}',
                                    record.partition(), record.offset(), e.message, e)
                            throw e
                        }
                    }

                    if (connection != null) {
                        connection.commit()
                    }

                    if (records.count() > 0) {
                        try {
                            consumer.commitSync()
                        } catch (Exception e) {
                            log.error('Failed to commit offsets: {}', e.message)
                        }
                    }
                } catch (Exception e) {
                    if (connection != null) {
                        try {
                            connection.rollback()
                            log.info('Rolled back database transaction due to error')
                        } catch (SQLException rollbackEx) {
                            log.error('Failed to rollback transaction: {}', rollbackEx.message)
                        }
                    }
                    log.error('Error processing batch: {}', e.message)
                    throw e
                } finally {
                    if (connection != null && !connection.isClosed()) {
                        connection.close()
                    }
                }
            }
        } catch (WakeupException e) {
            log.error('Shutdown signal received, exiting consumption loop.', e.message, e)
        } catch (Exception e) {
            log.error('Fatal error in consumption loop: {}', e.message, e)
            System.exit(1)
        } finally {
            consumer.close()
        }
    }
}
