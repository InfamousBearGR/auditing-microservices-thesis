package com.business.registry.validation

import com.business.registry.dto.member.MemberRequestDto
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

import java.time.LocalDate

@Component
@CompileStatic
class MemberValidation {

    MessageService messageService
    Utils utils

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

    void validateMemberRequestDto(MemberRequestDto memberDto) {
        if (memberDto == null) {
            throw new IllegalArgumentException(messageService.getMessage("Το.αίτημα.είναι.κενό"))
        }
        if (memberDto.active == null) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ενεργός.είναι.υποχρεωτικό"))
        }
        if (memberDto.dateFrom == null || memberDto.dateFrom.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ημερομηνία.Από.είναι.υποχρεωτικό"))
        }
        if (!utils.validateDate(memberDto.dateFrom)) {
            throw new IllegalArgumentException(messageService.getMessage("Η.Ημερομηνία.Από.δεν.είναι.έγκυρη"))
        }

        if (memberDto.dateTo == null || memberDto.dateTo.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ημερομηνία.Έως.είναι.υποχρεωτικό"))
        }
        if (!utils.validateDate(memberDto.dateTo)) {
            throw new IllegalArgumentException(messageService.getMessage("Η.Ημερομηνία.Έως.δεν.είναι.έγκυρη"))
        }

        LocalDate dateFrom = LocalDate.parse(memberDto.dateFrom)
        LocalDate dateTo = LocalDate.parse(memberDto.dateTo)
        LocalDate today = LocalDate.now()

        if (dateTo.isBefore(dateFrom)) {
            throw new IllegalArgumentException(messageService.getMessage("Η.Ημερομηνία.Έως.δεν.μπορεί.να.είναι.προγενέστερη.της.Ημερομηνία.Από"))
        }

        if (dateFrom.isAfter(today)) {
            throw new IllegalArgumentException(messageService.getMessage("Η.Ημερομηνία.Από.δεν.μπορεί.να.είναι.μεταγενέστερη.του.σήμερα"))
        }

        if (dateTo.isBefore(today)) {
            throw new IllegalArgumentException(messageService.getMessage("Η.Ημερομηνία.Έως.δεν.μπορεί.να.είναι.προγενέστερη.του.σήμερα"))
        }

        if (memberDto.percentageOfOwnership == null || memberDto.percentageOfOwnership.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Ποσοστό.Ιδιοκτησίας.είναι.υποχρεωτικό"))
        }
        if (!utils.validatePercentage(memberDto.percentageOfOwnership)) {
            throw new IllegalArgumentException(messageService.getMessage("Το.Ποσοστό.Ιδιοκτησίας.πρέπει.να.είναι.ένας.έγκυρος.αριθμός"))
        }
        if (memberDto.memberRelationId == null || memberDto.memberRelationId <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Κατάσταση.είναι.υποχρεωτικό"))
        }
        if (memberDto.representedIndividual == null) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Εκπροσωπείται.Μεμονωμένα.είναι.υποχρεωτικό"))
        }
        if (memberDto.representedTogether == null) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Εκπροσωπείται.Από.Κοινού.είναι.υποχρεωτικό"))
        }
        if (memberDto.changeReason == null || memberDto.changeReason.trim().isEmpty()) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Αιτία.Αλλαγής.είναι.υποχρεωτικό"))
        }
        if (memberDto.legalEntityId && memberDto.personId) {
            throw new IllegalArgumentException(messageService.getMessage("Ο.Εταίρος.δεν.μπορεί.να.είναι.ταυτόχρονα.Φυσικό.και.Νομικό.Πρόσωπο"))
        }
        if (memberDto.legalEntityId == null && memberDto.personId == null) {
            throw new IllegalArgumentException(messageService.getMessage("Ο.Εταίρος.πρέπει.να.είναι.είτε.Φυσικό.είτε.Νομικό.Πρόσωπο"))
        }
        if (memberDto.legalEntityId && (memberDto.representativeOfMemberId == null || memberDto.representativeOfMemberId <= 0)) {
            throw new IllegalArgumentException(messageService.getMessage("Το.πεδίο.Εκπρόσωπος.είναι.υποχρεωτικό.όταν.το.μέλος.είναι.Νομικό.Πρόσωπο"))
        }
    }

    void validateUpdate(MemberRequestDto memberDto, Long id) {
        if (id != null && id <= 0) {
            throw new IllegalArgumentException(messageService.getMessage("Μη.έγκυρο.id", [id] as Object[]))
        }
        validateMemberRequestDto(memberDto)
    }
}
