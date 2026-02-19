package com.business.registry.mapper.member

import com.business.registry.dto.member.LegalEntityDto
import com.business.registry.dto.member.MemberResponseDto
import com.business.registry.dto.member.PersonDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.model.LegalEntity
import com.business.registry.model.Member
import com.business.registry.model.Person
import groovy.transform.CompileStatic
import org.springframework.stereotype.Component

@Component
@CompileStatic
class MemberMapper {

    static PersonDto toPersonDto(Person person) {
        if (person == null) {
            return null
        }
        new PersonDto(
                name: person.name,
                surname: person.surname,
                afm: person.afm,
        )
    }

    static LegalEntityDto toLegalEntityDto(LegalEntity legalEntity) {
        if (legalEntity == null) {
            return null
        }
        new LegalEntityDto(
                businessName: legalEntity.businessName,
                afm: legalEntity.afm,
        )
    }

    static MemberResponseDto toMemberDto(
            Member member,
            PersonDto person,
            LegalEntityDto legalEntity,
            PersonDto representativeOfMember,
            ParametricDto memberRelation
    ) {
        if (member == null) {
            return null
        }
        new MemberResponseDto(
                id: member.id,
                active: member.active,
                dateFrom: member.dateFrom?.toString(),
                dateTo: member.dateTo?.toString(),
                percentageOfOwnership: member.percentageOfOwnership,
                person: person,
                legalEntity: legalEntity,
                representativeOfMember: representativeOfMember,
                representedIndividual: member.representedIndividual,
                representedTogether: member.representedTogether,
                memberRelation: memberRelation,
        )
    }
}
