package com.business.registry.repository

import com.business.registry.model.MemberRelation
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface MemberRelationRepository extends JpaRepository<MemberRelation, Long> {
}

