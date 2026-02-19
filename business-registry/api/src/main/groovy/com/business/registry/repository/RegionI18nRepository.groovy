package com.business.registry.repository

import com.business.registry.model.Language
import com.business.registry.model.Region
import com.business.registry.model.RegionI18n
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface RegionI18nRepository extends JpaRepository<RegionI18n, Long> {
    List<RegionI18n> findByLanguage(Language language)

    RegionI18n findByRegionAndLanguage(Region region, Language language)
}
