package com.business.registry.dao

import com.business.registry.model.Currency
import com.business.registry.model.CurrencyI18n
import com.business.registry.repository.CurrencyI18nRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class CurrencyI18nDao {

    private final CurrencyI18nRepository currencyI18nRepository
    private final LanguageDao languageDao

    CurrencyI18nDao(CurrencyI18nRepository currencyI18nRepository, LanguageDao languageDao) {
        this.currencyI18nRepository = currencyI18nRepository
        this.languageDao = languageDao
    }

    List<CurrencyI18n> findAllCurrencyTranslationsByLocale(Locale locale) {
        return currencyI18nRepository.findByLanguage(languageDao.getLanguageFromLocale(locale))
    }

    CurrencyI18n findCurrencyTranslationByLocaleAndCurrency(Currency currency, Locale locale) {
        return currencyI18nRepository.findByCurrencyAndLanguage(currency, languageDao.getLanguageFromLocale(locale))
    }
}

