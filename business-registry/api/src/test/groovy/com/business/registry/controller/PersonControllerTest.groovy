package com.business.registry.controller

import com.business.registry.dto.person.PersonRequestDto
import com.business.registry.dto.person.PersonResponseDto
import com.business.registry.service.PersonService
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
class PersonControllerTest {

    @Mock
    PersonService personService

    @InjectMocks
    PersonController personController

    @BeforeEach
    void setUp() {
        LocaleContextHolder.setLocale(Locale.ENGLISH)
    }

    @Test
    void "getAllPersons should return list of persons"() {
        // Given
        def persons = [new PersonResponseDto(), new PersonResponseDto()]
        when(personService.getAllPersons(any(Locale.class))).thenReturn(persons)

        // When
        ResponseEntity<List<PersonResponseDto>> response = personController.getAllPersons()

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(persons, response.body)
        verify(personService).getAllPersons(any(Locale.class))
    }

    @Test
    void "getPersonById should return person"() {
        // Given
        def id = 1L
        def person = new PersonResponseDto()
        when(personService.getPersonById(eq(id), any(Locale.class))).thenReturn(person)

        // When
        ResponseEntity<PersonResponseDto> response = personController.getPersonById(id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(person, response.body)
        verify(personService).getPersonById(eq(id), any(Locale.class))
    }

    @Test
    void "createPerson should return ok"() {
        // Given
        def requestDto = new PersonRequestDto()

        // When
        ResponseEntity<Void> response = personController.createPerson(requestDto)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(personService).createPerson(requestDto)
    }

    @Test
    void "updatePerson should return ok"() {
        // Given
        def id = 1L
        def requestDto = new PersonRequestDto()

        // When
        ResponseEntity<Void> response = personController.updatePerson(requestDto, id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(personService).updatePerson(requestDto, id)
    }

    @Test
    void "deletePersonById should return ok"() {
        // Given
        def id = 1L

        // When
        ResponseEntity<Void> response = personController.deletePersonById(id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(personService).deletePersonById(id)
    }
}
