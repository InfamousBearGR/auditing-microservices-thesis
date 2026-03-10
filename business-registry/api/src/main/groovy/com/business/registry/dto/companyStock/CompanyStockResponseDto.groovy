package com.business.registry.dto.companyStock

import com.business.registry.dto.util.ParametricDto
import groovy.transform.CompileStatic

@CompileStatic
class CompanyStockResponseDto {
    Long id
    Long companyId
    Long amount
    ParametricDto stockType
    BigDecimal nominalPrice
}
