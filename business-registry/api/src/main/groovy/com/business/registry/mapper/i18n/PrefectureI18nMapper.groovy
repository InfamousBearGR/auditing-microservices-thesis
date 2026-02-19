package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.PrefectureI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class PrefectureI18nMapper implements I18nMapper<PrefectureI18n> {

    @Override
    ParametricDto toParametricDto(PrefectureI18n prefectureI18n) {
        if (prefectureI18n == null) {
            return null
        }
        new ParametricDto(
                id: prefectureI18n.prefecture.id,
                description: prefectureI18n.description
        )
    }

    @Override
    List<ParametricDto> toParametricDtoList(Collection<PrefectureI18n> i18nEntities) {
        if (i18nEntities == null) {
            return []
        }
        i18nEntities.collect { toParametricDto(it) }
    }
}

