package auditConsumer

import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import groovy.util.logging.Slf4j
import org.apache.kafka.clients.consumer.ConsumerConfig
import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.kafka.common.errors.WakeupException

import java.sql.Connection
import java.sql.DriverManager
import java.sql.PreparedStatement
import java.sql.SQLException
import java.sql.Timestamp
import java.time.Duration

/**
 * Kafka Consumer for Audit Logs
 * Consumes CDC events from Kafka and stores them in TimescaleDB
 */
@Slf4j
class AuditConsumer {

    private static final ObjectMapper objectMapper = new ObjectMapper()
    private static final Properties properties = new Properties()

    static {
        try {
            InputStream input = AuditConsumer.class.getClassLoader().getResourceAsStream("application.properties")
            if (input != null) {
                properties.load(input)
            } else {
                log.warn("application.properties not found, using defaults or environment variables")
            }
        } catch (IOException ex) {
            log.error("Error loading application.properties", ex)
        }
    }

    // Configuration from environment variables or properties file
    private static final String KAFKA_BROKER = getEnv('KAFKA_BROKER', properties.getProperty('kafka.broker', 'kafka:9092'))
    private static final String KAFKA_TOPIC = getEnv('KAFKA_TOPIC', properties.getProperty('kafka.topic', 'server.public.company'))
    private static final String KAFKA_GROUP = getEnv('KAFKA_GROUP', properties.getProperty('kafka.group', 'audit_consumer_group'))

    private static final String DB_HOST = getEnv('DB_HOST', properties.getProperty('db.host', 'auditDb'))
    private static final String DB_PORT = getEnv('DB_PORT', properties.getProperty('db.port', '5432'))
    private static final String DB_NAME = getEnv('DB_NAME', properties.getProperty('db.name', 'auditdb'))
    private static final String DB_USER = getEnv('DB_USER', properties.getProperty('db.user', 'admin'))
    private static final String DB_PASSWORD = getEnv('DB_PASSWORD', properties.getProperty('db.password', 'admin'))

    private static String getEnv(String key, String defaultValue) {
        System.getenv(key) ?: defaultValue
    }

    static void main(String[] args) {
        log.info('Starting Audit Consumer...')
        log.info('Kafka Broker: {}', KAFKA_BROKER)
        log.info('Kafka Topic: {}', KAFKA_TOPIC)
        log.info('Database: {}:{}/{}', DB_HOST, DB_PORT, DB_NAME)

        // Create Kafka consumer
        def consumer = createKafkaConsumer()

        // Subscribe to topic
        consumer.subscribe([KAFKA_TOPIC])
        log.info('✓ Connected to Kafka, consuming from topic: {}', KAFKA_TOPIC)

        // Database connection with retry
        String dbUrl = "jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}"
        Connection connection = null

        int maxRetries = 10
        int retryCount = 0
        while (connection == null && retryCount < maxRetries) {
            try {
                connection = DriverManager.getConnection(dbUrl, DB_USER, DB_PASSWORD)
                connection.autoCommit = true
                log.info('✓ Connected to database')
            } catch (Exception e) {
                retryCount++
                if (retryCount >= maxRetries) {
                    log.error('✗ Failed to connect to database after {} attempts: {}', maxRetries, e.message)
                    throw e
                }
                log.warn('⚠ Database connection attempt {} failed, retrying in 5s...', retryCount)
                Thread.sleep(5000)
            }
        }

        // Consume messages
        Runtime.runtime.addShutdownHook(new Thread({
            log.info('Shutting down...')
            try {
                consumer.wakeup()
            } catch (Exception e) {
                log.error('Error during shutdown: {}', e.message)
            }
        }))

        PreparedStatement auditStmt = null
        try {
            // Prepare statement once for performance
            String sql = 'INSERT INTO company_audit (before, after, operation_type, changed_at, changed_by_user_id, parent_id) VALUES (?::jsonb, ?::jsonb, ?, ?, ?, ?)'
            auditStmt = connection.prepareStatement(sql)

            log.info('✓ Starting message consumption loop...')
            while (true) {
                def records = consumer.poll(Duration.ofMillis(1000))

                if (records.count() > 0) {
                    log.debug('Received {} records', records.count())
                }

                records.each { ConsumerRecord<String, String> record ->
                    try {
                        log.debug('Processing message from partition {} offset {}', record.partition(), record.offset())
                        processMessage(record, auditStmt)
                    } catch (SQLException e) {
                        log.error('✗ Database error processing message from partition {} offset {}: {}',
                                  record.partition(), record.offset(), e.message, e)
                        throw e
                    } catch (Exception e) {
                        log.error('✗ Error processing message from partition {} offset {}: {}',
                                  record.partition(), record.offset(), e.message, e)
                    }
                }

                if (records.count() > 0) {
                    try {
                        consumer.commitSync()
                    } catch (Exception e) {
                        log.error('Failed to commit offsets: {}', e.message)
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
            if (auditStmt != null && !auditStmt.isClosed()) {
                auditStmt.close()
            }
            if (connection != null && !connection.isClosed()) {
                connection.close()
            }
        }
    }

    private static KafkaConsumer<String, String> createKafkaConsumer() {
        Properties props = new Properties()
        props[ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG] = KAFKA_BROKER
        props[ConsumerConfig.GROUP_ID_CONFIG] = KAFKA_GROUP
        props[ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG] = StringDeserializer.name
        props[ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG] = StringDeserializer.name
        props[ConsumerConfig.AUTO_OFFSET_RESET_CONFIG] = 'earliest'
        props[ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG] = 'false'

        new KafkaConsumer<>(props)
    }

    private static Integer getIntFromJsonNode(JsonNode node, String fieldName) {
        if (node != null && node.has(fieldName) && !node.get(fieldName).isNull()) {
            return node.get(fieldName).asInt()
        }
        return null
    }

    private static void processMessage(ConsumerRecord<String, String> record, PreparedStatement stmt) {
        // Parse the Debezium CDC message
        JsonNode rootNode = objectMapper.readTree(record.value())
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
        Integer changedByUserId = getIntFromJsonNode(after, "last_user_id") ?: getIntFromJsonNode(before, "last_user_id") ?: 0
        Integer parentId = getIntFromJsonNode(after, "id") ?: getIntFromJsonNode(before, "id") ?: 0

        // Insert into audit table
        try {
            String beforeJson = (before == null || before.isNull()) ? null : objectMapper.writeValueAsString(before)
            String afterJson = (after == null || after.isNull()) ? null : objectMapper.writeValueAsString(after)

            stmt.setString(1, beforeJson)
            stmt.setString(2, afterJson)
            stmt.setString(3, operationType)
            stmt.setTimestamp(4, new Timestamp(System.currentTimeMillis()))
            stmt.setInt(5, changedByUserId)
            stmt.setInt(6, parentId)

            int rowsAffected = stmt.executeUpdate()

            if (rowsAffected > 0) {
                String recordId = "N/A"
                if (after != null && after.has("id")) recordId = after.get("id").asText()
                else if (before != null && before.has("id")) recordId = before.get("id").asText()
                
                log.info('✓ Inserted audit record for {} id: {}', operationType, recordId)
            } else {
                log.warn('⚠ No rows inserted for record')
            }
        } catch (Exception e) {
            log.error('✗ Failed to insert audit record: {}', e.message, e)
            throw e
        }
    }
}