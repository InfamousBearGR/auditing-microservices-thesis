package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.StockTypeI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class StockTypeI18nMapper implements I18nMapper<StockTypeI18n> {

    @Override
    ParametricDto toParametricDto(StockTypeI18n stockTypeI18n) {
        if (stockTypeI18n == null) {
            return null
        }
        new ParametricDto(
                id: stockTypeI18n.stockType.id,
                description: stockTypeI18n.description
        )
    }

    @Override
    List<ParametricDto> toParametricDtoList(Collection<StockTypeI18n> i18nEntities) {
        if (i18nEntities == null) {
            return []
        }
        i18nEntities.collect { toParametricDto(it) }
    }
}
