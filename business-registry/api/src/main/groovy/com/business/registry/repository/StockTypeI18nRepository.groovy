package com.business.registry.repository

import com.business.registry.model.Language
import com.business.registry.model.StockType
import com.business.registry.model.StockTypeI18n
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface StockTypeI18nRepository extends JpaRepository<StockTypeI18n, Long> {
    List<StockTypeI18n> findByLanguage(Language language)

    StockTypeI18n findByStockTypeAndLanguage(StockType stockType, Language language)
}

