package com.business.registry.mapper.companyCapital

import com.business.registry.dto.companyCapital.CompanyCapitalResponse
import com.business.registry.dto.companyStock.CompanyStockResponse
import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.CompanyCapital
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyCapitalMapper {

    static CompanyCapitalResponse toCompanyCapitalResponse(
            CompanyCapital companyCapital,
            ParametricDto currency,
            List<CompanyStockResponse> stocks
    ) {
        if (companyCapital == null) {
            return null
        }
        new CompanyCapitalResponse(
                companyId: companyCapital.companyId,
                totalAmount: companyCapital.totalAmount?.toString(),
                currency: currency,
                changeReason: companyCapital.changeReason,
                stocks: stocks
        )
    }
}
