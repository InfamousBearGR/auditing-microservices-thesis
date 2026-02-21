package com.business.registry.dao

import com.business.registry.model.Country
import com.business.registry.repository.CountryRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class CountryDao {

    private final CountryRepository countryRepository

    CountryDao(CountryRepository countryRepository) {
        this.countryRepository = countryRepository
    }

    Country findCountryById(Long id) {
        return countryRepository.findById(id).orElse(null)
    }
}

