package com.business.registry.validation

import com.business.registry.dto.companyCapital.CompanyCapitalRequestDto
import com.business.registry.dto.companyStock.CompanyStockRequestDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyCapitalValidation implements Validatable {

    MessageService messageService

    @Override
    void validateFindById(Long id) {
        Utils.validateId(id, messageService)
    }

    @Override
    void validateDeleteById(Long id) {
        Utils.validateId(id, messageService)
    }

    void validateCompanyCapitalRequestDto(CompanyCapitalRequestDto companyCapitalRequestDto) {
        Utils.validateRequestNotNull(companyCapitalRequestDto, messageService)
        Utils.validateRequiredId(companyCapitalRequestDto.companyId, "Μη.έγκυρο.id.επιχείρησης", messageService)
        if (companyCapitalRequestDto.totalAmount == null || companyCapitalRequestDto.totalAmount.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.ποσό", [companyCapitalRequestDto.totalAmount] as Object[]))
        }
        if (!Utils.validateBigDecimal(companyCapitalRequestDto.totalAmount)) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.ποσό.Το.τρέχον.κεφάλαιο.μπορεί.να.έχει.μέχρι.δύο.δεκαδικά.ψηφία", [companyCapitalRequestDto.totalAmount] as Object[]))
        }
        if (new BigDecimal(companyCapitalRequestDto.totalAmount.trim()) < BigDecimal.ZERO) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.ποσό.Το.τρέχον.κεφάλαιο.δεν.μπορεί.να.είναι.αρνητικός.αριθμός", [companyCapitalRequestDto.totalAmount] as Object[]))
        }
        Utils.validateRequiredId(companyCapitalRequestDto.currencyId, "Μη.έγκυρο.id.νομίσματος", messageService)
        Utils.validateChangeReason(companyCapitalRequestDto.changeReason, messageService)
        validateStocksTotalMatchesCapital(companyCapitalRequestDto)
    }

    void validateStocksTotalMatchesCapital(CompanyCapitalRequestDto companyCapitalRequestDto) {
        List<CompanyStockRequestDto> activeStocks = (companyCapitalRequestDto.stocks ?: [])
                .findAll { CompanyStockRequestDto s -> !s.toBeDeleted }
        BigDecimal stocksTotal = activeStocks.inject(BigDecimal.ZERO) { BigDecimal acc, CompanyStockRequestDto s ->
            if (s.nominalPrice == null || s.nominalPrice.trim().isEmpty() || !Utils.validateBigDecimal(s.nominalPrice)) {
                throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρη.τιμή.μετοχής"))
            }
            if (s.amount == null || s.amount < 0) {
                throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρος.αριθμός.μετοχών"))
            }
            acc + new BigDecimal(s.nominalPrice.trim()) * new BigDecimal(s.amount)
        } as BigDecimal
        BigDecimal totalAmount = new BigDecimal(companyCapitalRequestDto.totalAmount.trim())
        if (stocksTotal != totalAmount) {
            throw new IllegalArgumentException(messageService.getMessage("Το.σύνολο.μετοχών.δεν.ισούται.με.το.κεφάλαιο", [stocksTotal, totalAmount] as Object[]))
        }
    }

    void validateUpdate(CompanyCapitalRequestDto companyCapitalRequestDto) {
        Utils.validateRequiredId(companyCapitalRequestDto.companyId, "Μη.έγκυρο.id", messageService)
        validateCompanyCapitalRequestDto(companyCapitalRequestDto)
    }
}
