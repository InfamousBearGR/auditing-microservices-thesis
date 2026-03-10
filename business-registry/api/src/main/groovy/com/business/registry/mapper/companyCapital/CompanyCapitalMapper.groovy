package com.business.registry.mapper.companyCapital

import com.business.registry.dto.companyCapital.CompanyCapitalResponseDto
import com.business.registry.dto.companyStock.CompanyStockResponseDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.CompanyCapital
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyCapitalMapper {

    static CompanyCapitalResponseDto toCompanyCapitalResponse(
            CompanyCapital companyCapital,
            ParametricDto currency,
            List<CompanyStockResponseDto> stocks
    ) {
        if (companyCapital == null) {
            return null
        }
        new CompanyCapitalResponseDto(
                companyId: companyCapital.companyId,
                totalAmount: companyCapital.totalAmount?.toString(),
                currency: currency,
                stocks: stocks
        )
    }
}
