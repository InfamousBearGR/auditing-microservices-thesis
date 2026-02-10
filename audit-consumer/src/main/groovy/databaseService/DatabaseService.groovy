package databaseService

import groovy.util.logging.Slf4j
import utils.Utils

import java.sql.Connection
import java.sql.DriverManager
import java.sql.PreparedStatement
import java.sql.Timestamp

@Slf4j
class DatabaseService {
    private static final Properties properties = Utils.getProperties()
    private static final String DB_HOST = properties.getProperty('db.host', 'auditDb')
    private static final String DB_PORT = properties.getProperty('db.port', '5432')
    private static final String DB_NAME = properties.getProperty('db.name', 'auditdb')
    private static final String DB_USER = properties.getProperty('db.user', 'admin')
    private static final String DB_PASSWORD = properties.getProperty('db.password', 'admin')

    static Connection getConnection() {
        // Database connection with retry
        String dbUrl = "jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}"
        Connection connection = null
        log.info('Database: {}:{}/{}', DB_HOST, DB_PORT, DB_NAME)
        int maxRetries = 10
        int retryCount = 0
        while (connection == null && retryCount < maxRetries) {
            try {
                connection = DriverManager.getConnection(dbUrl, DB_USER, DB_PASSWORD)
                connection.autoCommit = false
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
        return connection
    }

    static insertAuditLog(Connection connection, String table, String beforeJson, String afterJson, String operationType, Timestamp operationTimestamp, int changedByUserId, int parentId, long lsn, String change_reason) {
        PreparedStatement auditStmt = null
        try {
            String sql = 'INSERT INTO ' + table + ' (before, after, operation_type, changed_at, changed_by_user_id, parent_id, change_id, business_change_id, change_reason) VALUES (?::jsonb, ?::jsonb, ?, ?, ?, ?, ?, ?, ?)'
            auditStmt = connection.prepareStatement(sql)
            auditStmt.setString(1, beforeJson)
            auditStmt.setString(2, afterJson)
            auditStmt.setString(3, operationType)
            auditStmt.setTimestamp(4, operationTimestamp)
            auditStmt.setInt(5, changedByUserId)
            auditStmt.setInt(6, parentId)
            auditStmt.setLong(7, lsn)
            auditStmt.setLong(8, operationTimestamp.getTime())
            auditStmt.setString(9, change_reason)
            int rowsAffected = auditStmt.executeUpdate()

            if (rowsAffected < 0) {
               log.warn('⚠ No rows inserted for record')
            }
        } catch (Exception e) {
            log.error('✗ Failed to insert audit record: {}', e.message, e)
            throw e
        } finally {
            if (auditStmt != null && !auditStmt.isClosed()) {
                auditStmt.close()
            }
        }
    }
}
