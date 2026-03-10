package com.business.registry.validation

import com.business.registry.dto.companyStock.CompanyStockRequestDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyStockValidation implements Validatable {

    MessageService messageService

    @Override
    void validateFindById(Long id) {
        Utils.validateId(id, messageService)
    }

    @Override
    void validateDeleteById(Long id) {
        Utils.validateId(id, messageService)
    }

    void validateCompanyStockRequestDto(CompanyStockRequestDto companyStockRequestDto) {
        Utils.validateRequestNotNull(companyStockRequestDto, messageService)
        Utils.validateRequiredId(companyStockRequestDto.companyId, "Μη.έγκυρο.id.επιχείρησης", messageService)
        Utils.validateRequiredId(companyStockRequestDto.stockTypeId, "Μη.έγκυρο.id.τύπου.μετοχής", messageService)
        if (companyStockRequestDto.nominalPrice == null || companyStockRequestDto.nominalPrice.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρη.ονομαστική.αξία", [companyStockRequestDto.nominalPrice] as Object[]))
        }
        if (!Utils.validateBigDecimal(companyStockRequestDto.nominalPrice)) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρη.ονομαστική.αξία.Η.ονομαστική.αξία.μπορεί.να.έχει.μέχρι.δύο.δεκαδικά.ψηφία", [companyStockRequestDto.nominalPrice] as Object[]))
        }
        if (new BigDecimal(companyStockRequestDto.nominalPrice.trim()) < BigDecimal.ZERO) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρη.ονομαστική.αξία.Η.ονομαστική.αξία.δεν.μπορεί.να.είναι.αρνητικός.αριθμός", [companyStockRequestDto.nominalPrice] as Object[]))
        }
        if (companyStockRequestDto.amount == null || companyStockRequestDto.amount < 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρος.αριθμός.μετοχών", [companyStockRequestDto.amount] as Object[]))
        }
    }

    void validateUpdate(CompanyStockRequestDto companyStockRequestDto) {
        validateCompanyStockRequestDto(companyStockRequestDto)
    }
}
