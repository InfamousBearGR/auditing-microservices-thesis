package com.business.registry.dto.companyCapital

import com.business.registry.dto.companyStock.CompanyStockResponseDto
import com.business.registry.dto.util.ParametricDto
import groovy.transform.CompileStatic

@CompileStatic
class CompanyCapitalResponseDto {
    Long companyId
    String totalAmount
    ParametricDto currency
    List<CompanyStockResponseDto> stocks
}
