package com.business.registry.dto.companyCapital

import com.business.registry.dto.companyStock.CompanyStockRequestDto
import groovy.transform.CompileStatic

@CompileStatic
class CompanyCapitalRequestDto {
    Long companyId
    String totalAmount
    Long currencyId
    String changeReason
    List<CompanyStockRequestDto> stocks
}
