package com.business.registry.repository

import com.business.registry.model.Company
import org.springframework.data.jpa.repository.JpaRepository

interface CompanyRepository extends JpaRepository<Company, Long> {
}