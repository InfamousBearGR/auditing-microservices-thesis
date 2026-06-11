package com.business.registry.audit

import groovy.transform.CompileStatic
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.envers.RevisionEntity
import org.hibernate.envers.RevisionNumber
import org.hibernate.envers.RevisionTimestamp

/**
 * Custom Envers revision entity (REVINFO). Demonstrates the idiomatic Envers
 * attribution mechanism: one row per revision, enriched with the acting user
 * and (optional) change reason via {@link AuditRevisionListener}.
 *
 * NOTE: this is a normal @Entity, so it is mapped even when Envers is disabled.
 * The REVINFO table is therefore pre-created in mainDb/init.sql so that the base
 * profile's ddl-auto=validate succeeds. The <table>_AUD tables, by contrast, are
 * Envers-internal (not mapped entities) and are created by ddl-auto=update only
 * under the 'envers' profile.
 */
@Entity
@Table(name = "revinfo")
@RevisionEntity(AuditRevisionListener)
@CompileStatic
class AuditRevisionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @RevisionNumber
    @Column(name = "rev")
    int id

    @RevisionTimestamp
    @Column(name = "revtstmp")
    long timestamp

    @Column(name = "changed_by_user_id")
    Long changedByUserId

    @Column(name = "change_reason")
    String changeReason
}
