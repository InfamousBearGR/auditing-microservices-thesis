package com.business.registry.controller

import com.business.registry.dto.company.CompanyRequestDto
import com.business.registry.dto.company.CompanyResponseDto
import com.business.registry.service.CompanyService
import groovy.transform.CompileStatic
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
    ResponseEntity<List<CompanyResponseDto>> getAllCompanies() {
        Locale locale = LocaleContextHolder.getLocale()
        List<CompanyResponseDto> companies = companyService.getAllCompanies(locale)
        ResponseEntity.ok(companies)
    }

    @GetMapping("/view/{id}")
    ResponseEntity<CompanyResponseDto> getCompanyById(@PathVariable Long id) {
        Locale locale = LocaleContextHolder.getLocale()
        CompanyResponseDto company = companyService.getCompanyById(id, locale)
        ResponseEntity.ok(company)
    }

    @PostMapping("/create")
    ResponseEntity<Void> createCompany(@RequestBody CompanyRequestDto companyDto) {
        companyService.createCompany(companyDto)
        ResponseEntity.ok().build()
    }

    @PutMapping("/update/{id}")
    ResponseEntity<Void> updateCompany(@RequestBody CompanyRequestDto companyDto, @PathVariable Long id) {
        companyService.updateCompany(companyDto, id)
        ResponseEntity.ok().build()
    }

    @DeleteMapping("/delete/{id}")
    ResponseEntity<Void> deleteCompanyById(@PathVariable Long id) {
        companyService.deleteCompanyById(id)
        ResponseEntity.ok().build()
    }
}
