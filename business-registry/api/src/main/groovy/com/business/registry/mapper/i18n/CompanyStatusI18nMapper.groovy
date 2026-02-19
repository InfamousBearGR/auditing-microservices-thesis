package com.business.registry.mapper.i18n

import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.CompanyStatusI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyStatusI18nMapper implements I18nMapper<CompanyStatusI18n> {

    @Override
    ParametricDto toParametricDto(CompanyStatusI18n companyStatusI18n) {
        if (companyStatusI18n == null) {
            return null
        }
        new ParametricDto(
                id: companyStatusI18n.companyStatus.id,
                description: companyStatusI18n.description
        )
    }

    @Override
    List<ParametricDto> toParametricDtoList(Collection<CompanyStatusI18n> i18nEntities) {
        if (i18nEntities == null) {
            return []
        }
        i18nEntities.collect { toParametricDto(it) }
    }
}

