package com.business.registry.repository

import com.business.registry.model.Company
import com.business.registry.model.Member
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface MemberRepository extends JpaRepository<Member, Long> {
    List<Member> findAllByCompany(Company company)
}
