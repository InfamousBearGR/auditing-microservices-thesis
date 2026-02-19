package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.PrefectureService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/prefecture")
@CompileStatic
class PrefectureController {

    private final PrefectureService prefectureService

    PrefectureController(PrefectureService prefectureService) {
        this.prefectureService = prefectureService
    }

    @GetMapping("/translations/{regionId}")
    ResponseEntity<List<ParametricDto>> getAllPrefectureTranslations(@PathVariable (required = true) Long regionId) {
        Locale locale = LocaleContextHolder.getLocale()
        List<ParametricDto> translations = prefectureService.findAllPrefectureTranslationsByRegionIdLocale(regionId, locale)
        ResponseEntity.ok(translations)
    }
}

