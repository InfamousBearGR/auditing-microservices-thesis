package com.business.registry.service

import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.RegionI18nMapper
import com.business.registry.model.Language
import com.business.registry.model.Region
import com.business.registry.model.RegionI18n
import com.business.registry.repository.RegionI18nRepository
import com.business.registry.repository.RegionRepository
import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class RegionService {

    private final RegionRepository regionRepository
    private final RegionI18nRepository regionI18nRepository
    private final RegionI18nMapper regionI18nMapper

    @Autowired
    LanguageService languageService

    RegionService(RegionRepository regionRepository,
                  RegionI18nRepository regionI18nRepository,
                  RegionI18nMapper regionI18nMapper) {
        this.regionRepository = regionRepository
        this.regionI18nRepository = regionI18nRepository
        this.regionI18nMapper = regionI18nMapper
    }

    List<ParametricDto> findAllRegionTranslationsByLocale(Locale locale) {
        Language language = languageService.getLanguageFromLocale(locale)
        List<RegionI18n> i18nEntities = regionI18nRepository.findByLanguage(language)
        return regionI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findRegionTranslationByLocaleAndRegion(Locale locale, Region region) {
        Language language = languageService.getLanguageFromLocale(locale)
        RegionI18n i18nEntity = regionI18nRepository.findByRegionAndLanguage(region, language)
        return regionI18nMapper.toParametricDto(i18nEntity)
    }

    Region findRegionById(Long id) {
        return regionRepository.findById(id).orElse(null)
    }
}
