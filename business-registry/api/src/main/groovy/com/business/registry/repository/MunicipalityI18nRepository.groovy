package com.business.registry.repository

import com.business.registry.model.Language
import com.business.registry.model.Municipality
import com.business.registry.model.MunicipalityI18n
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface MunicipalityI18nRepository extends JpaRepository<MunicipalityI18n, Long> {
    List<MunicipalityI18n> findByMunicipalityInAndLanguage(Collection<Municipality> municipalities, Language language)

    MunicipalityI18n findByMunicipalityAndLanguage(Municipality municipality, Language language)
}
