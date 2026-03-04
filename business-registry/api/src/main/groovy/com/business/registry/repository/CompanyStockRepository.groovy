package com.business.registry.repository

import com.business.registry.model.CompanyStock
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CompanyStockRepository extends JpaRepository<CompanyStock, Long> {
    List<CompanyStock> findAllByCompanyId(Long companyId)
}

