package com.business.registry.dao

import com.business.registry.model.CompanyStatus
import com.business.registry.repository.CompanyStatusRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class CompanyStatusDao {

    private final CompanyStatusRepository companyStatusRepository

    CompanyStatusDao(CompanyStatusRepository companyStatusRepository) {
        this.companyStatusRepository = companyStatusRepository
    }

    CompanyStatus findCompanyStatusById(Long id) {
        return companyStatusRepository.findById(id).orElse(null)
    }
}
