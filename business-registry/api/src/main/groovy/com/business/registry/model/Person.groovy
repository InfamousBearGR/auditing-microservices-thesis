package com.business.registry.model

import groovy.transform.CompileStatic
import jakarta.persistence.*
import org.hibernate.envers.Audited
import org.hibernate.envers.RelationTargetAuditMode
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

import java.time.LocalDate

@Entity
@Table(name = "person")
@Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
@CompileStatic
class Person {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id

    @NotBlank
    @Column(nullable = false)
    String name

    @NotBlank
    @Column(nullable = false)
    String surname

    @NotBlank
    @Column(nullable = false, length = 9)
    String afm

    @Column
    String city

    @Column
    String street

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "country_id")
    Country country

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "prefecture_id")
    Prefecture prefecture

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "municipality_id")
    Municipality municipality

    @Column(name = "street_number", length = 50)
    String streetNumber

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "region_id")
    Region region

    @Column(name = "postal_code", length = 20)
    String postalCode

    @NotNull
    @Column(name = "birth_date", nullable = false)
    LocalDate birthDate

    @NotBlank
    @Column(name = "birth_place", nullable = false)
    String birthPlace

    @NotBlank
    @Column(name = "identity_number", nullable = false, length = 20)
    String identityNumber

    @Column(name = "phone_number", length = 20)
    String phoneNumber

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "last_user_id")
    UserAccount lastUser

    @NotBlank
    @Column(name = "change_reason", nullable = false)
    String changeReason

    @Column(name = "date_created", nullable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    Date dateCreated

    @Column(name = "last_updated", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    Date lastUpdated
}

