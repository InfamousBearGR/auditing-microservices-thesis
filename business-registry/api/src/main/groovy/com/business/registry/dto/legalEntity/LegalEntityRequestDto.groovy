package com.business.registry.dto.legalEntity

import groovy.transform.CompileStatic

@CompileStatic
class LegalEntityRequestDto {
    String gemiNumber
    String businessName
    String phoneNumber
    String afm
    String city
    String street
    Long countryId
    Long prefectureId
    Long municipalityId
    String streetNumber
    Long regionId
    String postalCode
    String changeReason
}
