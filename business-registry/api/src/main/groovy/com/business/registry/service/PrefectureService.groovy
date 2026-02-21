package com.business.registry.service

import com.business.registry.dao.PrefectureDao
import com.business.registry.dao.PrefectureI18nDao
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.PrefectureI18nMapper
import com.business.registry.model.Prefecture
import com.business.registry.model.PrefectureI18n
import com.business.registry.model.Region
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class PrefectureService {

    private final PrefectureDao prefectureDao
    private final PrefectureI18nDao prefectureI18nDao
    private final PrefectureI18nMapper prefectureI18nMapper

    PrefectureService(PrefectureDao prefectureDao,
                      PrefectureI18nDao prefectureI18nDao,
                      PrefectureI18nMapper prefectureI18nMapper) {
        this.prefectureDao = prefectureDao
        this.prefectureI18nDao = prefectureI18nDao
        this.prefectureI18nMapper = prefectureI18nMapper
    }

    List<ParametricDto> findAllPrefectureTranslationsByRegionIdLocale(Long regionId, Locale locale) {
        Region region = new Region(id: regionId)
        List<Prefecture> prefectures = prefectureDao.findPrefecturesByRegion(region)
        List<PrefectureI18n> i18nEntities = prefectureI18nDao.findPrefectureTranslationsByPrefecturesAndLocale(prefectures, locale)
        return prefectureI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findPrefectureTranslationByLocaleAndPrefecture(Locale locale, Prefecture prefecture) {
        PrefectureI18n i18nEntity = prefectureI18nDao.findPrefectureTranslationByLocaleAndPrefecture(prefecture, locale)
        return prefectureI18nMapper.toParametricDto(i18nEntity)
    }

    Prefecture findPrefectureById(Long id) {
        return prefectureDao.findPrefectureById(id)
    }
}
