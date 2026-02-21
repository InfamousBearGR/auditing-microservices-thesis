package com.business.registry.repository

import com.business.registry.model.LegalEntity
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface LegalEntityRepository extends JpaRepository<LegalEntity, Long> {
}
