package com.business.registry.repository

import com.business.registry.model.Prefecture
import com.business.registry.model.Region
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface PrefectureRepository extends JpaRepository<Prefecture, Long> {
        List<Prefecture> findByRegion(Region region)
}

