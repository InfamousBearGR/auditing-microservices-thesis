package com.business.registry.repository

import com.business.registry.model.Municipality
import com.business.registry.model.Prefecture
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface MunicipalityRepository extends JpaRepository<Municipality, Long> {
    List<Municipality> findByPrefecture(Prefecture prefecture)
}

