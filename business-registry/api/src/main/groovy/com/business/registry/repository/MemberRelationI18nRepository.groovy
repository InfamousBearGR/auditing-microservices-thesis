package com.business.registry.repository

import com.business.registry.model.Language
import com.business.registry.model.MemberRelation
import com.business.registry.model.MemberRelationI18n
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface MemberRelationI18nRepository extends JpaRepository<MemberRelationI18n, Long> {
    List<MemberRelationI18n> findByLanguage(Language language)

    MemberRelationI18n findByMemberRelationAndLanguage(MemberRelation memberRelation, Language language)
}
