package com.business.registry.service

import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.CountryI18nMapper
import com.business.registry.model.Country
import com.business.registry.model.CountryI18n
import com.business.registry.model.Language
import com.business.registry.repository.CountryI18nRepository
import com.business.registry.repository.CountryRepository
import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class CountryService {

    private final CountryRepository countryRepository
    private final CountryI18nRepository countryI18nRepository
    private final CountryI18nMapper countryI18nMapper

    @Autowired
    LanguageService languageService

    CountryService(CountryRepository countryRepository,
                   CountryI18nRepository countryI18nRepository,
                   CountryI18nMapper countryI18nMapper) {
        this.countryRepository = countryRepository
        this.countryI18nRepository = countryI18nRepository
        this.countryI18nMapper = countryI18nMapper
    }

    List<ParametricDto> findAllCountryTranslationsByLocale(Locale locale) {
        Language language = languageService.getLanguageFromLocale(locale)
        List<CountryI18n> i18nEntities = countryI18nRepository.findByLanguage(language)
        return countryI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findCountryTranslationByLocaleAndCountry(Locale locale, Country country) {
        Language language = languageService.getLanguageFromLocale(locale)
        CountryI18n i18nEntity = countryI18nRepository.findByCountryAndLanguage(country, language)
        return countryI18nMapper.toParametricDto(i18nEntity)
    }

    Country findCountryById(Long id) {
        return countryRepository.findById(id).orElse(null)
    }
}
