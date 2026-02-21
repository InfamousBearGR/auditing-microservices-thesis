package com.business.registry.model

import groovy.transform.CompileStatic
import jakarta.persistence.*
import jakarta.validation.constraints.NotBlank

@Entity
@Table(name = "stock_types")
@CompileStatic
class StockType {

     @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id

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

