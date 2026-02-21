package com.business.registry.dao

import com.business.registry.model.Prefecture
import com.business.registry.model.PrefectureI18n
import com.business.registry.repository.PrefectureI18nRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class PrefectureI18nDao {

    private final PrefectureI18nRepository prefectureI18nRepository
    private final LanguageDao languageDao

    PrefectureI18nDao(PrefectureI18nRepository prefectureI18nRepository, LanguageDao languageDao) {
        this.prefectureI18nRepository = prefectureI18nRepository
        this.languageDao = languageDao
    }

    List<PrefectureI18n> findPrefectureTranslationsByPrefecturesAndLocale(List<Prefecture> prefectures, Locale locale) {
        return prefectureI18nRepository.findByPrefectureInAndLanguage(prefectures, languageDao.getLanguageFromLocale(locale))
    }

    PrefectureI18n findPrefectureTranslationByLocaleAndPrefecture(Prefecture prefecture, Locale locale) {
        return prefectureI18nRepository.findByPrefectureAndLanguage(prefecture, languageDao.getLanguageFromLocale(locale))
    }
}

