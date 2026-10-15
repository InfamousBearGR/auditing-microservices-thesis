package com.business.registry.service

import groovy.transform.CompileStatic
import org.bouncycastle.crypto.generators.Argon2BytesGenerator
import org.bouncycastle.crypto.params.Argon2Parameters
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

import java.security.SecureRandom

/**
 * Argon2id password hashing.
 *
 * Stored hash formats (both Base64, salt and hash separated by ':'):
 *   <salt>:<hash>                       legacy — default cost parameters below
 *   m=<KiB>,t=<iterations>,p=<lanes>$<salt>:<hash>
 *                                       cost parameters stored WITH the hash
 *
 * Storing the parameters with the hash is the usual practice (cf. the PHC string
 * format): the cost can be raised for new hashes without invalidating old ones.
 * hashPassword() always writes the parametrised format with the default cost.
 * The benchmark accounts (bench1..bench64 in mainDb/init.sql) use a deliberately
 * cheap cost so that the load generator measures the audited write path and not
 * password hashing — never use such parameters for real accounts.
 */
@Service
@CompileStatic
class PasswordService {

    private static final int SALT_LENGTH = 16
    private static final int HASH_LENGTH = 32
    private static final int ITERATIONS = 2
    private static final int MEMORY = 65536 // 64 MB
    private static final int PARALLELISM = 1

    // Sanity bounds for parameters read from a stored hash.
    private static final int MIN_MEMORY = 8
    private static final int MAX_MEMORY = 1048576 // 1 GB
    private static final int MAX_ITERATIONS = 64
    private static final int MAX_PARALLELISM = 16

    private final SecureRandom secureRandom = new SecureRandom()

    private static final Logger log = LoggerFactory.getLogger(PasswordService.class)

    /**
     * Hash a password using Argon2id
     * @param password The plain text password
     * @return The hashed password (format: m=..,t=..,p=..$salt:hash, Base64)
     */
    String hashPassword(String password) {
        byte[] salt = new byte[SALT_LENGTH]
        secureRandom.nextBytes(salt)

        byte[] hash = generateArgon2Hash(password, salt, MEMORY, ITERATIONS, PARALLELISM)

        String saltB64 = Base64.encoder.encodeToString(salt)
        String hashB64 = Base64.encoder.encodeToString(hash)

        return "m=${MEMORY},t=${ITERATIONS},p=${PARALLELISM}\$${saltB64}:${hashB64}".toString()
    }

    /**
     * Verify a password against a stored hash
     * @param password The plain text password to verify
     * @param storedHash The stored hash (legacy salt:hash or m=..,t=..,p=..$salt:hash)
     * @return true if password matches, false otherwise
     */
    static boolean verifyPassword(String password, String storedHash) {
        if (!storedHash || !storedHash.contains(':')) {
            return false
        }

        int memory = MEMORY
        int iterations = ITERATIONS
        int parallelism = PARALLELISM
        String saltAndHash = storedHash

        int dollar = storedHash.indexOf('$')
        if (dollar >= 0) {
            int[] params = parseParameters(storedHash.substring(0, dollar))
            if (params == null) {
                log.error('Unrecognised password hash parameters')
                return false
            }
            memory = params[0]
            iterations = params[1]
            parallelism = params[2]
            saltAndHash = storedHash.substring(dollar + 1)
        }

        String[] parts = saltAndHash.split(':', 2)
        if (parts.length != 2) {
            return false
        }

        try {
            byte[] salt = Base64.decoder.decode(parts[0])
            byte[] expectedHash = Base64.decoder.decode(parts[1])

            byte[] actualHash = generateArgon2Hash(password, salt, memory, iterations, parallelism)

            return constantTimeEquals(expectedHash, actualHash)
        } catch (Exception e) {
            log.error(e.message)
            return false
        }
    }

    /**
     * Parse "m=<KiB>,t=<iterations>,p=<lanes>" (any order).
     * @return [memory, iterations, parallelism] or null if malformed / out of bounds
     */
    private static int[] parseParameters(String spec) {
        int memory = -1
        int iterations = -1
        int parallelism = -1
        for (String item : spec.split(',')) {
            String[] kv = item.trim().split('=', 2)
            if (kv.length != 2) {
                return null
            }
            int value = 0
            try {
                value = Integer.parseInt(kv[1].trim())
            } catch (NumberFormatException ignored) {
                return null
            }
            switch (kv[0].trim()) {
                case 'm': memory = value; break
                case 't': iterations = value; break
                case 'p': parallelism = value; break
                default: return null
            }
        }
        if (parallelism < 1 || parallelism > MAX_PARALLELISM) {
            return null
        }
        if (iterations < 1 || iterations > MAX_ITERATIONS) {
            return null
        }
        if (memory < Math.max(MIN_MEMORY, 8 * parallelism) || memory > MAX_MEMORY) {
            return null
        }
        return [memory, iterations, parallelism] as int[]
    }

    /**
     * Generate Argon2id hash
     */
    private static byte[] generateArgon2Hash(String password, byte[] salt, int memory, int iterations, int parallelism) {
        Argon2Parameters.Builder builder = new Argon2Parameters.Builder(Argon2Parameters.ARGON2_id)
            .withVersion(Argon2Parameters.ARGON2_VERSION_13)
            .withIterations(iterations)
            .withMemoryAsKB(memory)
            .withParallelism(parallelism)
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
