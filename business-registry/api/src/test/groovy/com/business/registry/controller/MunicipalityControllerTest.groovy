package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.MunicipalityService
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
class MunicipalityControllerTest {

    @Mock
    MunicipalityService municipalityService

    @InjectMocks
    MunicipalityController municipalityController

    @BeforeEach
    void setUp() {
        LocaleContextHolder.setLocale(Locale.ENGLISH)
    }

    @Test
    void "getAllMunicipalityTranslations should return list of translations"() {
        // Given
        def prefectureId = 1L
        def translations = [new ParametricDto(), new ParametricDto()]
        when(municipalityService.findAllMunicipalityTranslationsByPrefectureIdAndLocale(eq(prefectureId), any(Locale.class))).thenReturn(translations)

        // When
        ResponseEntity<List<ParametricDto>> response = municipalityController.getAllMunicipalityTranslations(prefectureId)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(translations, response.body)
        verify(municipalityService).findAllMunicipalityTranslationsByPrefectureIdAndLocale(eq(prefectureId), any(Locale.class))
    }
}
