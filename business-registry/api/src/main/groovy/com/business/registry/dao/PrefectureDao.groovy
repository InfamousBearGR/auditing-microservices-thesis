package com.business.registry.dao

import com.business.registry.model.Prefecture
import com.business.registry.model.Region
import com.business.registry.repository.PrefectureRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class PrefectureDao {

    private final PrefectureRepository prefectureRepository

    PrefectureDao(PrefectureRepository prefectureRepository) {
        this.prefectureRepository = prefectureRepository
    }

    Prefecture findPrefectureById(Long id) {
        return prefectureRepository.findById(id).orElse(null)
    }

    List<Prefecture> findPrefecturesByRegion(Region region) {
        return prefectureRepository.findByRegion(region)
    }
}

