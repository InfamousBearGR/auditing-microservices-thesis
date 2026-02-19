package com.business.registry.validation

import com.business.registry.dto.company.CompanyRequestDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class CompanyValidation {

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

    void validateCompanyRequestDto(CompanyRequestDto companyDto) {
        if (companyDto == null) {
            throw new IllegalArgumentException(messageService.getMessage("Το.αίτημα.είναι.κενό"))
        }
        if (companyDto.name == null || companyDto.name.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Επωνυμία.Επιχείρησης.είναι.υποχρεωτικό"))
        }
        if (companyDto.city == null || companyDto.city.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Πόλη.είναι.υποχρεωτικό"))
        }
        if (companyDto.street == null || companyDto.street.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Οδός.είναι.υποχρεωτικό"))
        }
        if (companyDto.streetNumber == null || companyDto.streetNumber.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αριθμός.είναι.υποχρεωτικό"))
        }
        if (companyDto.postalCode == null || companyDto.postalCode.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ταχυδρομικός.Κώδικας.είναι.υποχρεωτικό"))
        }
        if (companyDto.afm == null || companyDto.afm.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.ΑΦΜ.είναι.υποχρεωτικό"))
        }
        if (!Utils.validateAfm(companyDto.afm)) {
            throw new IllegalArgumentException(messageService.getMessage("Το.ΑΦΜ.δεν.είναι.έγκυρο"))
        }
        if (companyDto.dateIncorporated == null || companyDto.dateIncorporated.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ημερομηνία.Ίδρυσης.είναι.υποχρεωτικό"))
        }
        if (!Utils.validateDate(companyDto.dateIncorporated)) {
            throw new IllegalArgumentException(messageService.getMessage("Η.Ημερομηνία.Ίδρυσης.δεν.είναι.έγκυρη"))
        }
        if (companyDto.gemiNumber == null || companyDto.gemiNumber.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αριθμός.ΓΕΜΗ.είναι.υποχρεωτικό"))
        }
        if (companyDto.countryId == null || companyDto.countryId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Χώρα.είναι.υποχρεωτικό"))
        }
        if (companyDto.prefectureId == null || companyDto.prefectureId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Νομός.είναι.υποχρεωτικό"))
        }
        if (companyDto.municipalityId == null || companyDto.municipalityId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Δήμος.είναι.υποχρεωτικό"))
        }
        if (companyDto.regionId == null || companyDto.regionId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Περιφέρεια.είναι.υποχρεωτικό"))
        }
        if (companyDto.legalTypeId == null || companyDto.legalTypeId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Νομική.Μορφή.είναι.υποχρεωτικό"))
        }
        if (companyDto.companyStatusId == null || companyDto.companyStatusId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Κατάσταση.Επιχείρησης.είναι.υποχρεωτικό"))
        }
        if (companyDto.changeReason == null || companyDto.changeReason.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αιτία.Αλλαγής.είναι.υποχρεωτικό"))
        }
    }

    void validateUpdate(CompanyRequestDto companyDto, Long id) {
        if (id != null && id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
        validateCompanyRequestDto(companyDto)
    }
}
