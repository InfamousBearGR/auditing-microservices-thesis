package com.business.registry.validation

import com.business.registry.dto.company.CompanyRequestDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyValidation implements Validatable {

    MessageService messageService

    @Override
    void validateFindById(Long id) {
        Utils.validateId(id, messageService)
    }

    @Override
    void validateDeleteById(Long id) {
        Utils.validateId(id, messageService)
    }

    void validateCompanyRequestDto(CompanyRequestDto companyDto) {
        Utils.validateRequestNotNull(companyDto, messageService)
        Utils.validateRequiredString(companyDto.name, "Το.πεδίο.Επωνυμία.Επιχείρησης.είναι.υποχρεωτικό", messageService)
        Utils.validateAddressFields(companyDto.city, companyDto.street, companyDto.streetNumber, companyDto.postalCode, messageService)
        Utils.validateAfmField(companyDto.afm, messageService)
        if (companyDto.dateIncorporated == null || companyDto.dateIncorporated.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ημερομηνία.Ίδρυσης.είναι.υποχρεωτικό"))
        }
        if (!Utils.validateDate(companyDto.dateIncorporated)) {
            throw new IllegalArgumentException(messageService.getMessage("Η.Ημερομηνία.Ίδρυσης.δεν.είναι.έγκυρη"))
        }
        Utils.validateRequiredString(companyDto.registryNumber, "Το.πεδίο.Αριθμός.Μητρώου.είναι.υποχρεωτικό", messageService)
        if (companyDto.registryNumber.length() != 12) {
            throw new IllegalArgumentException(messageService.getMessage("Ο.Αριθμός.Μητρώου.πρέπει.να.έχει.12.ψηφία"))
        }
        Utils.validateLocationIds(companyDto.countryId, companyDto.prefectureId, companyDto.municipalityId, companyDto.regionId, messageService)
        Utils.validateRequiredId(companyDto.legalTypeId,      "Το.πεδίο.Νομική.Μορφή.είναι.υποχρεωτικό",          messageService)
        Utils.validateRequiredId(companyDto.companyStatusId,  "Το.πεδίο.Κατάσταση.Επιχείρησης.είναι.υποχρεωτικό", messageService)
        Utils.validateChangeReason(companyDto.changeReason, messageService)
    }

    void validateUpdate(CompanyRequestDto companyDto, Long id) {
        if (id != null && id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
        validateCompanyRequestDto(companyDto)
    }
}
