package com.business.registry.model

import groovy.transform.CompileStatic
import jakarta.persistence.*
import jakarta.validation.constraints.Digits
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

import static jakarta.persistence.FetchType.LAZY
import static jakarta.persistence.GenerationType.IDENTITY
import static jakarta.persistence.TemporalType.TIMESTAMP

@Entity
@Table(name = "company_stocks", indexes = [
        @Index(columnList = "company_id"),
        @Index(columnList = "stock_type_id")
])
@CompileStatic
class CompanyStock {

    @Id
    @GeneratedValue(strategy = IDENTITY)
    Long id

    @NotNull
    @Column(name = "company_id", nullable = false)
    Long companyId

    @NotNull
    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "stock_type_id", nullable = false)
    StockType stockType

    @NotNull
    @Column(nullable = false)
    Long amount

    @NotNull
    @Digits(integer = 15, fraction = 2)
    @Column(name = "nominal_price", nullable = false)
    BigDecimal nominalPrice

    @ManyToOne(fetch = LAZY)
    @JoinColumn(name = "last_user_id")
    UserAccount lastUser

    @NotBlank
    @Column(name = "change_reason", nullable = false, length = 255)
    String changeReason

    @Column(name = "date_created", nullable = false, updatable = false)
    @Temporal(TIMESTAMP)
    Date dateCreated

    @Column(name = "last_updated", nullable = false)
    @Temporal(TIMESTAMP)
    Date lastUpdated
}

