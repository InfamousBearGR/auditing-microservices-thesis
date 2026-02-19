package com.business.registry.model

import groovy.transform.CompileStatic
import jakarta.persistence.*
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

import static jakarta.persistence.FetchType.LAZY
import static jakarta.persistence.GenerationType.IDENTITY
import static jakarta.persistence.TemporalType.TIMESTAMP

@Entity
@Table(name = "countriesI18n", uniqueConstraints = [
    @UniqueConstraint(columnNames = ["country_id", "language_id"])
])
@CompileStatic
class CountryI18n {

    @Id
    @GeneratedValue(strategy = IDENTITY)
    Long id

    @NotNull
    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "country_id", nullable = false)
    Country country

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


