package com.business.registry.validation

import com.business.registry.service.MessageService
import groovy.transform.CompileStatic

import java.time.LocalDate
import java.time.format.DateTimeParseException

@CompileStatic
class Utils {

    // -------------------------------------------------------------------------
    // Shared validation helpers – used by all Validatable components
    // -------------------------------------------------------------------------

    /**
     * Validates that an id is non-null and positive.
     */
    static void validateId(Long id, MessageService messageService) {
        if (id == null || id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
    }

    /**
     * Validates that a request DTO is not null.
     */
    static void validateRequestNotNull(Object dto, MessageService messageService) {
        if (dto == null) {
            throw new IllegalArgumentException(messageService.getMessage("Το.αίτημα.είναι.κενό"))
        }
    }

    /**
     * Validates that a required String field is non-null and non-blank.
     */
    static void validateRequiredString(String value, String messageKey, MessageService messageService) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage(messageKey))
        }
    }

    /**
     * Validates a Long foreign-key / id field – must be non-null and positive.
     */
    static void validateRequiredId(Long value, String messageKey, MessageService messageService) {
        if (value == null || value <= 0) {
            throw new IllegalArgumentException(messageService.getMessage(messageKey, [value] as Object[]))
        }
    }

    /**
     * Validates the AFM field: presence + algorithmic check.
     */
    static void validateAfmField(String afm, MessageService messageService) {
        validateRequiredString(afm, "Το.πεδίο.ΑΦΜ.είναι.υποχρεωτικό", messageService)
        if (!validateAfm(afm)) {
            throw new IllegalArgumentException(messageService.getMessage("Το.ΑΦΜ.δεν.είναι.έγκυρο"))
        }
    }

    /**
     * Validates the shared address block (city, street, streetNumber, postalCode).
     */
    static void validateAddressFields(
            String city, String street, String streetNumber, String postalCode,
            MessageService messageService) {
        validateRequiredString(city,         "Το.πεδίο.Πόλη.είναι.υποχρεωτικό",                  messageService)
        validateRequiredString(street,       "Το.πεδίο.Οδός.είναι.υποχρεωτικό",                  messageService)
        validateRequiredString(streetNumber, "Το.πεδίο.Αριθμός.είναι.υποχρεωτικό",               messageService)
        validateRequiredString(postalCode,   "Το.πεδίο.Ταχυδρομικός.Κώδικας.είναι.υποχρεωτικό", messageService)
    }

    /**
     * Validates the shared location id block (countryId, prefectureId, municipalityId, regionId).
     */
    static void validateLocationIds(
            Long countryId, Long prefectureId, Long municipalityId, Long regionId,
            MessageService messageService) {
        validateRequiredId(countryId,      "Το.πεδίο.Χώρα.είναι.υποχρεωτικό",       messageService)
        validateRequiredId(prefectureId,   "Το.πεδίο.Νομός.είναι.υποχρεωτικό",      messageService)
        validateRequiredId(municipalityId, "Το.πεδίο.Δήμος.είναι.υποχρεωτικό",      messageService)
        validateRequiredId(regionId,       "Το.πεδίο.Περιφέρεια.είναι.υποχρεωτικό", messageService)
    }

    /**
     * Validates the shared changeReason field.
     */
    static void validateChangeReason(String changeReason, MessageService messageService) {
        validateRequiredString(changeReason, "Το.πεδίο.Αιτία.Αλλαγής.είναι.υποχρεωτικό", messageService)
    }


    static boolean validateAfm(String afm) {
        // Null/empty guard
        if (afm == null) {
            return false
        }

        // Must be exactly 9 characters
        if (afm.length() != 9) {
            return false
        }

        // Must be all digits
        if (!afm.matches(/\d+/)) {
            return false
        }

        // Disallow all-zero AFM
        if (afm == ('0' * 9)) {
            return false
        }

        int sum = 0
        // Compute sum of first 8 digits shifted as in the original algorithm
        for (int i = 0; i < 8; i++) {
            int v = Character.getNumericValue(afm.charAt(i))
            sum += (v << (8 - i))
        }

        int calc = sum % 11
        int d9 = Character.getNumericValue(afm.charAt(8))
        boolean valid = (calc % 10) == d9

        return valid
    }

    static boolean validateDate(String dateStr) {
        // Null/empty guard
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return false
        }

        // Check format YYYY-MM-DD
        if (!dateStr.matches(/\d{4}-\d{2}-\d{2}/)) {
            return false
        }

        try {
            // Parse the date to ensure it's valid
            LocalDate.parse(dateStr)
            return true
        } catch (DateTimeParseException ignored) {
            return false
        }
    }

    static boolean validatePercentage(String percentageStr) {
        // Null/empty guard
        if (percentageStr == null || percentageStr.trim().isEmpty()) {
            return false
        }

        String normalized = percentageStr.trim()

        // Handle percentage sign
        if (normalized.endsWith("%")) {
            normalized = normalized.substring(0, normalized.length() - 1).trim()
        }

        try {
            double percentage
            if (normalized.contains("/")) {
                String[] parts = normalized.split("/")
                if (parts.length != 2) {
                    return false
                }
                double numerator = Double.parseDouble(parts[0].trim())
                double denominator = Double.parseDouble(parts[1].trim())
                if (denominator == 0) {
                    return false
                }
                percentage = numerator / denominator
                // If it's a fraction like 1/3, it's likely 0.333.
                // The existing validation checks 0..100.
                // 0.333 is within 0..100.
            } else {
                percentage = Double.parseDouble(normalized)
            }
            return percentage >= 0 && percentage <= 100
        } catch (NumberFormatException ignored) {
            return false
        }
    }

    static boolean validateBigDecimal(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false
        }
        String trimmed = value.trim()
        // Allow at most 2 decimal places: e.g. 55, 55.1, 55.11, 55.0, 55.00 — but not 55.000
        if (!trimmed.matches(/^-?\d+(\.\d{1,2})?$/)) {
            return false
        }
        try {
            new BigDecimal(trimmed)
            return true
        } catch (NumberFormatException ignored) {
            return false
        }
    }
}
