package com.business.registry.dao

import com.business.registry.model.LegalEntity
import com.business.registry.repository.LegalEntityRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class LegalEntityDao {

    private final LegalEntityRepository legalEntityRepository

    LegalEntityDao(LegalEntityRepository legalEntityRepository) {
        this.legalEntityRepository = legalEntityRepository
    }

    List<LegalEntity> findAllLegalEntities() {
        return legalEntityRepository.findAll()
    }

    LegalEntity findLegalEntityById(Long id) {
        return legalEntityRepository.findById(id).orElse(null)
    }

    boolean existsById(Long id) {
        return legalEntityRepository.existsById(id)
    }

    LegalEntity save(LegalEntity legalEntity) {
        return legalEntityRepository.save(legalEntity)
    }

    LegalEntity saveAndFlush(LegalEntity legalEntity) {
        return legalEntityRepository.saveAndFlush(legalEntity)
    }

    void deleteLegalEntityById(Long id) {
        legalEntityRepository.deleteById(id)
    }
}

