package com.business.registry.mapper.companyStock

import com.business.registry.dto.companyStock.CompanyStockResponse
import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.CompanyStock
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyStockMapper {

    static CompanyStockResponse toCompanyStockResponse(
            CompanyStock companyStock,
            ParametricDto stockType
    ) {
        if (companyStock == null) {
            return null
        }
        new CompanyStockResponse(
                id: companyStock.id,
                companyId: companyStock.companyId,
                stockType: stockType,
                nominalPrice: companyStock.nominalPrice,
                amount: companyStock.amount
        )
    }
}
