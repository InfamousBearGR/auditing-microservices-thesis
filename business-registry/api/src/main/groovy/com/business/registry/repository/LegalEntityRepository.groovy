package com.business.registry.repository

import com.business.registry.model.LegalEntity
import org.springframework.data.jpa.repository.JpaRepository

interface LegalEntityRepository extends JpaRepository<LegalEntity, Long> {
}
