package com.business.registry.service

import com.business.registry.model.Language
import com.business.registry.repository.LanguageRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class LanguageService {

    private final LanguageRepository languageRepository

    LanguageService(LanguageRepository languageRepository) {
        this.languageRepository = languageRepository
    }

    Language getLanguageFromLocale(Locale locale) {
        return languageRepository.findByCode(locale?.language)
    }
}

