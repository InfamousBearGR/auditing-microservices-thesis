package com.business.registry.repository

import com.business.registry.model.Person
import org.springframework.data.jpa.repository.JpaRepository

interface PersonRepository extends JpaRepository<Person, Long> {
}
