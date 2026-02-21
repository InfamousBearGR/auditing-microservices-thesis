package com.business.registry.service

import com.business.registry.dao.CurrencyI18nDao
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.CurrencyI18nMapper
import com.business.registry.model.CurrencyI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service

@CompileStatic
@Service
class CurrencyService {

    private final CurrencyI18nDao currencyI18nDao
    private final CurrencyI18nMapper currencyI18nMapper

    CurrencyService(
            CurrencyI18nDao currencyI18nDao,
            CurrencyI18nMapper currencyI18nMapper
    ) {
        this.currencyI18nDao = currencyI18nDao
        this.currencyI18nMapper = currencyI18nMapper
    }

    List<ParametricDto> findAllCurrencyTranslationsByLocale(Locale locale) {
        List<CurrencyI18n> i18nEntities = currencyI18nDao.findAllCurrencyTranslationsByLocale(locale)
        return currencyI18nMapper.toParametricDtoList(i18nEntities)
    }
}

