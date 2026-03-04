package com.business.registry.dao

import com.business.registry.model.CompanyCapital
import com.business.registry.repository.CompanyCapitalRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class CompanyCapitalDao implements CascadableDao<CompanyCapital> {

    private final CompanyCapitalRepository companyCapitalRepository

    CompanyCapitalDao(CompanyCapitalRepository companyCapitalRepository) {
        this.companyCapitalRepository = companyCapitalRepository
    }

    List<CompanyCapital> findAllByCompanyId(Long companyId) {
        return companyCapitalRepository.findAllByCompanyId(companyId)
    }

    @Override
    CompanyCapital save(CompanyCapital companyCapital) {
        return companyCapitalRepository.save(companyCapital)
    }

    @Override
    CompanyCapital saveAndFlush(CompanyCapital companyCapital) {
        return companyCapitalRepository.saveAndFlush(companyCapital)
    }

    @Override
    void deleteById(Long id) {
        companyCapitalRepository.deleteById(id)
    }
}
