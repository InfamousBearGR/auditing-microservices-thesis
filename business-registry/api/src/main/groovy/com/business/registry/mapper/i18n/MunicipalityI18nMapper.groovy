package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.MunicipalityI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class MunicipalityI18nMapper implements I18nMapper<MunicipalityI18n> {

    @Override
    ParametricDto toParametricDto(MunicipalityI18n municipalityI18n) {
        if (municipalityI18n == null) {
            return null
        }
        new ParametricDto(
                id: municipalityI18n.municipality.id,
                description: municipalityI18n.description
        )
    }

    @Override
    List<ParametricDto> toParametricDtoList(Collection<MunicipalityI18n> i18nEntities) {
        if (i18nEntities == null) {
            return []
        }
        i18nEntities.collect { toParametricDto(it) }
    }
}

