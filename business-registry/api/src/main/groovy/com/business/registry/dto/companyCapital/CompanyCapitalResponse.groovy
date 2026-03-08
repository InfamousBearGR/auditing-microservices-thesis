package com.business.registry.dto.companyCapital

import com.business.registry.dto.companyStock.CompanyStockResponse
import com.business.registry.dto.util.ParametricDto
import groovy.transform.CompileStatic

@CompileStatic
class CompanyCapitalResponse {
    Long companyId
    String totalAmount
    ParametricDto currency
    String changeReason
    List<CompanyStockResponse> stocks
}
