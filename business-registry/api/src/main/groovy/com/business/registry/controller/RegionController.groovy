package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.RegionService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/region")
@CompileStatic
class RegionController {

    private final RegionService regionService

    RegionController(RegionService regionService) {
        this.regionService = regionService
    }

    @GetMapping("/translations")
    ResponseEntity<List<ParametricDto>> getAllRegionTranslations() {
        Locale locale = LocaleContextHolder.getLocale()
        List<ParametricDto> translations = regionService.findAllRegionTranslationsByLocale(locale)
        ResponseEntity.ok(translations)
    }
}

