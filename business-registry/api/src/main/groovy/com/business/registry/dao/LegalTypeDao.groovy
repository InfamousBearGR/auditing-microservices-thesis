package com.business.registry.dao

import com.business.registry.model.LegalType
import com.business.registry.repository.LegalTypeRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class LegalTypeDao {

    private final LegalTypeRepository legalTypeRepository

    LegalTypeDao(LegalTypeRepository legalTypeRepository) {
        this.legalTypeRepository = legalTypeRepository
    }

    LegalType findLegalTypeById(Long id) {
        return legalTypeRepository.findById(id).orElse(null)
    }
}

