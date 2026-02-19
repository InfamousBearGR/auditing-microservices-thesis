package com.business.registry.service

import groovy.transform.CompileStatic
import org.bouncycastle.crypto.generators.Argon2BytesGenerator
import org.bouncycastle.crypto.params.Argon2Parameters
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

import java.security.SecureRandom

@Service
@CompileStatic
class PasswordService {

    private static final int SALT_LENGTH = 16
    private static final int HASH_LENGTH = 32
    private static final int ITERATIONS = 2
    private static final int MEMORY = 65536 // 64 MB
    private static final int PARALLELISM = 1

    private final SecureRandom secureRandom = new SecureRandom()

    private static final Logger log = LoggerFactory.getLogger(PasswordService.class)

    /**
     * Hash a password using Argon2id
     * @param password The plain text password
     * @return The hashed password with salt (format: salt:hash in Base64)
     */
    String hashPassword(String password) {
        byte[] salt = new byte[SALT_LENGTH]
        secureRandom.nextBytes(salt)

        byte[] hash = generateArgon2Hash(password, salt)

        String saltB64 = Base64.encoder.encodeToString(salt)
        String hashB64 = Base64.encoder.encodeToString(hash)

        return "${saltB64}:${hashB64}"
    }

    /**
     * Verify a password against a stored hash
     * @param password The plain text password to verify
     * @param storedHash The stored hash (format: salt:hash in Base64)
     * @return true if password matches, false otherwise
     */
    static boolean verifyPassword(String password, String storedHash) {
        if (!storedHash || !storedHash.contains(':')) {
            return false
        }

        String[] parts = storedHash.split(':', 2)
        if (parts.length != 2) {
            return false
        }

        try {
            byte[] salt = Base64.decoder.decode(parts[0])
            byte[] expectedHash = Base64.decoder.decode(parts[1])

            byte[] actualHash = generateArgon2Hash(password, salt)

            return constantTimeEquals(expectedHash, actualHash)
        } catch (Exception e) {
            log.error(e.message)
            return false
        }
    }

    /**
     * Generate Argon2id hash
     */
    private static byte[] generateArgon2Hash(String password, byte[] salt) {
        Argon2Parameters.Builder builder = new Argon2Parameters.Builder(Argon2Parameters.ARGON2_id)
            .withVersion(Argon2Parameters.ARGON2_VERSION_13)
            .withIterations(ITERATIONS)
            .withMemoryAsKB(MEMORY)
            .withParallelism(PARALLELISM)
            .withSalt(salt)

        Argon2BytesGenerator generator = new Argon2BytesGenerator()
        generator.init(builder.build())

        byte[] hash = new byte[HASH_LENGTH]
        generator.generateBytes(password.toCharArray(), hash)

        return hash
    }

    /**
     * Constant time comparison to prevent timing attacks
     */
    private static boolean constantTimeEquals(byte[] a, byte[] b) {
        if (a.length != b.length) {
            return false
        }

        int result = 0
        for (int i = 0; i < a.length; i++) {
            result |= a[i] ^ b[i]
        }

        return result == 0
    }
}

