package com.business.registry.dto.member

import com.business.registry.dto.util.ParametricDto
import groovy.transform.CompileStatic

@CompileStatic
class MemberResponseDto {
    Long id
    Boolean active
    String dateFrom
    String dateTo
    String percentageOfOwnership
    PersonDto person
    LegalEntityDto legalEntity
    PersonDto representativeOfMember
    Boolean representedIndividual
    Boolean representedTogether
    ParametricDto memberRelation
}
