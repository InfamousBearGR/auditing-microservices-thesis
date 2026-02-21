package com.business.registry.dao

import com.business.registry.model.Country
import com.business.registry.model.CountryI18n
import com.business.registry.repository.CountryI18nRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class CountryI18nDao {

    private final CountryI18nRepository countryI18nRepository
    private final LanguageDao languageDao

    CountryI18nDao(CountryI18nRepository countryI18nRepository, LanguageDao languageDao) {
        this.countryI18nRepository = countryI18nRepository
        this.languageDao = languageDao
    }

    List<CountryI18n> findAllCountryTranslationsByLocale(Locale locale) {
        return countryI18nRepository.findByLanguage(languageDao.getLanguageFromLocale(locale))
    }

    CountryI18n findCountryTranslationByLocaleAndCountry(Country country, Locale locale) {
        return countryI18nRepository.findByCountryAndLanguage(country, languageDao.getLanguageFromLocale(locale))
    }
}

