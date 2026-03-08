package com.business.registry.validation

import com.business.registry.dto.legalEntity.LegalEntityRequestDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class LegalEntityValidation implements Validatable {

    MessageService messageService

    @Override
    void validateFindById(Long id) {
        Utils.validateId(id, messageService)
    }

    @Override
    void validateDeleteById(Long id) {
        Utils.validateId(id, messageService)
    }

    void validateLegalEntityRequestDto(LegalEntityRequestDto legalEntityDto) {
        Utils.validateRequestNotNull(legalEntityDto, messageService)
        Utils.validateRequiredString(legalEntityDto.registryNumber, "Το.πεδίο.Αριθμός.Μητρώου.είναι.υποχρεωτικό", messageService)
        Utils.validateRequiredString(legalEntityDto.businessName, "Το.πεδίο.Επωνυμία.Νομικού.Προσώπου.είναι.υποχρεωτικό", messageService)
        Utils.validateAfmField(legalEntityDto.afm, messageService)
        Utils.validateAddressFields(legalEntityDto.city, legalEntityDto.street, legalEntityDto.streetNumber, legalEntityDto.postalCode, messageService)
        Utils.validateChangeReason(legalEntityDto.changeReason, messageService)
        Utils.validateLocationIds(legalEntityDto.countryId, legalEntityDto.prefectureId, legalEntityDto.municipalityId, legalEntityDto.regionId, messageService)
    }

    void validateUpdate(LegalEntityRequestDto legalEntityDto, Long id) {
        if (id != null && id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
        validateLegalEntityRequestDto(legalEntityDto)
    }
}
