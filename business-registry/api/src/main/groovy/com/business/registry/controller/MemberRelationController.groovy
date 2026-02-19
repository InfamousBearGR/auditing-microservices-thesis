package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.MemberRelationService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/memberRelation")
@CompileStatic
class MemberRelationController {

    private final MemberRelationService memberRelationService

    MemberRelationController(MemberRelationService memberRelationService) {
        this.memberRelationService = memberRelationService
    }

    @GetMapping("/translations")
    ResponseEntity<List<ParametricDto>> getAllMemberRelationTranslations() {
        Locale locale = LocaleContextHolder.getLocale()
        List<ParametricDto> translations = memberRelationService.findAllMemberRelationTranslationsByLocale(locale)
        ResponseEntity.ok(translations)
    }
}

