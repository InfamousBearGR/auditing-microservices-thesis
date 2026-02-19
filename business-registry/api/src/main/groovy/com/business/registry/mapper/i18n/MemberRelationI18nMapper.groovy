package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.MemberRelationI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class MemberRelationI18nMapper implements I18nMapper<MemberRelationI18n> {

    @Override
    ParametricDto toParametricDto(MemberRelationI18n memberRelationI18n) {
        if (memberRelationI18n == null) {
            return null
        }
        new ParametricDto(
                id: memberRelationI18n.memberRelation.id,
                description: memberRelationI18n.description
        )
    }

    @Override
    List<ParametricDto> toParametricDtoList(Collection<MemberRelationI18n> i18nEntities) {
        if (i18nEntities == null) {
            return []
        }
        i18nEntities.collect { toParametricDto(it) }
    }
}

