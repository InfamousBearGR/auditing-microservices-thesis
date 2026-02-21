package com.business.registry.repository

import com.business.registry.model.Currency
import com.business.registry.model.CurrencyI18n
import com.business.registry.model.Language
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CurrencyI18nRepository extends JpaRepository<CurrencyI18n, Long> {
    List<CurrencyI18n> findByLanguage(Language language)

    CurrencyI18n findByCurrencyAndLanguage(Currency currency, Language language)
}

