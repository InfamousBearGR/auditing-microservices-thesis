package com.business.registry.controller

import com.business.registry.dto.company.CompanyRequestDto
import com.business.registry.dto.company.CompanyResponseDto
import com.business.registry.dto.util.DeleteRequestDto
import com.business.registry.service.CompanyService
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/company")
@CompileStatic
class CompanyController {

    private final CompanyService companyService

    CompanyController(CompanyService companyService) {
        this.companyService = companyService
    }

    @GetMapping("/index")
    ResponseEntity<List<CompanyResponseDto>> getAllCompanies(
            @RequestParam(required = false) Long companyStatusId,
            @RequestParam(required = false) Long legalTypeId) {
        Locale locale = LocaleContextHolder.getLocale()
        List<CompanyResponseDto> companies = companyService.getAllCompanies(locale, companyStatusId, legalTypeId)
        ResponseEntity.ok(companies)
    }

    @GetMapping("/view/{id}")
    ResponseEntity<CompanyResponseDto> getCompanyById(@PathVariable Long id) {
        Locale locale = LocaleContextHolder.getLocale()
        CompanyResponseDto company = companyService.getCompanyById(id, locale)
        ResponseEntity.ok(company)
    }

    @PostMapping("/create")
    ResponseEntity<Void> createCompany(@RequestBody CompanyRequestDto companyDto, HttpSession session) {
        companyService.createCompany(companyDto, session)
        ResponseEntity.ok().build()
    }

    @PutMapping("/update/{id}")
    ResponseEntity<Void> updateCompany(@RequestBody CompanyRequestDto companyDto, @PathVariable Long id, HttpSession session) {
        companyService.updateCompany(companyDto, id, session)
        ResponseEntity.ok().build()
    }

    @DeleteMapping("/delete/{id}")
    ResponseEntity<Void> deleteCompanyById(@PathVariable Long id, @RequestBody DeleteRequestDto deleteRequest, HttpSession session) {
        companyService.deleteCompanyById(id, deleteRequest.changeReason, session)
        ResponseEntity.ok().build()
    }
}
