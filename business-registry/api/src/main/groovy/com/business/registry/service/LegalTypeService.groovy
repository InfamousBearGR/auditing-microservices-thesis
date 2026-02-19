package com.business.registry.service

import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.LegalTypeI18nMapper
import com.business.registry.model.Language
import com.business.registry.model.LegalType
import com.business.registry.model.LegalTypeI18n
import com.business.registry.repository.LegalTypeI18nRepository
import com.business.registry.repository.LegalTypeRepository
import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class LegalTypeService {

    private final LegalTypeRepository legalTypeRepository
    private final LegalTypeI18nRepository legalTypeI18nRepository
    private final LegalTypeI18nMapper legalTypeI18nMapper

    @Autowired
    LanguageService languageService

    LegalTypeService(LegalTypeRepository legalTypeRepository,
                     LegalTypeI18nRepository legalTypeI18nRepository,
                     LegalTypeI18nMapper legalTypeI18nMapper) {
        this.legalTypeRepository = legalTypeRepository
        this.legalTypeI18nRepository = legalTypeI18nRepository
        this.legalTypeI18nMapper = legalTypeI18nMapper
    }

    List<ParametricDto> findAllLegalTypeTranslationsByLocale(Locale locale) {
        Language language = languageService.getLanguageFromLocale(locale)
        List<LegalTypeI18n> i18nEntities = legalTypeI18nRepository.findByLanguage(language)
        return legalTypeI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findLegalTypeTranslationByLocaleAndLegalType(Locale locale, LegalType legalType) {
        Language language = languageService.getLanguageFromLocale(locale)
        LegalTypeI18n i18nEntity = legalTypeI18nRepository.findByLegalTypeAndLanguage(legalType, language)
        return legalTypeI18nMapper.toParametricDto(i18nEntity)
    }

    LegalType findLegalTypeById(Long id) {
        return legalTypeRepository.findById(id).orElse(null)
    }
}
