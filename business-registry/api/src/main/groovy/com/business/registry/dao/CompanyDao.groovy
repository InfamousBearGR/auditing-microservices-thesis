package com.business.registry.dao

import com.business.registry.model.Company
import com.business.registry.repository.CompanyRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class CompanyDao {

    private final CompanyRepository companyRepository

    CompanyDao(CompanyRepository companyRepository) {
        this.companyRepository = companyRepository
    }

    List<Company> findAllCompanies() {
        return companyRepository.findAll()
    }

    Company findCompanyById(Long id) {
        return companyRepository.findById(id).orElse(null)
    }

    Company save(Company company) {
        return companyRepository.save(company)
    }

    Company saveAndFlush(Company company) {
        return companyRepository.saveAndFlush(company)
    }

    void deleteCompanyById(Long id) {
        companyRepository.deleteById(id)
    }
}

