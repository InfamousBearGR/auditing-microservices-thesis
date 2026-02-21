package com.business.registry.model

import groovy.transform.CompileStatic
import jakarta.persistence.*
import jakarta.validation.constraints.DecimalMin
import jakarta.validation.constraints.Digits
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

import static jakarta.persistence.FetchType.LAZY
import static jakarta.persistence.GenerationType.IDENTITY
import static jakarta.persistence.TemporalType.TIMESTAMP

@Entity
@Table(name = "company_capital")
@CompileStatic
class CompanyCapital {

    @Id
    @GeneratedValue(strategy = IDENTITY)
    Long id

    @NotNull
    @Column(name = "company_id", nullable = false)
    Long companyId

    @NotNull
    @Digits(integer = 15, fraction = 2)
    @DecimalMin(value = "0.00")
    @Column(name = "total_amount", nullable = false)
    BigDecimal totalAmount

    @NotNull
    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "currency_id", nullable = false)
    Currency currency

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
