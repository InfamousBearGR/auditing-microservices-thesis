package com.business.registry.dao

import com.business.registry.model.CompanyStatus
import com.business.registry.model.CompanyStatusI18n
import com.business.registry.model.Language
import com.business.registry.repository.CompanyStatusI18nRepository
import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class CompanyStatusI18nDao {

    private final CompanyStatusI18nRepository companyStatusI18nRepository

    CompanyStatusI18nDao(
            CompanyStatusI18nRepository companyStatusI18nRepository
    ) {
        this.companyStatusI18nRepository = companyStatusI18nRepository
    }

    @Autowired
    private LanguageDao languageDao

    List<CompanyStatusI18n> findAllCompanyStatusTranslationsByLocale(Locale locale) {
        Language language = languageDao.getLanguageFromLocale(locale)
        return companyStatusI18nRepository.findByLanguage(language)
    }

    CompanyStatusI18n findCompanyStatusTranslationByLocaleAndCompanyStatus(CompanyStatus companyStatus, Locale locale) {
        Language language = languageDao.getLanguageFromLocale(locale)
        return companyStatusI18nRepository.findByCompanyStatusAndLanguage(companyStatus, language)
    }
}
