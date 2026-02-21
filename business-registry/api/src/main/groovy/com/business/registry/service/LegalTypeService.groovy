package com.business.registry.service

import com.business.registry.dao.LegalTypeDao
import com.business.registry.dao.LegalTypeI18nDao
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.LegalTypeI18nMapper
import com.business.registry.model.LegalType
import com.business.registry.model.LegalTypeI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class LegalTypeService {

    private final LegalTypeDao legalTypeDao
    private final LegalTypeI18nDao legalTypeI18nDao
    private final LegalTypeI18nMapper legalTypeI18nMapper

    LegalTypeService(LegalTypeDao legalTypeDao,
                     LegalTypeI18nDao legalTypeI18nDao,
                     LegalTypeI18nMapper legalTypeI18nMapper) {
        this.legalTypeDao = legalTypeDao
        this.legalTypeI18nDao = legalTypeI18nDao
        this.legalTypeI18nMapper = legalTypeI18nMapper
    }

    List<ParametricDto> findAllLegalTypeTranslationsByLocale(Locale locale) {
        List<LegalTypeI18n> i18nEntities = legalTypeI18nDao.findAllLegalTypeTranslationsByLocale(locale)
        return legalTypeI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findLegalTypeTranslationByLocaleAndLegalType(Locale locale, LegalType legalType) {
        LegalTypeI18n i18nEntity = legalTypeI18nDao.findLegalTypeTranslationByLocaleAndLegalType(legalType, locale)
        return legalTypeI18nMapper.toParametricDto(i18nEntity)
    }

    LegalType findLegalTypeById(Long id) {
        return legalTypeDao.findLegalTypeById(id)
    }
}
