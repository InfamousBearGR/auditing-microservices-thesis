package com.business.registry.dto.company

import groovy.transform.CompileStatic

@CompileStatic
class CompanyRequestDto {
    String name
    String city
    String street
    Long countryId
    Long prefectureId
    Long municipalityId
    String streetNumber
    Long regionId
    String postalCode
    String afm
    Long legalTypeId
    String dateIncorporated
    String registryNumber
    Long companyStatusId
    String changeReason
}
