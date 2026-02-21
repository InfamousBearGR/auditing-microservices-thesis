package com.business.registry.service

import com.business.registry.dao.CompanyStatusDao
import com.business.registry.dao.CompanyStatusI18nDao
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.CompanyStatusI18nMapper
import com.business.registry.model.CompanyStatus
import com.business.registry.model.CompanyStatusI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class CompanyStatusService {

    private final CompanyStatusI18nDao companyStatusI18nDao
    private final CompanyStatusDao companyStatusDao
    private final CompanyStatusI18nMapper companyStatusI18nMapper


    CompanyStatusService(
            CompanyStatusI18nMapper companyStatusI18nMapper,
            CompanyStatusI18nDao companyStatusI18nDao,
            CompanyStatusDao companyStatusDao
    ) {
        this.companyStatusI18nMapper = companyStatusI18nMapper
        this.companyStatusI18nDao = companyStatusI18nDao
        this.companyStatusDao = companyStatusDao
    }

    List<ParametricDto> findAllCompanyStatusTranslationsByLocale(Locale locale) {
        List<CompanyStatusI18n> i18nEntities = companyStatusI18nDao.findAllCompanyStatusTranslationsByLocale(locale)
        return companyStatusI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findCompanyStatusTranslationByLocaleAndCompanyStatus(Locale locale, CompanyStatus companyStatus) {
        CompanyStatusI18n i18nEntity = companyStatusI18nDao.findCompanyStatusTranslationByLocaleAndCompanyStatus(companyStatus, locale)
        return companyStatusI18nMapper.toParametricDto(i18nEntity)
    }

    CompanyStatus findCompanyStatusById(Long id) {
        return companyStatusDao.findCompanyStatusById(id)
    }
}

