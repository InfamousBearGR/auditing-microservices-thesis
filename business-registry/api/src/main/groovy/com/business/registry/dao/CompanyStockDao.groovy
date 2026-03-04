package com.business.registry.dao

import com.business.registry.model.CompanyStock
import com.business.registry.repository.CompanyStockRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class CompanyStockDao implements CascadableDao<CompanyStock> {

    private final CompanyStockRepository companyStockRepository

    CompanyStockDao(CompanyStockRepository companyStockRepository) {
        this.companyStockRepository = companyStockRepository
    }

    List<CompanyStock> findAllByCompanyId(Long companyId) {
        return companyStockRepository.findAllByCompanyId(companyId)
    }

    @Override
    CompanyStock save(CompanyStock companyStock) {
        return companyStockRepository.save(companyStock)
    }

    @Override
    CompanyStock saveAndFlush(CompanyStock companyStock) {
        return companyStockRepository.saveAndFlush(companyStock)
    }

    @Override
    void deleteById(Long id) {
        companyStockRepository.deleteById(id)
    }
}
