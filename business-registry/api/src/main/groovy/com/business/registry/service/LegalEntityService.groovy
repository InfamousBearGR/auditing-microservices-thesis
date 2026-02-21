package com.business.registry.service

import com.business.registry.dao.LegalEntityDao
import com.business.registry.dto.legalEntity.LegalEntityRequestDto
import com.business.registry.dto.legalEntity.LegalEntityResponseDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.exception.NotFoundException
import com.business.registry.mapper.legalEntity.LegalEntityMapper
import com.business.registry.model.*
import com.business.registry.validation.LegalEntityValidation
import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
class LegalEntityService {
    private final LegalEntityDao legalEntityDao
    private final LegalEntityMapper legalEntityMapper
    private final LegalEntityValidation legalEntityValidation

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

    LegalEntityService(
            LegalEntityDao legalEntityDao,
            LegalEntityMapper legalEntityMapper,
            CountryService countryService,
            PrefectureService prefectureService,
            MunicipalityService municipalityService,
            RegionService regionService,
            MessageService messageService,
            LegalEntityValidation legalEntityValidation
    ) {
        this.legalEntityDao = legalEntityDao
        this.legalEntityMapper = legalEntityMapper
        this.countryService = countryService
        this.prefectureService = prefectureService
        this.municipalityService = municipalityService
        this.regionService = regionService
        this.messageService = messageService
        this.legalEntityValidation = legalEntityValidation
    }

    @Transactional(readOnly = true)
    List<LegalEntityResponseDto> getAllLegalEntities(Locale locale) {
        return legalEntityDao.findAllLegalEntities().collect { legalEntity ->
            mapToLegalEntityResponseDto(legalEntity, locale)
        }
    }

    @Transactional(readOnly = true)
    LegalEntityResponseDto getLegalEntityById(Long id, Locale locale) {
        legalEntityValidation.validateFindById(id)
        LegalEntity legalEntity = legalEntityDao.findLegalEntityById(id)
        if (legalEntity == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Νομικό.Πρόσωπο.με.id.", [id] as Object[]))
        }
        return mapToLegalEntityResponseDto(legalEntity, locale)
    }

    @Transactional(readOnly = true)
    LegalEntity findLegalEntityById(Long id) {
        return legalEntityDao.findLegalEntityById(id)
    }

    @Transactional
    void updateLegalEntity(LegalEntityRequestDto legalEntityDto, Long id) {
        legalEntityValidation.validateUpdate(legalEntityDto, id)
        LegalEntity legalEntity = legalEntityDao.findLegalEntityById(id)
        if (legalEntity == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Νομικό.Πρόσωπο.με.id.", [id] as Object[]))
        }
        populateLegalEntityFromDto(legalEntity, legalEntityDto)
        legalEntityDao.saveLegalEntity(legalEntity)
    }

    @Transactional
    void createLegalEntity(LegalEntityRequestDto legalEntityDto) {
        legalEntityValidation.validateLegalEntityRequestDto(legalEntityDto)
        LegalEntity legalEntity = new LegalEntity()
        populateLegalEntityFromDto(legalEntity, legalEntityDto)
        legalEntityDao.saveLegalEntity(legalEntity)
    }

    @Transactional
    void deleteLegalEntityById(Long id) {
        legalEntityValidation.validateDeleteById(id)
        if (!legalEntityDao.existsById(id)) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Νομικό.Πρόσωπο.με.id.", [id] as Object[]))
        }
        legalEntityDao.deleteLegalEntityById(id)
    }

    private LegalEntityResponseDto mapToLegalEntityResponseDto(LegalEntity legalEntity, Locale locale) {
        ParametricDto country = countryService.findCountryTranslationByLocaleAndCountry(locale, legalEntity.country)
        ParametricDto prefecture = prefectureService.findPrefectureTranslationByLocaleAndPrefecture(locale, legalEntity.prefecture)
        ParametricDto municipality = municipalityService.findMunicipalityTranslationByLocaleAndMunicipality(locale, legalEntity.municipality)
        ParametricDto region = regionService.findRegionTranslationByLocaleAndRegion(locale, legalEntity.region)
        return legalEntityMapper.toLegalEntityDto(legalEntity, country, prefecture, municipality, region)
    }

    private void populateLegalEntityFromDto(LegalEntity legalEntity, LegalEntityRequestDto legalEntityDto) {
        Country country = countryService.findCountryById(legalEntityDto.countryId)
        if (country == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.χώρα.με.id.", [legalEntityDto.countryId] as Object[]))
        }
        Prefecture prefecture = prefectureService.findPrefectureById(legalEntityDto.prefectureId)
        if (prefecture == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.νομός.με.id.", [legalEntityDto.prefectureId] as Object[]))
        }
        Municipality municipality = municipalityService.findMunicipalityById(legalEntityDto.municipalityId)
        if (municipality == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.δήμος.με.id.", [legalEntityDto.municipalityId] as Object[]))
        }
        Region region = regionService.findRegionById(legalEntityDto.regionId)
        if (region == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.περιφέρεια.με.id.", [legalEntityDto.regionId] as Object[]))
        }
        legalEntity.registryNumber = legalEntityDto.registryNumber
        legalEntity.businessName = legalEntityDto.businessName
        legalEntity.phoneNumber = legalEntityDto.phoneNumber
        legalEntity.afm = legalEntityDto.afm
        legalEntity.city = legalEntityDto.city
        legalEntity.street = legalEntityDto.street
        legalEntity.country = country
        legalEntity.prefecture = prefecture
        legalEntity.municipality = municipality
        legalEntity.streetNumber = legalEntityDto.streetNumber
        legalEntity.region = region
        legalEntity.postalCode = legalEntityDto.postalCode
        legalEntity.changeReason = legalEntityDto.changeReason
    }
}

