package com.business.registry.service

import com.business.registry.dao.MunicipalityDao
import com.business.registry.dao.MunicipalityI18nDao
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.MunicipalityI18nMapper
import com.business.registry.model.Municipality
import com.business.registry.model.MunicipalityI18n
import com.business.registry.model.Prefecture
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class MunicipalityService {

    private final MunicipalityDao municipalityDao
    private final MunicipalityI18nDao municipalityI18nDao
    private final MunicipalityI18nMapper municipalityI18nMapper

    MunicipalityService(MunicipalityDao municipalityDao,
                        MunicipalityI18nDao municipalityI18nDao,
                        MunicipalityI18nMapper municipalityI18nMapper) {
        this.municipalityDao = municipalityDao
        this.municipalityI18nDao = municipalityI18nDao
        this.municipalityI18nMapper = municipalityI18nMapper
    }

    List<ParametricDto> findAllMunicipalityTranslationsByPrefectureIdAndLocale(Long prefectureId, Locale locale) {
        Prefecture prefecture = new Prefecture(id: prefectureId)
        List<Municipality> municipalities = municipalityDao.findMunicipalitiesByPrefecture(prefecture)
        List<MunicipalityI18n> i18nEntities = municipalityI18nDao.findMunicipalityTranslationsByMunicipalitiesAndLocale(municipalities, locale)
        return municipalityI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findMunicipalityTranslationByLocaleAndMunicipality(Locale locale, Municipality municipality) {
        MunicipalityI18n i18nEntity = municipalityI18nDao.findMunicipalityTranslationByLocaleAndMunicipality(municipality, locale)
        return municipalityI18nMapper.toParametricDto(i18nEntity)
    }

    Municipality findMunicipalityById(Long id) {
        return municipalityDao.findMunicipalityById(id)
    }
}
