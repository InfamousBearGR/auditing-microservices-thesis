package com.business.registry.service

import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.CompanyStatusI18nMapper
import com.business.registry.model.CompanyStatus
import com.business.registry.model.CompanyStatusI18n
import com.business.registry.model.Language
import com.business.registry.repository.CompanyStatusI18nRepository
import com.business.registry.repository.CompanyStatusRepository
import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class CompanyStatusService {

    private final CompanyStatusRepository companyStatusRepository
    private final CompanyStatusI18nRepository companyStatusI18nRepository
    private final CompanyStatusI18nMapper companyStatusI18nMapper

    @Autowired
    LanguageService languageService

    CompanyStatusService(CompanyStatusRepository companyStatusRepository,
                         CompanyStatusI18nRepository companyStatusI18nRepository,
                         CompanyStatusI18nMapper companyStatusI18nMapper) {
        this.companyStatusRepository = companyStatusRepository
        this.companyStatusI18nRepository = companyStatusI18nRepository
        this.companyStatusI18nMapper = companyStatusI18nMapper
    }

    List<ParametricDto> findAllCompanyStatusTranslationsByLocale(Locale locale) {
        Language language = languageService.getLanguageFromLocale(locale)
        List<CompanyStatusI18n> i18nEntities = companyStatusI18nRepository.findByLanguage(language)
        return companyStatusI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findCompanyStatusTranslationByLocaleAndCompanyStatus(Locale locale, CompanyStatus companyStatus) {
        Language language = languageService.getLanguageFromLocale(locale)
        CompanyStatusI18n i18nEntity = companyStatusI18nRepository.findByCompanyStatusAndLanguage(companyStatus, language)
        return companyStatusI18nMapper.toParametricDto(i18nEntity)
    }

    CompanyStatus findCompanyStatusById(Long id) {
        return companyStatusRepository.findById(id).orElse(null)
    }
}

