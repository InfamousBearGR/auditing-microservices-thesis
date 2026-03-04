package com.business.registry.dao

import com.business.registry.model.Auditable

/**
 * Marker interface for DAOs that participate in a cascading delete.
 *
 * <p>Any DAO whose entity type needs to be stamped and removed as part of a
 * {@link com.business.registry.service.DeleteService#cascadeDelete} call should
 * implement this interface. Doing so removes the need to pass explicit
 * {@code saveChild} and {@code deleteChild} closures when building a
 * {@link com.business.registry.service.DeleteService.ChildGroup}.
 *
 * @param <T> the entity type – must implement {@link Auditable}
 */
interface CascadableDao<T extends Auditable> {
    /** Persists (inserts or updates) {@code entity}. */
    T save(T entity)

    /**
     * Persists {@code entity} and immediately flushes the change to the database,
     * ensuring the UPDATE is written to the WAL before a subsequent DELETE is issued.
     * This is required so that Debezium captures both the UPDATE and the DELETE events.
     */
    T saveAndFlush(T entity)

    /** Deletes the record identified by {@code id}. */
    void deleteById(Long id)
}

