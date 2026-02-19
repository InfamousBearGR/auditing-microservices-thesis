package com.business.registry.repository

import com.business.registry.model.Language
import com.business.registry.model.LegalType
import com.business.registry.model.LegalTypeI18n
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface LegalTypeI18nRepository extends JpaRepository<LegalTypeI18n, Long> {
    List<LegalTypeI18n> findByLanguage(Language language)

    LegalTypeI18n findByLegalTypeAndLanguage(LegalType legalType, Language language)
}
