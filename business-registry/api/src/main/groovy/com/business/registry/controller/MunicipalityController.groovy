package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.MunicipalityService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/municipality")
@CompileStatic
class MunicipalityController {

    private final MunicipalityService municipalityService

    MunicipalityController(MunicipalityService municipalityService) {
        this.municipalityService = municipalityService
    }

    @GetMapping("/translations/{prefectureId}")
    ResponseEntity<List<ParametricDto>> getAllMunicipalityTranslations(@PathVariable(required = true) Long prefectureId) {
        Locale locale = LocaleContextHolder.getLocale()
        List<ParametricDto> translations = municipalityService.findAllMunicipalityTranslationsByPrefectureIdAndLocale(prefectureId, locale)
        ResponseEntity.ok(translations)
    }
}

