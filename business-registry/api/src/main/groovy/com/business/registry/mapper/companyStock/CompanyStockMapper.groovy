package com.business.registry.mapper.companyStock

import com.business.registry.dto.companyStock.CompanyStockResponseDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.CompanyStock
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyStockMapper {

    static CompanyStockResponseDto toCompanyStockResponse(
            CompanyStock companyStock,
            ParametricDto stockType
    ) {
        if (companyStock == null) {
            return null
        }
        new CompanyStockResponseDto(
                id: companyStock.id,
                companyId: companyStock.companyId,
                stockType: stockType,
                nominalPrice: companyStock.nominalPrice,
                amount: companyStock.amount
        )
    }
}
