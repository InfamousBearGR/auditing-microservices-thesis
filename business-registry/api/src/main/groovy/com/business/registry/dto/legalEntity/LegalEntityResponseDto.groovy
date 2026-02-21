package com.business.registry.dto.legalEntity

import com.business.registry.dto.util.ParametricDto
import groovy.transform.CompileStatic

@CompileStatic
class LegalEntityResponseDto {
    Long id
    String registryNumber
    String businessName
    String phoneNumber
    String afm
    String city
    String street
    ParametricDto country
    ParametricDto prefecture
    ParametricDto municipality
    String streetNumber
    ParametricDto region
    String postalCode
}
