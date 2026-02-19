package com.business.registry.repository

import com.business.registry.model.CompanyStatus
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CompanyStatusRepository extends JpaRepository<CompanyStatus, Long> {
}

