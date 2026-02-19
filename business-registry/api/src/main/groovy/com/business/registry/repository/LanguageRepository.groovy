package com.business.registry.repository

import com.business.registry.model.Language
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface LanguageRepository extends JpaRepository<Language, Long> {
    Language findByCode(String code)
}

