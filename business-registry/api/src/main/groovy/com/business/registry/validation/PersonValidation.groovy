package com.business.registry.validation

import com.business.registry.dto.person.PersonRequestDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Component

@Component
@CompileStatic
class PersonValidation implements Validatable {

    @Autowired
    MessageService messageService

    @Override
    void validateFindById(Long id) {
        Utils.validateId(id, messageService)
    }

    @Override
    void validateDeleteById(Long id) {
        Utils.validateId(id, messageService)
    }

    void validatePersonRequestDto(PersonRequestDto personDto) {
        Utils.validateRequestNotNull(personDto, messageService)
        Utils.validateRequiredString(personDto.name, "Το.πεδίο.Όνομα.είναι.υποχρεωτικό", messageService)
        Utils.validateRequiredString(personDto.surname, "Το.πεδίο.Επώνυμο.είναι.υποχρεωτικό", messageService)
        Utils.validateAfmField(personDto.afm, messageService)
        Utils.validateAddressFields(personDto.city, personDto.street, personDto.streetNumber, personDto.postalCode, messageService)
        if (personDto.birthDate == null || personDto.birthDate.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ημερομηνία.Γέννησης.είναι.υποχρεωτικό"))
        }
        if (!Utils.validateDate(personDto.birthDate)) {
            throw new IllegalArgumentException(messageService.getMessage("Η.Ημερομηνία.Γέννησης.δεν.είναι.έγκυρη"))
        }
        Utils.validateRequiredString(personDto.birthPlace, "Το.πεδίο.Τόπος.Γέννησης.είναι.υποχρεωτικό", messageService)
        Utils.validateRequiredString(personDto.identityNumber, "Το.πεδίο.Αριθμός.Ταυτότητας.είναι.υποχρεωτικό", messageService)
        Utils.validateRequiredString(personDto.phoneNumber, "Το.πεδίο.Τηλέφωνο.είναι.υποχρεωτικό", messageService)
        Utils.validateChangeReason(personDto.changeReason, messageService)
        Utils.validateLocationIds(personDto.countryId, personDto.prefectureId, personDto.municipalityId, personDto.regionId, messageService)
    }

    void validateUpdate(PersonRequestDto personDto, Long id) {
        if (id != null && id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
        validatePersonRequestDto(personDto)
    }
}
