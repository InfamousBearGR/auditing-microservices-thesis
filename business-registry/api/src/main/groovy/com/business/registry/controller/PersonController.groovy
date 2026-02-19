package com.business.registry.controller

import com.business.registry.dto.person.PersonRequestDto
import com.business.registry.dto.person.PersonResponseDto
import com.business.registry.service.PersonService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/person")
@CompileStatic
class PersonController {

    private final PersonService personService

    PersonController(PersonService personService) {
        this.personService = personService
    }

    @GetMapping("/index")
    ResponseEntity<List<PersonResponseDto>> getAllPersons() {
        Locale locale = LocaleContextHolder.getLocale()
        List<PersonResponseDto> persons = personService.getAllPersons(locale)
        ResponseEntity.ok(persons)
    }

    @GetMapping("/view/{id}")
    ResponseEntity<PersonResponseDto> getPersonById(@PathVariable Long id) {
        Locale locale = LocaleContextHolder.getLocale()
        PersonResponseDto person = personService.getPersonById(id, locale)
        ResponseEntity.ok(person)
    }

    @PostMapping("/create")
    ResponseEntity<Void> createPerson(@RequestBody PersonRequestDto personDto) {
        personService.createPerson(personDto)
        ResponseEntity.ok().build()
    }

    @PutMapping("/update/{id}")
    ResponseEntity<Void> updatePerson(@RequestBody PersonRequestDto personDto, @PathVariable Long id) {
        personService.updatePerson(personDto, id)
        ResponseEntity.ok().build()
    }

    @DeleteMapping("/delete/{id}")
    ResponseEntity<Void> deletePersonById(@PathVariable Long id) {
        personService.deletePersonById(id)
        ResponseEntity.ok().build()
    }
}
