package com.business.registry.repository

import com.business.registry.model.Company
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface CompanyRepository extends JpaRepository<Company, Long> {

    @Query("SELECT c FROM Company c WHERE (c.companyStatus.id = :companyStatusId OR :companyStatusId IS NULL) AND (c.legalType.id = :legalTypeId OR :legalTypeId IS NULL)")
    List<Company> findAllByFilters(@Param("companyStatusId") Long companyStatusId, @Param("legalTypeId") Long legalTypeId)
}