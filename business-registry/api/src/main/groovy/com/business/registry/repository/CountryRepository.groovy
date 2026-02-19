package com.business.registry.repository

import com.business.registry.model.Country
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CountryRepository extends JpaRepository<Country, Long> {
}

