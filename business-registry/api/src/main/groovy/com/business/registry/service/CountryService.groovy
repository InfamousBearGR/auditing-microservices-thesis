package com.business.registry.service

import com.business.registry.dao.CountryDao
import com.business.registry.dao.CountryI18nDao
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.CountryI18nMapper
import com.business.registry.model.Country
import com.business.registry.model.CountryI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class CountryService {

    private final CountryDao countryDao
    private final CountryI18nDao countryI18nDao
    private final CountryI18nMapper countryI18nMapper

    CountryService(CountryDao countryDao,
                   CountryI18nDao countryI18nDao,
                   CountryI18nMapper countryI18nMapper) {
        this.countryDao = countryDao
        this.countryI18nDao = countryI18nDao
        this.countryI18nMapper = countryI18nMapper
    }

    List<ParametricDto> findAllCountryTranslationsByLocale(Locale locale) {
        List<CountryI18n> i18nEntities = countryI18nDao.findAllCountryTranslationsByLocale(locale)
        return countryI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findCountryTranslationByLocaleAndCountry(Locale locale, Country country) {
        CountryI18n i18nEntity = countryI18nDao.findCountryTranslationByLocaleAndCountry(country, locale)
        return countryI18nMapper.toParametricDto(i18nEntity)
    }

    Country findCountryById(Long id) {
        return countryDao.findCountryById(id)
    }
}
