package com.business.registry.repository

import com.business.registry.model.LegalType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface LegalTypeRepository extends JpaRepository<LegalType, Long> {
}

