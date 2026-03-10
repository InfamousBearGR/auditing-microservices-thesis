package com.business.registry.controller

import com.business.registry.dto.companyCapital.CompanyCapitalRequestDto
import com.business.registry.dto.companyCapital.CompanyCapitalResponseDto
import com.business.registry.service.CompanyCapitalService
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/capital")
@CompileStatic
class CompanyCapitalController {
    private final CompanyCapitalService companyCapitalService

    CompanyCapitalController(CompanyCapitalService companyCapitalService) {
        this.companyCapitalService = companyCapitalService
    }

    @GetMapping("/view/{id}")
    ResponseEntity<CompanyCapitalResponseDto> getCompanyCapital(@PathVariable Long id) {
        Locale locale = LocaleContextHolder.getLocale()
        CompanyCapitalResponseDto capital = companyCapitalService.getCompanyCapital(id, locale)
        ResponseEntity.ok(capital)
    }

    @PutMapping("/update")
    ResponseEntity<Void> updateCompanyCapital(@RequestBody CompanyCapitalRequestDto capitalRequest, HttpSession session) {
        companyCapitalService.updateCompanyCapital(capitalRequest, session)
        ResponseEntity.ok().build()
    }
}
