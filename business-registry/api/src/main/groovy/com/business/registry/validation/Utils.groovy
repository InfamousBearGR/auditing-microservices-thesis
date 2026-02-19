package com.business.registry.validation

import groovy.transform.CompileStatic

import java.time.LocalDate
import java.time.format.DateTimeParseException

@CompileStatic
class Utils {
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
}
