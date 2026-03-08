package com.business.registry.service

import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.PrefectureI18nMapper
import com.business.registry.model.Language
import com.business.registry.model.Prefecture
import com.business.registry.model.PrefectureI18n
import com.business.registry.model.Region
import com.business.registry.repository.LanguageRepository
import com.business.registry.repository.PrefectureI18nRepository
import com.business.registry.repository.PrefectureRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class PrefectureService {

    private final PrefectureRepository prefectureRepository
    private final PrefectureI18nRepository prefectureI18nRepository
    private final PrefectureI18nMapper prefectureI18nMapper
    private final LanguageRepository languageRepository

    PrefectureService(PrefectureRepository prefectureRepository,
                      PrefectureI18nRepository prefectureI18nRepository,
                      PrefectureI18nMapper prefectureI18nMapper,
                      LanguageRepository languageRepository) {
        this.prefectureRepository = prefectureRepository
        this.prefectureI18nRepository = prefectureI18nRepository
        this.prefectureI18nMapper = prefectureI18nMapper
        this.languageRepository = languageRepository
    }

    List<ParametricDto> findAllPrefectureTranslationsByRegionIdLocale(Long regionId, Locale locale) {
        Region region = new Region(id: regionId)
        List<Prefecture> prefectures = prefectureRepository.findByRegion(region)
        Language language = languageRepository.findByCode(locale?.language)
        List<PrefectureI18n> i18nEntities = prefectureI18nRepository.findByPrefectureInAndLanguage(prefectures, language)
        return prefectureI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findPrefectureTranslationByLocaleAndPrefecture(Locale locale, Prefecture prefecture) {
        Language language = languageRepository.findByCode(locale?.language)
        PrefectureI18n i18nEntity = prefectureI18nRepository.findByPrefectureAndLanguage(prefecture, language)
        return prefectureI18nMapper.toParametricDto(i18nEntity)
    }

    Prefecture findPrefectureById(Long id) {
        return prefectureRepository.findById(id).orElse(null)
    }
}
