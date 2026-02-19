package com.business.registry.repository

import com.business.registry.model.Country
import com.business.registry.model.CountryI18n
import com.business.registry.model.Language
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CountryI18nRepository extends JpaRepository<CountryI18n, Long> {
    List<CountryI18n> findByLanguage(Language language)

    CountryI18n findByCountryAndLanguage(Country country, Language language)
}
