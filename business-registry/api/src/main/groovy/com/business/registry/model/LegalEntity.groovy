package com.business.registry.model

import groovy.transform.CompileStatic
import jakarta.persistence.*
import jakarta.validation.constraints.NotBlank

@Entity
@Table(name = "legal_entity")
@CompileStatic
class LegalEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id

    @NotBlank
    @Column(name = "gemi_number", nullable = false, length = 12)
    String gemiNumber

    @NotBlank
    @Column(name = "business_name", nullable = false)
    String businessName

    @Column(name = "phone_number", length = 20)
    String phoneNumber

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

