package com.business.registry.dto.companyStock

import groovy.transform.CompileStatic

@CompileStatic
class CompanyStockRequestDto {
    Long id
    Long companyId
    Long stockTypeId
    Long amount
    String nominalPrice
    Boolean toBeDeleted
}
