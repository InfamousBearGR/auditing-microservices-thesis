package com.business.registry.service

import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.MemberRelationI18nMapper
import com.business.registry.model.Language
import com.business.registry.model.MemberRelation
import com.business.registry.model.MemberRelationI18n
import com.business.registry.repository.LanguageRepository
import com.business.registry.repository.MemberRelationI18nRepository
import com.business.registry.repository.MemberRelationRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class MemberRelationService {

    private final MemberRelationRepository memberRelationRepository
    private final MemberRelationI18nRepository memberRelationI18nRepository
    private final MemberRelationI18nMapper memberRelationI18nMapper
    private final LanguageRepository languageRepository

    MemberRelationService(MemberRelationRepository memberRelationRepository,
                          MemberRelationI18nRepository memberRelationI18nRepository,
                          MemberRelationI18nMapper memberRelationI18nMapper,
                          LanguageRepository languageRepository) {
        this.memberRelationRepository = memberRelationRepository
        this.memberRelationI18nRepository = memberRelationI18nRepository
        this.memberRelationI18nMapper = memberRelationI18nMapper
        this.languageRepository = languageRepository
    }

    List<ParametricDto> findAllMemberRelationTranslationsByLocale(Locale locale) {
        Language language = languageRepository.findByCode(locale?.language)
        List<MemberRelationI18n> i18nEntities = memberRelationI18nRepository.findByLanguage(language)
        return memberRelationI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findMemberRelationTranslationByLocaleAndMemberRelation(Locale locale, MemberRelation memberRelation) {
        Language language = languageRepository.findByCode(locale?.language)
        MemberRelationI18n i18nEntity = memberRelationI18nRepository.findByMemberRelationAndLanguage(memberRelation, language)
        return memberRelationI18nMapper.toParametricDto(i18nEntity)
    }

    MemberRelation findMemberRelationById(Long id) {
        return memberRelationRepository.findById(id).orElse(null)
    }
}
