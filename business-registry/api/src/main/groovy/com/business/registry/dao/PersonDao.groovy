package com.business.registry.dao

import com.business.registry.model.Person
import com.business.registry.repository.PersonRepository
import groovy.transform.CompileStatic
import org.springframework.stereotype.Repository

@CompileStatic
@Repository
class PersonDao {

    private final PersonRepository personRepository

    PersonDao(PersonRepository personRepository) {
        this.personRepository = personRepository
    }

    List<Person> findAllPersons() {
        return personRepository.findAll()
    }

    Person findPersonById(Long id) {
        return personRepository.findById(id).orElse(null)
    }

    boolean existsById(Long id) {
        return personRepository.existsById(id)
    }

    Person savePerson(Person person) {
        return personRepository.save(person)
    }

    void deletePersonById(Long id) {
        personRepository.deleteById(id)
    }
}

