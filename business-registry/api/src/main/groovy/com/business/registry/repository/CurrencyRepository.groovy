package com.business.registry.repository

import com.business.registry.model.Currency
import org.springframework.data.jpa.repository.JpaRepository

interface CurrencyRepository extends JpaRepository<Currency, Long> {
}