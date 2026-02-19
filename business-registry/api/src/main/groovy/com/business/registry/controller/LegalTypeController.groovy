package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.LegalTypeService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/legalType")
@CompileStatic
class LegalTypeController {

    private final LegalTypeService legalTypeService

    LegalTypeController(LegalTypeService legalTypeService) {
        this.legalTypeService = legalTypeService
    }

    @GetMapping("/translations")
    ResponseEntity<List<ParametricDto>> getAllLegalTypeTranslations() {
        Locale locale = LocaleContextHolder.getLocale()
        List<ParametricDto> translations = legalTypeService.findAllLegalTypeTranslationsByLocale(locale)
        ResponseEntity.ok(translations)
    }
}

