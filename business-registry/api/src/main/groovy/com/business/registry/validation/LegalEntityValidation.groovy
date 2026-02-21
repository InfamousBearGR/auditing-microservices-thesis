package com.business.registry.validation

import com.business.registry.dto.legalEntity.LegalEntityRequestDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class LegalEntityValidation {

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

    void validateLegalEntityRequestDto(LegalEntityRequestDto legalEntityDto) {
        if (legalEntityDto == null) {
            throw new IllegalArgumentException(messageService.getMessage("Το.αίτημα.είναι.κενό"))
        }
        if (legalEntityDto.registryNumber == null || legalEntityDto.registryNumber.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αριθμός.Μητρώου.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.businessName == null || legalEntityDto.businessName.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Επωνυμία.Νομικού.Προσώπου.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.afm == null || legalEntityDto.afm.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.ΑΦΜ.είναι.υποχρεωτικό"))
        }
        if (!Utils.validateAfm(legalEntityDto.afm)) {
            throw new IllegalArgumentException(messageService.getMessage("Το.ΑΦΜ.δεν.είναι.έγκυρο"))
        }
        if (legalEntityDto.city == null || legalEntityDto.city.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Πόλη.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.street == null || legalEntityDto.street.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Οδός.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.streetNumber == null || legalEntityDto.streetNumber.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αριθμός.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.postalCode == null || legalEntityDto.postalCode.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ταχυδρομικός.Κώδικας.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.changeReason == null || legalEntityDto.changeReason.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αιτία.Αλλαγής.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.countryId == null || legalEntityDto.countryId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Χώρα.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.prefectureId == null || legalEntityDto.prefectureId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Νομός.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.municipalityId == null || legalEntityDto.municipalityId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Δήμος.είναι.υποχρεωτικό"))
        }
        if (legalEntityDto.regionId == null || legalEntityDto.regionId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Περιφέρεια.είναι.υποχρεωτικό"))
        }
    }

    void validateUpdate(LegalEntityRequestDto legalEntityDto, Long id) {
        if (id != null && id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
        validateLegalEntityRequestDto(legalEntityDto)
    }
}
