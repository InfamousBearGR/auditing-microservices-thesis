package com.business.registry.model

import groovy.transform.CompileStatic
import jakarta.persistence.*
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

import static jakarta.persistence.FetchType.LAZY
import static jakarta.persistence.GenerationType.IDENTITY
import static jakarta.persistence.TemporalType.TIMESTAMP

@Entity
@Table(name = "stock_typesI18n", uniqueConstraints = [
        @UniqueConstraint(columnNames = ["stock_type_id", "language_id"])
])
@CompileStatic
class StockTypeI18n {

    @Id
    @GeneratedValue(strategy = IDENTITY)
    Long id

    @NotNull
    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "stock_type_id", nullable = false)
    StockType stockType

    @NotBlank
    @Column(nullable = false)
    String description

    @NotNull
    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "language_id", nullable = false)
    Language language

    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "last_user_id")
    UserAccount lastUser

    @NotBlank
    @Column(name = "change_reason", nullable = false)
    String changeReason

    @Column(name = "date_created", nullable = false, updatable = false)
    @Temporal(TIMESTAMP)
    Date dateCreated

    @Column(name = "last_updated", nullable = false)
    @Temporal(TIMESTAMP)
    Date lastUpdated
}

