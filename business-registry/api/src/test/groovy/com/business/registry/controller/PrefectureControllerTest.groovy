package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.PrefectureService
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
class PrefectureControllerTest {

    @Mock
    PrefectureService prefectureService

    @InjectMocks
    PrefectureController prefectureController

    @BeforeEach
    void setUp() {
        LocaleContextHolder.setLocale(Locale.ENGLISH)
    }

    @Test
    void "getAllPrefectureTranslations should return list of translations"() {
        // Given
        def regionId = 1L
        def translations = [new ParametricDto(), new ParametricDto()]
        when(prefectureService.findAllPrefectureTranslationsByRegionIdLocale(eq(regionId), any(Locale.class))).thenReturn(translations)

        // When
        ResponseEntity<List<ParametricDto>> response = prefectureController.getAllPrefectureTranslations(regionId)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(translations, response.body)
        verify(prefectureService).findAllPrefectureTranslationsByRegionIdLocale(eq(regionId), any(Locale.class))
    }
}
