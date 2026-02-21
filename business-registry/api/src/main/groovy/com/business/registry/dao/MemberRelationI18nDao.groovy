package com.business.registry.dao

import com.business.registry.model.MemberRelation
import com.business.registry.model.MemberRelationI18n
import com.business.registry.repository.MemberRelationI18nRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class MemberRelationI18nDao {

    private final MemberRelationI18nRepository memberRelationI18nRepository
    private final LanguageDao languageDao

    MemberRelationI18nDao(MemberRelationI18nRepository memberRelationI18nRepository, LanguageDao languageDao) {
        this.memberRelationI18nRepository = memberRelationI18nRepository
        this.languageDao = languageDao
    }

    List<MemberRelationI18n> findAllMemberRelationTranslationsByLocale(Locale locale) {
        return memberRelationI18nRepository.findByLanguage(languageDao.getLanguageFromLocale(locale))
    }

    MemberRelationI18n findMemberRelationTranslationByLocaleAndMemberRelation(MemberRelation memberRelation, Locale locale) {
        return memberRelationI18nRepository.findByMemberRelationAndLanguage(memberRelation, languageDao.getLanguageFromLocale(locale))
    }
}

