package com.business.registry.repository

import com.business.registry.model.CompanyStatus
import com.business.registry.model.CompanyStatusI18n
import com.business.registry.model.Language
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CompanyStatusI18nRepository extends JpaRepository<CompanyStatusI18n, Long> {
    List<CompanyStatusI18n> findByLanguage(Language language)

    CompanyStatusI18n findByCompanyStatusAndLanguage(CompanyStatus companyStatus, Language language)
}

