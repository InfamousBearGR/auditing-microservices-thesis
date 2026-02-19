package com.business.registry.controller

import com.business.registry.dto.legalEntity.LegalEntityRequestDto
import com.business.registry.dto.legalEntity.LegalEntityResponseDto
import com.business.registry.service.LegalEntityService
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
class LegalEntityControllerTest {

    @Mock
    LegalEntityService legalEntityService

    @InjectMocks
    LegalEntityController legalEntityController

    @BeforeEach
    void setUp() {
        LocaleContextHolder.setLocale(Locale.ENGLISH)
    }

    @Test
    void "getAllLegalEntities should return list of legal entities"() {
        // Given
        def legalEntities = [new LegalEntityResponseDto(), new LegalEntityResponseDto()]
        when(legalEntityService.getAllLegalEntities(any(Locale.class))).thenReturn(legalEntities)

        // When
        ResponseEntity<List<LegalEntityResponseDto>> response = legalEntityController.getAllLegalEntities()

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(legalEntities, response.body)
        verify(legalEntityService).getAllLegalEntities(any(Locale.class))
    }

    @Test
    void "getLegalEntityById should return legal entity"() {
        // Given
        def id = 1L
        def legalEntity = new LegalEntityResponseDto()
        when(legalEntityService.getLegalEntityById(eq(id), any(Locale.class))).thenReturn(legalEntity)

        // When
        ResponseEntity<LegalEntityResponseDto> response = legalEntityController.getLegalEntityById(id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(legalEntity, response.body)
        verify(legalEntityService).getLegalEntityById(eq(id), any(Locale.class))
    }

    @Test
    void "createLegalEntity should return ok"() {
        // Given
        def requestDto = new LegalEntityRequestDto()

        // When
        ResponseEntity<Void> response = legalEntityController.createLegalEntity(requestDto)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(legalEntityService).createLegalEntity(requestDto)
    }

    @Test
    void "updateLegalEntity should return ok"() {
        // Given
        def id = 1L
        def requestDto = new LegalEntityRequestDto()

        // When
        ResponseEntity<Void> response = legalEntityController.updateLegalEntity(requestDto, id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(legalEntityService).updateLegalEntity(requestDto, id)
    }

    @Test
    void "deleteLegalEntityById should return ok"() {
        // Given
        def id = 1L

        // When
        ResponseEntity<Void> response = legalEntityController.deleteLegalEntityById(id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(legalEntityService).deleteLegalEntityById(id)
    }
}
