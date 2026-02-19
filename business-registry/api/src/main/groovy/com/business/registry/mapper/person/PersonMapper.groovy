package com.business.registry.mapper.person

import com.business.registry.dto.person.PersonResponseDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.Person
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class PersonMapper {

    static PersonResponseDto toPersonDto(
            Person person,
            ParametricDto country,
            ParametricDto prefecture,
            ParametricDto municipality,
            ParametricDto region
    ) {
        if (person == null) {
            return null
        }
        new PersonResponseDto(
                id: person.id,
                name: person.name,
                surname: person.surname,
                afm: person.afm,
                city: person.city,
                street: person.street,
                country: country,
                prefecture: prefecture,
                municipality: municipality,
                streetNumber: person.streetNumber,
                region: region,
                postalCode: person.postalCode,
                birthDate: person.birthDate?.toString(),
                birthPlace: person.birthPlace,
                identityNumber: person.identityNumber,
                phoneNumber: person.phoneNumber,
                changeReason: person.changeReason
        )
    }
}
