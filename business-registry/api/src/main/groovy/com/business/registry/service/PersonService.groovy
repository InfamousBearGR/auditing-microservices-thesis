package com.business.registry.service

import com.business.registry.dto.person.PersonRequestDto
import com.business.registry.dto.person.PersonResponseDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.exception.NotFoundException
import com.business.registry.mapper.person.PersonMapper
import com.business.registry.model.*
import com.business.registry.repository.PersonRepository
import com.business.registry.repository.UserAccountRepository
import com.business.registry.validation.PersonValidation
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import java.time.LocalDate

@Service
@CompileStatic
class PersonService {
    private final PersonRepository personRepository
    private final PersonMapper personMapper
    private final PersonValidation personValidation
    private final UserAccountRepository userAccountRepository

    @Autowired
    CountryService countryService

    @Autowired
    PrefectureService prefectureService

    @Autowired
    MunicipalityService municipalityService

    @Autowired
    RegionService regionService

    @Autowired
    MessageService messageService

    @Autowired
    AuthenticationService authenticationService

    PersonService(
            PersonRepository personRepository,
            PersonMapper personMapper,
            CountryService countryService,
            PrefectureService prefectureService,
            MunicipalityService municipalityService,
            RegionService regionService,
            MessageService messageService,
            PersonValidation personValidation,
            UserAccountRepository userAccountRepository,
            AuthenticationService authenticationService
    ) {
        this.personRepository = personRepository
        this.personMapper = personMapper
        this.countryService = countryService
        this.prefectureService = prefectureService
        this.municipalityService = municipalityService
        this.regionService = regionService
        this.messageService = messageService
        this.personValidation = personValidation
        this.userAccountRepository = userAccountRepository
        this.authenticationService = authenticationService
    }

    @Transactional(readOnly = true)
    List<PersonResponseDto> getAllPersons(Locale locale) {
        return personRepository.findAll().collect { person ->
            mapToPersonResponseDto(person, locale)
        }
    }

    @Transactional(readOnly = true)
    PersonResponseDto getPersonById(Long id, Locale locale) {
        personValidation.validateFindById(id)
        Person person = personRepository.findById(id).orElse(null)
        if (person == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Φυσικό.Πρόσωπο.με.id.", [id] as Object[]))
        }
        return mapToPersonResponseDto(person, locale)
    }

    @Transactional(readOnly = true)
    Person findPersonById(Long id) {
        return personRepository.findById(id).orElse(null)
    }

    @Transactional
    void updatePerson(PersonRequestDto personDto, Long id, HttpSession session) {
        personValidation.validateUpdate(personDto, id)
        Person person = personRepository.findById(id).orElse(null)
        if (person == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Φυσικό.Πρόσωπο.με.id.", [id] as Object[]))
        }
        populatePersonFromDto(person, personDto, session)
        personRepository.save(person)
    }

    @Transactional
    void createPerson(PersonRequestDto personDto, HttpSession session) {
        personValidation.validatePersonRequestDto(personDto)
        Person person = new Person()
        populatePersonFromDto(person, personDto, session)
        personRepository.save(person)
    }

    @Transactional
    void deletePersonById(Long id, String changeReason, HttpSession session) {
        personValidation.validateDeleteById(id)
        if (!personRepository.existsById(id)) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Φυσικό.Πρόσωπο.με.id.", [id] as Object[]))
        }
        Person person = personRepository.findById(id).orElse(null)
        UserAccount user = userAccountRepository.findById(AuthenticationService.getCurrentUserId(session)).orElse(null)
        person.changeReason = changeReason
        person.lastUser = user
        personRepository.saveAndFlush(person)
        personRepository.deleteById(id)
    }

    private PersonResponseDto mapToPersonResponseDto(Person person, Locale locale) {
        ParametricDto country = countryService.findCountryTranslationByLocaleAndCountry(locale, person.country)
        ParametricDto prefecture = prefectureService.findPrefectureTranslationByLocaleAndPrefecture(locale, person.prefecture)
        ParametricDto municipality = municipalityService.findMunicipalityTranslationByLocaleAndMunicipality(locale, person.municipality)
        ParametricDto region = regionService.findRegionTranslationByLocaleAndRegion(locale, person.region)
        return personMapper.toPersonDto(person, country, prefecture, municipality, region)
    }

    private void populatePersonFromDto(Person person, PersonRequestDto personDto, HttpSession session) {
        Country country = countryService.findCountryById(personDto.countryId)
        if (country == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.χώρα.με.id.", [personDto.countryId] as Object[]))
        }
        Prefecture prefecture = prefectureService.findPrefectureById(personDto.prefectureId)
        if (prefecture == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.νομός.με.id.", [personDto.prefectureId] as Object[]))
        }
        Municipality municipality = municipalityService.findMunicipalityById(personDto.municipalityId)
        if (municipality == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.δήμος.με.id.", [personDto.municipalityId] as Object[]))
        }
        Region region = regionService.findRegionById(personDto.regionId)
        if (region == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.περιφέρεια.με.id.", [personDto.regionId] as Object[]))
        }
        UserAccount user = userAccountRepository.findById(AuthenticationService.getCurrentUserId(session)).orElse(null)
        person.name = personDto.name
        person.surname = personDto.surname
        person.afm = personDto.afm
        person.city = personDto.city
        person.street = personDto.street
        person.streetNumber = personDto.streetNumber
        person.postalCode = personDto.postalCode
        person.birthDate = personDto.birthDate ? LocalDate.parse(personDto.birthDate) : null
        person.birthPlace = personDto.birthPlace
        person.identityNumber = personDto.identityNumber
        person.phoneNumber = personDto.phoneNumber
        person.changeReason = personDto.changeReason
        person.lastUser = user
        person.country = country
        person.prefecture = prefecture
        person.municipality = municipality
        person.region = region
    }
}

