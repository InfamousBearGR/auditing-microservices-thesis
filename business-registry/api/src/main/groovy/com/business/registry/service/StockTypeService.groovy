package com.business.registry.service

import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.StockTypeI18nMapper
import com.business.registry.model.Language
import com.business.registry.model.StockType
import com.business.registry.model.StockTypeI18n
import com.business.registry.repository.LanguageRepository
import com.business.registry.repository.StockTypeI18nRepository
import com.business.registry.repository.StockTypeRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service

@CompileStatic
@Service
class StockTypeService {

    private final StockTypeI18nRepository stockTypeI18nRepository
    private final StockTypeI18nMapper stockTypeI18nMapper
    private final StockTypeRepository stockTypeRepository
    private final LanguageRepository languageRepository

    StockTypeService(
            StockTypeI18nRepository stockTypeI18nRepository,
            StockTypeI18nMapper stockTypeI18nMapper,
            StockTypeRepository stockTypeRepository,
            LanguageRepository languageRepository
    ) {
        this.stockTypeI18nRepository = stockTypeI18nRepository
        this.stockTypeI18nMapper = stockTypeI18nMapper
        this.stockTypeRepository = stockTypeRepository
        this.languageRepository = languageRepository
    }

    List<ParametricDto> findAllStockTypeTranslationsByLocale(Locale locale) {
        Language language = languageRepository.findByCode(locale?.language)
        List<StockTypeI18n> i18nEntities = stockTypeI18nRepository.findByLanguage(language)
        return stockTypeI18nMapper.toParametricDtoList(i18nEntities)
    }

    StockType findStockTypeById(Long id) {
        return stockTypeRepository.findById(id).orElse(null)
    }

    ParametricDto findStockTypeTranslationByLocaleAndStockType(Locale locale, StockType stockType) {
        Language language = languageRepository.findByCode(locale?.language)
        StockTypeI18n i18nEntity = stockTypeI18nRepository.findByStockTypeAndLanguage(stockType, language)
        return stockTypeI18nMapper.toParametricDto(i18nEntity)
    }
}

