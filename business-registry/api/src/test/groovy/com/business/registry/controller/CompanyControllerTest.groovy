package com.business.registry.controller

import com.business.registry.dto.company.CompanyRequestDto
import com.business.registry.dto.company.CompanyResponseDto
import com.business.registry.service.CompanyService
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity

import static org.junit.jupiter.api.Assertions.assertEquals
import static org.mockito.ArgumentMatchers.any
import static org.mockito.ArgumentMatchers.eq
import static org.mockito.Mockito.verify
import static org.mockito.Mockito.when

@ExtendWith(MockitoExtension.class)
class CompanyControllerTest {

    @Mock
    CompanyService companyService

    @InjectMocks
    CompanyController companyController

    @BeforeEach
    void setUp() {
        LocaleContextHolder.setLocale(Locale.ENGLISH)
    }

    @Test
    void "getAllCompanies should return list of companies"() {
        // Given
        def companies = [new CompanyResponseDto(), new CompanyResponseDto()]
        when(companyService.getAllCompanies(any(Locale.class))).thenReturn(companies)

        // When
        ResponseEntity<List<CompanyResponseDto>> response = companyController.getAllCompanies()

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(companies, response.body)
        verify(companyService).getAllCompanies(any(Locale.class))
    }

    @Test
    void "getCompanyById should return company"() {
        // Given
        def id = 1L
        def company = new CompanyResponseDto()
        when(companyService.getCompanyById(eq(id), any(Locale.class))).thenReturn(company)

        // When
        ResponseEntity<CompanyResponseDto> response = companyController.getCompanyById(id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(company, response.body)
        verify(companyService).getCompanyById(eq(id), any(Locale.class))
    }

    @Test
    void "createCompany should return ok"() {
        // Given
        def requestDto = new CompanyRequestDto()

        // When
        ResponseEntity<Void> response = companyController.createCompany(requestDto)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(companyService).createCompany(requestDto)
    }

    @Test
    void "updateCompany should return ok"() {
        // Given
        def id = 1L
        def requestDto = new CompanyRequestDto()

        // When
        ResponseEntity<Void> response = companyController.updateCompany(requestDto, id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(companyService).updateCompany(requestDto, id)
    }

    @Test
    void "deleteCompanyById should return ok"() {
        // Given
        def id = 1L

        // When
        ResponseEntity<Void> response = companyController.deleteCompanyById(id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(companyService).deleteCompanyById(id)
    }
}
