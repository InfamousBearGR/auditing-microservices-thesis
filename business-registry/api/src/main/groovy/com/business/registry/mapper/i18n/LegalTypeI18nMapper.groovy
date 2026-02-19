package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.LegalTypeI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class LegalTypeI18nMapper implements I18nMapper<LegalTypeI18n> {

    @Override
    ParametricDto toParametricDto(LegalTypeI18n legalTypeI18n) {
        if (legalTypeI18n == null) {
            return null
        }
        new ParametricDto(
                id: legalTypeI18n.legalType.id,
                description: legalTypeI18n.description
        )
    }

    @Override
    List<ParametricDto> toParametricDtoList(Collection<LegalTypeI18n> i18nEntities) {
        if (i18nEntities == null) {
            return []
        }
        i18nEntities.collect { toParametricDto(it) }
    }
}

