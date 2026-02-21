package com.business.registry.mapper.company

import com.business.registry.dto.company.CompanyResponseDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.Company
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyMapper {

    static CompanyResponseDto toCompanyDto(
            Company company,
            ParametricDto country,
            ParametricDto prefecture,
            ParametricDto municipality,
            ParametricDto region,
            ParametricDto legalType,
            ParametricDto companyStatus
    ) {
        if (company == null) {
            return null
        }
        new CompanyResponseDto(
                id: company.id,
                name: company.name,
                city: company.city,
                street: company.street,
                country: country,
                prefecture: prefecture,
                municipality: municipality,
                streetNumber: company.streetNumber,
                region: region,
                postalCode: company.postalCode,
                afm: company.afm,
                legalType: legalType,
                dateIncorporated: company.dateIncorporated?.toString(),
                registryNumber: company.registryNumber,
                companyStatus: companyStatus
        )
    }
}
