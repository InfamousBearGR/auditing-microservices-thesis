package com.business.registry.service

import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.MunicipalityI18nMapper
import com.business.registry.model.Language
import com.business.registry.model.Municipality
import com.business.registry.model.MunicipalityI18n
import com.business.registry.model.Prefecture
import com.business.registry.repository.MunicipalityI18nRepository
import com.business.registry.repository.MunicipalityRepository
import groovy.transform.CompileStatic
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class MunicipalityService {

    private final MunicipalityRepository municipalityRepository
    private final MunicipalityI18nRepository municipalityI18nRepository
    private final MunicipalityI18nMapper municipalityI18nMapper

    @Autowired
    LanguageService languageService

    MunicipalityService(MunicipalityRepository municipalityRepository,
                        MunicipalityI18nRepository municipalityI18nRepository,
                        MunicipalityI18nMapper municipalityI18nMapper) {
        this.municipalityRepository = municipalityRepository
        this.municipalityI18nRepository = municipalityI18nRepository
        this.municipalityI18nMapper = municipalityI18nMapper
    }

    List<ParametricDto> findAllMunicipalityTranslationsByPrefectureIdAndLocale(Long prefectureId, Locale locale) {
        Language language = languageService.getLanguageFromLocale(locale)
        Prefecture prefecture = new Prefecture(id: prefectureId)
        List<Municipality> municipalities = municipalityRepository.findByPrefecture(prefecture)
        List<MunicipalityI18n> i18nEntities = municipalityI18nRepository.findByMunicipalityInAndLanguage(municipalities, language)
        return municipalityI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findMunicipalityTranslationByLocaleAndMunicipality(Locale locale, Municipality municipality) {
        Language language = languageService.getLanguageFromLocale(locale)
        MunicipalityI18n i18nEntity = municipalityI18nRepository.findByMunicipalityAndLanguage(municipality, language)
        return municipalityI18nMapper.toParametricDto(i18nEntity)
    }

    Municipality findMunicipalityById(Long id) {
        return municipalityRepository.findById(id).orElse(null)
    }
}
