package com.business.registry.service

import com.business.registry.dao.StockTypeI18nDao
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.StockTypeI18nMapper
import com.business.registry.model.StockTypeI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service


@CompileStatic
@Service
class StockTypeService {

    private final StockTypeI18nDao stockTypeI18nDao
    private final StockTypeI18nMapper stockTypeI18nMapper

    StockTypeService(
            StockTypeI18nDao stockTypeI18nDao,
            StockTypeI18nMapper stockTypeI18nMapper
    ) {
        this.stockTypeI18nDao = stockTypeI18nDao
        this.stockTypeI18nMapper = stockTypeI18nMapper
    }

    List<ParametricDto> findAllStockTypeTranslationsByLocale(Locale locale) {
        List<StockTypeI18n> i18nEntities = stockTypeI18nDao.findAllStockTypeTranslationsByLocale(locale)
        return stockTypeI18nMapper.toParametricDtoList(i18nEntities)
    }

}

