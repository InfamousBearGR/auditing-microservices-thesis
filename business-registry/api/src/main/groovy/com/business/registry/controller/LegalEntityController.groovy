package com.business.registry.controller

import com.business.registry.dto.legalEntity.LegalEntityRequestDto
import com.business.registry.dto.legalEntity.LegalEntityResponseDto
import com.business.registry.dto.util.DeleteRequestDto
import com.business.registry.service.LegalEntityService
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/legalEntity")
@CompileStatic
class LegalEntityController {

    private final LegalEntityService legalEntityService

    LegalEntityController(LegalEntityService legalEntityService) {
        this.legalEntityService = legalEntityService
    }

    @GetMapping("/index")
    ResponseEntity<List<LegalEntityResponseDto>> getAllLegalEntities() {
        Locale locale = LocaleContextHolder.getLocale()
        List<LegalEntityResponseDto> legalEntities = legalEntityService.getAllLegalEntities(locale)
        ResponseEntity.ok(legalEntities)
    }

    @GetMapping("/view/{id}")
    ResponseEntity<LegalEntityResponseDto> getLegalEntityById(@PathVariable Long id) {
        Locale locale = LocaleContextHolder.getLocale()
        LegalEntityResponseDto legalEntity = legalEntityService.getLegalEntityById(id, locale)
        ResponseEntity.ok(legalEntity)
    }

    @PostMapping("/create")
    ResponseEntity<Void> createLegalEntity(@RequestBody LegalEntityRequestDto legalEntityDto, HttpSession session) {
        legalEntityService.createLegalEntity(legalEntityDto, session)
        ResponseEntity.ok().build()
    }

    @PutMapping("/update/{id}")
    ResponseEntity<Void> updateLegalEntity(@RequestBody LegalEntityRequestDto legalEntityDto, @PathVariable Long id, HttpSession session) {
        legalEntityService.updateLegalEntity(legalEntityDto, id, session)
        ResponseEntity.ok().build()
    }

    @DeleteMapping("/delete/{id}")
    ResponseEntity<Void> deleteLegalEntityById(@PathVariable Long id, @RequestBody DeleteRequestDto deleteRequest, HttpSession session) {
        legalEntityService.deleteLegalEntityById(id, deleteRequest.changeReason, session)
        ResponseEntity.ok().build()
    }
}
