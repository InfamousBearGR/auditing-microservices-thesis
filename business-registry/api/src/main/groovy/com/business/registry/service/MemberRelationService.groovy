package com.business.registry.service

import com.business.registry.dao.MemberRelationDao
import com.business.registry.dao.MemberRelationI18nDao
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.i18n.MemberRelationI18nMapper
import com.business.registry.model.MemberRelation
import com.business.registry.model.MemberRelationI18n
import groovy.transform.CompileStatic
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
@Transactional(readOnly = true)
class MemberRelationService {

    private final MemberRelationDao memberRelationDao
    private final MemberRelationI18nDao memberRelationI18nDao
    private final MemberRelationI18nMapper memberRelationI18nMapper

    MemberRelationService(MemberRelationDao memberRelationDao,
                          MemberRelationI18nDao memberRelationI18nDao,
                          MemberRelationI18nMapper memberRelationI18nMapper) {
        this.memberRelationDao = memberRelationDao
        this.memberRelationI18nDao = memberRelationI18nDao
        this.memberRelationI18nMapper = memberRelationI18nMapper
    }

    List<ParametricDto> findAllMemberRelationTranslationsByLocale(Locale locale) {
        List<MemberRelationI18n> i18nEntities = memberRelationI18nDao.findAllMemberRelationTranslationsByLocale(locale)
        return memberRelationI18nMapper.toParametricDtoList(i18nEntities)
    }

    ParametricDto findMemberRelationTranslationByLocaleAndMemberRelation(Locale locale, MemberRelation memberRelation) {
        MemberRelationI18n i18nEntity = memberRelationI18nDao.findMemberRelationTranslationByLocaleAndMemberRelation(memberRelation, locale)
        return memberRelationI18nMapper.toParametricDto(i18nEntity)
    }

    MemberRelation findMemberRelationById(Long id) {
        return memberRelationDao.findMemberRelationById(id)
    }
}
