package com.business.registry.dto.person

import groovy.transform.CompileStatic

@CompileStatic
class PersonRequestDto {
    String name
    String surname
    String afm
    String city
    String street
    Long countryId
    Long prefectureId
    Long municipalityId
    String streetNumber
    Long regionId
    String postalCode
    String birthDate
    String birthPlace
    String identityNumber
    String phoneNumber
    String changeReason
}
