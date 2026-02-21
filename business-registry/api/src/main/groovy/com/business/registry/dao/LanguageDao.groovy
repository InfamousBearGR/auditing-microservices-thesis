package com.business.registry.dao

import com.business.registry.model.Language
import com.business.registry.repository.LanguageRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class LanguageDao {
    private final LanguageRepository languageRepository

    LanguageDao(LanguageRepository languageRepository) {
        this.languageRepository = languageRepository
    }

    Language getLanguageFromLocale(Locale locale) {
        return languageRepository.findByCode(locale?.language)
    }
}
