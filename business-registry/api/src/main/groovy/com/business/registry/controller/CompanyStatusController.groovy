package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.CompanyStatusService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/companyStatus")
@CompileStatic
class CompanyStatusController {

    private final CompanyStatusService companyStatusService

    CompanyStatusController(CompanyStatusService companyStatusService) {
        this.companyStatusService = companyStatusService
    }

    @GetMapping("/translations")
    ResponseEntity<List<ParametricDto>> getAllCompanyStatusTranslations() {
        Locale locale = LocaleContextHolder.getLocale()
        List<ParametricDto> translations = companyStatusService.findAllCompanyStatusTranslationsByLocale(locale)
        ResponseEntity.ok(translations)
    }
}

