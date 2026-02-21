package com.business.registry.service

import com.business.registry.dao.RegionDao
import com.business.registry.dao.RegionI18nDao
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.RegionI18nMapper
import com.business.registry.model.Region
import com.business.registry.model.RegionI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class RegionService {

    private final RegionDao regionDao
    private final RegionI18nDao regionI18nDao
    private final RegionI18nMapper regionI18nMapper

    RegionService(RegionDao regionDao,
                  RegionI18nDao regionI18nDao,
                  RegionI18nMapper regionI18nMapper) {
        this.regionDao = regionDao
        this.regionI18nDao = regionI18nDao
        this.regionI18nMapper = regionI18nMapper
    }

    List<ParametricDto> findAllRegionTranslationsByLocale(Locale locale) {
        List<RegionI18n> i18nEntities = regionI18nDao.findAllRegionTranslationsByLocale(locale)
        return regionI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findRegionTranslationByLocaleAndRegion(Locale locale, Region region) {
        RegionI18n i18nEntity = regionI18nDao.findRegionTranslationByLocaleAndRegion(region, locale)
        return regionI18nMapper.toParametricDto(i18nEntity)
    }

    Region findRegionById(Long id) {
        return regionDao.findRegionById(id)
    }
}
