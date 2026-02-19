package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.CountryService
import com.business.registry.service.LanguageService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/country")
@CompileStatic
class CountryController {

    private final CountryService countryService
    private final LanguageService languageService

    CountryController(CountryService countryService, LanguageService languageService) {
        this.countryService = countryService
        this.languageService = languageService
    }

    @GetMapping("/translations")
    ResponseEntity<List<ParametricDto>> getAllCountryTranslations() {
        Locale locale = LocaleContextHolder.getLocale()
        List<ParametricDto> translations = countryService.findAllCountryTranslationsByLocale(locale)
        ResponseEntity.ok(translations)
    }
}

