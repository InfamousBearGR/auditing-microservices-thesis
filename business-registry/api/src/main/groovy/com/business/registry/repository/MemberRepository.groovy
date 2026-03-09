package com.business.registry.repository

import com.business.registry.model.Company
import com.business.registry.model.Member
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface MemberRepository extends JpaRepository<Member, Long> {
    List<Member> findAllByCompany(Company company)

    @Query("SELECT COUNT(m) > 0 FROM Member m WHERE m.person.id = :personId OR m.representativeOfMember.id = :personId")
    boolean existsByPersonId(@Param("personId") Long personId)

    @Query("SELECT COUNT(m) > 0 FROM Member m WHERE m.legalEntity.id = :legalEntityId")
    boolean existsByLegalEntityId(@Param("legalEntityId") Long legalEntityId)
}
