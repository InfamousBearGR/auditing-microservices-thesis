package com.business.registry.repository

import com.business.registry.model.CompanyCapital
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CompanyCapitalRepository extends JpaRepository<CompanyCapital, Long> {
    List<CompanyCapital> findAllByCompanyId(Long companyId)
}

