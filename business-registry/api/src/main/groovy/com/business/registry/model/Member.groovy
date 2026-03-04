package com.business.registry.model

import groovy.transform.CompileStatic
import jakarta.persistence.*
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

import java.time.LocalDate

@Entity
@Table(name = "member")
@CompileStatic
class Member implements Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id

    @NotNull
    @Column(nullable = false)
    Boolean active

    @NotNull
    @Column(name = "date_from", nullable = false)
    LocalDate dateFrom

    @NotNull
    @Column(name = "date_to", nullable = false)
    LocalDate dateTo

    @NotBlank
    @Column(name = "percentage_of_ownership", nullable = false, length = 10)
    String percentageOfOwnership

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "person_id")
    Person person

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "legal_entity_id")
    LegalEntity legalEntity

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    Company company

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "representative_of_member")
    Person representativeOfMember

    @NotNull
    @Column(name = "represented_individual", nullable = false)
    Boolean representedIndividual

    @NotNull
    @Column(name = "represented_together", nullable = false)
    Boolean representedTogether

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_relation_id", nullable = false)
    MemberRelation memberRelation

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

