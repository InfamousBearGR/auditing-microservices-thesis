package com.business.registry.dao

import com.business.registry.model.Region
import com.business.registry.repository.RegionRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class RegionDao {

    private final RegionRepository regionRepository

    RegionDao(RegionRepository regionRepository) {
        this.regionRepository = regionRepository
    }

    Region findRegionById(Long id) {
        return regionRepository.findById(id).orElse(null)
    }
}

