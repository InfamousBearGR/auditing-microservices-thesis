package com.business.registry.repository

import com.business.registry.model.Region
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface RegionRepository extends JpaRepository<Region, Long> {
}

