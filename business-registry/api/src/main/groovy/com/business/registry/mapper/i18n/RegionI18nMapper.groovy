package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.RegionI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class RegionI18nMapper implements I18nMapper<RegionI18n> {

    @Override
    ParametricDto toParametricDto(RegionI18n regionI18n) {
        if (regionI18n == null) {
            return null
        }
        new ParametricDto(
                id: regionI18n.region.id,
                description: regionI18n.description
        )
    }

    @Override
    List<ParametricDto> toParametricDtoList(Collection<RegionI18n> i18nEntities) {
        if (i18nEntities == null) {
            return []
        }
        i18nEntities.collect { toParametricDto(it) }
    }
}

