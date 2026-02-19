package com.business.registry.dto.company

import com.business.registry.dto.util.ParametricDto
import groovy.transform.CompileStatic

@CompileStatic
class CompanyResponseDto {
    Long id
    String name
    String city
    String street
    ParametricDto country
    ParametricDto prefecture
    ParametricDto municipality
    String streetNumber
    ParametricDto region
    String postalCode
    String afm
    ParametricDto legalType
    String dateIncorporated
    String gemiNumber
    ParametricDto companyStatus
}
