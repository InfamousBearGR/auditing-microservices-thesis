package com.business.registry.dto.member

import groovy.transform.CompileStatic

@CompileStatic
class MemberRequestDto {
    Boolean active
    String dateFrom
    String dateTo
    String percentageOfOwnership
    Long personId
    Long legalEntityId
    Long companyId
    Long representativeOfMemberId
    Boolean representedIndividual
    Boolean representedTogether
    Long memberRelationId
    String changeReason
}
