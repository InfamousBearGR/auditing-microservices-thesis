package com.business.registry.dao

import com.business.registry.model.Municipality
import com.business.registry.model.MunicipalityI18n
import com.business.registry.repository.MunicipalityI18nRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class MunicipalityI18nDao {

    private final MunicipalityI18nRepository municipalityI18nRepository
    private final LanguageDao languageDao

    MunicipalityI18nDao(MunicipalityI18nRepository municipalityI18nRepository, LanguageDao languageDao) {
        this.municipalityI18nRepository = municipalityI18nRepository
        this.languageDao = languageDao
    }

    List<MunicipalityI18n> findMunicipalityTranslationsByMunicipalitiesAndLocale(List<Municipality> municipalities, Locale locale) {
        return municipalityI18nRepository.findByMunicipalityInAndLanguage(municipalities, languageDao.getLanguageFromLocale(locale))
    }

    MunicipalityI18n findMunicipalityTranslationByLocaleAndMunicipality(Municipality municipality, Locale locale) {
        return municipalityI18nRepository.findByMunicipalityAndLanguage(municipality, languageDao.getLanguageFromLocale(locale))
    }
}

