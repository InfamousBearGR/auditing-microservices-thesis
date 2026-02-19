package com.business.registry.mapper.legalEntity

import com.business.registry.dto.legalEntity.LegalEntityResponseDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.LegalEntity
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class LegalEntityMapper {

    static LegalEntityResponseDto toLegalEntityDto(
            LegalEntity legalEntity,
            ParametricDto country,
            ParametricDto prefecture,
            ParametricDto municipality,
            ParametricDto region
    ) {
        if (legalEntity == null) {
            return null
        }
        new LegalEntityResponseDto(
                id: legalEntity.id,
                gemiNumber: legalEntity.gemiNumber,
                businessName: legalEntity.businessName,
                phoneNumber: legalEntity.phoneNumber,
                afm: legalEntity.afm,
                city: legalEntity.city,
                street: legalEntity.street,
                country: country,
                prefecture: prefecture,
                municipality: municipality,
                streetNumber: legalEntity.streetNumber,
                region: region,
                postalCode: legalEntity.postalCode
        )
    }
}
