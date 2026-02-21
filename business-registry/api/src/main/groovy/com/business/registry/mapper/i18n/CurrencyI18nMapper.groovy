package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.CurrencyI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CurrencyI18nMapper implements I18nMapper<CurrencyI18n> {

    @Override
    ParametricDto toParametricDto(CurrencyI18n currencyI18n) {
        if (currencyI18n == null) {
            return null
        }
        new ParametricDto(
                id: currencyI18n.currency.id,
                description: currencyI18n.description
        )
    }

    @Override
    List<ParametricDto> toParametricDtoList(Collection<CurrencyI18n> i18nEntities) {
        if (i18nEntities == null) {
            return []
        }
        i18nEntities.collect { toParametricDto(it) }
    }
}
