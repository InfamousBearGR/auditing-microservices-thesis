package com.business.registry.service

import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.CurrencyI18nMapper
import com.business.registry.model.Currency
import com.business.registry.model.CurrencyI18n
import com.business.registry.model.Language
import com.business.registry.repository.CurrencyI18nRepository
import com.business.registry.repository.CurrencyRepository
import com.business.registry.repository.LanguageRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service

@CompileStatic
@Service
class CurrencyService {

    private final CurrencyI18nRepository currencyI18nRepository
    private final CurrencyI18nMapper currencyI18nMapper
    private final CurrencyRepository currencyRepository
    private final LanguageRepository languageRepository

    CurrencyService(
            CurrencyI18nRepository currencyI18nRepository,
            CurrencyI18nMapper currencyI18nMapper,
            CurrencyRepository currencyRepository,
            LanguageRepository languageRepository
    ) {
        this.currencyI18nRepository = currencyI18nRepository
        this.currencyI18nMapper = currencyI18nMapper
        this.currencyRepository = currencyRepository
        this.languageRepository = languageRepository
    }

    List<ParametricDto> findAllCurrencyTranslationsByLocale(Locale locale) {
        Language language = languageRepository.findByCode(locale?.language)
        List<CurrencyI18n> i18nEntities = currencyI18nRepository.findByLanguage(language)
        return currencyI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findCurrencyTranslationByLocaleAndCurrency(Locale locale, Currency currency) {
        Language language = languageRepository.findByCode(locale?.language)
        CurrencyI18n i18nEntity = currencyI18nRepository.findByCurrencyAndLanguage(currency, language)
        return currencyI18nMapper.toParametricDto(i18nEntity)
    }

    Currency findCurrencyById(Long id) {
        return currencyRepository.findById(id).orElse(null)
    }
}

