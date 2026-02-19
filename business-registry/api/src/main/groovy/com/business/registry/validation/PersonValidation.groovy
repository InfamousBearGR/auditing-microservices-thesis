package com.business.registry.validation

import com.business.registry.dto.person.PersonRequestDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class PersonValidation {

    MessageService messageService

    void validateFindById(Long id) {
        if (id == null || id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
    }

    void validateDeleteById(Long id) {
        if (id == null || id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
    }

    void validatePersonRequestDto(PersonRequestDto personDto) {
        if (personDto == null) {
            throw new IllegalArgumentException(messageService.getMessage("Το.αίτημα.είναι.κενό"))
        }
        if (personDto.name == null || personDto.name.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Όνομα.είναι.υποχρεωτικό"))
        }
        if (personDto.surname == null || personDto.surname.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Επώνυμο.είναι.υποχρεωτικό"))
        }
        if (personDto.afm == null || personDto.afm.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.ΑΦΜ.είναι.υποχρεωτικό"))
        }
        if (!Utils.validateAfm(personDto.afm)) {
            throw new IllegalArgumentException(messageService.getMessage("Το.ΑΦΜ.δεν.είναι.έγκυρο"))
        }
        if (personDto.city == null || personDto.city.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Πόλη.είναι.υποχρεωτικό"))
        }
        if (personDto.street == null || personDto.street.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Οδός.είναι.υποχρεωτικό"))
        }
        if (personDto.streetNumber == null || personDto.streetNumber.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αριθμός.είναι.υποχρεωτικό"))
        }
        if (personDto.postalCode == null || personDto.postalCode.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ταχυδρομικός.Κώδικας.είναι.υποχρεωτικό"))
        }
        if (personDto.birthDate == null || personDto.birthDate.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ημερομηνία.Γέννησης.είναι.υποχρεωτικό"))
        }
        if (!Utils.validateDate(personDto.birthDate)) {
            throw new IllegalArgumentException(messageService.getMessage("Η.Ημερομηνία.Γέννησης.δεν.είναι.έγκυρη"))
        }
        if (personDto.birthPlace == null || personDto.birthPlace.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Τόπος.Γέννησης.είναι.υποχρεωτικό"))
        }
        if (personDto.identityNumber == null || personDto.identityNumber.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αριθμός.Ταυτότητας.είναι.υποχρεωτικό"))
        }
        if (personDto.changeReason == null || personDto.changeReason.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αιτία.Αλλαγής.είναι.υποχρεωτικό"))
        }
        if (personDto.countryId == null || personDto.countryId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Χώρα.είναι.υποχρεωτικό"))
        }
        if (personDto.prefectureId == null || personDto.prefectureId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Νομός.είναι.υποχρεωτικό"))
        }
        if (personDto.municipalityId == null || personDto.municipalityId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Δήμος.είναι.υποχρεωτικό"))
        }
        if (personDto.regionId == null || personDto.regionId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Περιφέρεια.είναι.υποχρεωτικό"))
        }
    }

    void validateUpdate(PersonRequestDto personDto, Long id) {
        if (id != null && id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
        validatePersonRequestDto(personDto)
    }
}
