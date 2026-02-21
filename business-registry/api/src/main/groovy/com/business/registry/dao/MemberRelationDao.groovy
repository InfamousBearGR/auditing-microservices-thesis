package com.business.registry.dao

import com.business.registry.model.MemberRelation
import com.business.registry.repository.MemberRelationRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class MemberRelationDao {

    private final MemberRelationRepository memberRelationRepository

    MemberRelationDao(MemberRelationRepository memberRelationRepository) {
        this.memberRelationRepository = memberRelationRepository
    }

    MemberRelation findMemberRelationById(Long id) {
        return memberRelationRepository.findById(id).orElse(null)
    }
}

