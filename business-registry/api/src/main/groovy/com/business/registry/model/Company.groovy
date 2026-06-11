package com.business.registry.model

import groovy.transform.CompileStatic
import jakarta.persistence.*
import org.hibernate.envers.Audited
import org.hibernate.envers.RelationTargetAuditMode
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

import java.time.LocalDate

@Entity
@Table(name = "company")
@Audited(targetAuditMode = RelationTargetAuditMode.NOT_AUDITED)
@CompileStatic
class Company implements Auditable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id

    @NotBlank
    @Column(nullable = false)
    String name

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

    @NotBlank
    @Column(nullable = false, length = 9)
    String afm

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "legal_type_id", nullable = false)
    LegalType legalType

    @NotNull
    @Column(name = "date_incorporated", nullable = false)
    LocalDate dateIncorporated

    @NotBlank
    @Column(name = "gemi_number", nullable = false, length = 12)
    String registryNumber

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_status_id", nullable = false)
    CompanyStatus companyStatus

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
