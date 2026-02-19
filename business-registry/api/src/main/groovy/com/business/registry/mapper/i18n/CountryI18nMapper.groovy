package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.CountryI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CountryI18nMapper implements I18nMapper<CountryI18n> {

    @Override
    ParametricDto toParametricDto(CountryI18n countryI18n) {
        if (countryI18n == null) {
            return null
        }
        new ParametricDto(
                id: countryI18n.country.id,
                description: countryI18n.description
        )
    }

    @Override
    List<ParametricDto> toParametricDtoList(Collection<CountryI18n> i18nEntities) {
        if (i18nEntities == null) {
            return []
        }
        i18nEntities.collect { toParametricDto(it) }
    }
}

