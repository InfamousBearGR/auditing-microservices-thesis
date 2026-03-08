package com.business.registry.validation

/**
 * Common interface for all validation components.
 * Every validator must be able to look up a record by id and update one.
 */
interface Validatable {

    /**
     * Validates that the given id is non-null and positive.
     */
    void validateFindById(Long id)

    /**
     * Validates the supplied DTO before persisting an update.
     * Implementations may accept additional parameters; this signature
     * covers the simplest case where only the dto itself is checked.
     */
    void validateDeleteById(Long id)
}

