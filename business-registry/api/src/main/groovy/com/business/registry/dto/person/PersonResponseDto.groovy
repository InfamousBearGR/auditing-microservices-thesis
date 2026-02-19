package com.business.registry.dto.person

import com.business.registry.dto.util.ParametricDto
import groovy.transform.CompileStatic

@CompileStatic
class PersonResponseDto {
    Long id
    String name
    String surname
    String afm
    String city
    String street
    ParametricDto country
    ParametricDto prefecture
    ParametricDto municipality
    String streetNumber
    ParametricDto region
    String postalCode
    String birthDate
    String birthPlace
    String identityNumber
    String phoneNumber
    String changeReason
}
