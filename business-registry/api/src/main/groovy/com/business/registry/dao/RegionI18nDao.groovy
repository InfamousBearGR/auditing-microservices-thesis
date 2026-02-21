package com.business.registry.dao

import com.business.registry.model.Region
import com.business.registry.model.RegionI18n
import com.business.registry.repository.RegionI18nRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class RegionI18nDao {

    private final RegionI18nRepository regionI18nRepository
    private final LanguageDao languageDao

    RegionI18nDao(RegionI18nRepository regionI18nRepository, LanguageDao languageDao) {
        this.regionI18nRepository = regionI18nRepository
        this.languageDao = languageDao
    }

    List<RegionI18n> findAllRegionTranslationsByLocale(Locale locale) {
        return regionI18nRepository.findByLanguage(languageDao.getLanguageFromLocale(locale))
    }

    RegionI18n findRegionTranslationByLocaleAndRegion(Region region, Locale locale) {
        return regionI18nRepository.findByRegionAndLanguage(region, languageDao.getLanguageFromLocale(locale))
    }
}

