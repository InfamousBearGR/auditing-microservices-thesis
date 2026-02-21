package com.business.registry.dao

import com.business.registry.model.StockType
import com.business.registry.model.StockTypeI18n
import com.business.registry.repository.StockTypeI18nRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class StockTypeI18nDao {

    private final StockTypeI18nRepository stockTypeI18nRepository
    private final LanguageDao languageDao

    StockTypeI18nDao(StockTypeI18nRepository stockTypeI18nRepository, LanguageDao languageDao) {
        this.stockTypeI18nRepository = stockTypeI18nRepository
        this.languageDao = languageDao
    }

    List<StockTypeI18n> findAllStockTypeTranslationsByLocale(Locale locale) {
        return stockTypeI18nRepository.findByLanguage(languageDao.getLanguageFromLocale(locale))
    }

    StockTypeI18n findStockTypeTranslationByLocaleAndStockType(StockType stockType, Locale locale) {
        return stockTypeI18nRepository.findByStockTypeAndLanguage(stockType, languageDao.getLanguageFromLocale(locale))
    }
}

