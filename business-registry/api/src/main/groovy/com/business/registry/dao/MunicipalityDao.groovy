package com.business.registry.dao

import com.business.registry.model.Municipality
import com.business.registry.model.Prefecture
import com.business.registry.repository.MunicipalityRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class MunicipalityDao {

    private final MunicipalityRepository municipalityRepository

    MunicipalityDao(MunicipalityRepository municipalityRepository) {
        this.municipalityRepository = municipalityRepository
    }

    Municipality findMunicipalityById(Long id) {
        return municipalityRepository.findById(id).orElse(null)
    }

    List<Municipality> findMunicipalitiesByPrefecture(Prefecture prefecture) {
        return municipalityRepository.findByPrefecture(prefecture)
    }
}

