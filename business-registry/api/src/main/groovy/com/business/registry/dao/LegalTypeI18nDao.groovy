package com.business.registry.dao

import com.business.registry.model.LegalType
import com.business.registry.model.LegalTypeI18n
import com.business.registry.repository.LegalTypeI18nRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class LegalTypeI18nDao {

    private final LegalTypeI18nRepository legalTypeI18nRepository
    private final LanguageDao languageDao

    LegalTypeI18nDao(LegalTypeI18nRepository legalTypeI18nRepository, LanguageDao languageDao) {
        this.legalTypeI18nRepository = legalTypeI18nRepository
        this.languageDao = languageDao
    }

    List<LegalTypeI18n> findAllLegalTypeTranslationsByLocale(Locale locale) {
        return legalTypeI18nRepository.findByLanguage(languageDao.getLanguageFromLocale(locale))
    }

    LegalTypeI18n findLegalTypeTranslationByLocaleAndLegalType(LegalType legalType, Locale locale) {
        return legalTypeI18nRepository.findByLegalTypeAndLanguage(legalType, languageDao.getLanguageFromLocale(locale))
    }
}

