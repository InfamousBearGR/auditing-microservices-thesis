package com.business.registry.service

import com.business.registry.dto.member.LegalEntityDto
import com.business.registry.dto.member.MemberRequestDto
import com.business.registry.dto.member.MemberResponseDto
import com.business.registry.dto.member.PersonDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.exception.NotFoundException
import com.business.registry.mapper.member.MemberMapper
import com.business.registry.model.*
import com.business.registry.repository.MemberRepository
import com.business.registry.repository.UserAccountRepository
import com.business.registry.validation.MemberValidation
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import java.time.LocalDate

@Service
@CompileStatic
class MemberService {
    private final MemberRepository memberRepository
    private final MemberMapper memberMapper
    private final MemberValidation memberValidation
    private final UserAccountRepository userAccountRepository

    @Autowired
    PersonService personService

    @Autowired
    LegalEntityService legalEntityService

    @Autowired
    CompanyService companyService

    @Autowired
    MemberRelationService memberRelationService

    @Autowired
    MessageService messageService

    @Autowired
    AuthenticationService authenticationService

    MemberService(
            MemberRepository memberRepository,
            MemberMapper memberMapper,
            PersonService personService,
            LegalEntityService legalEntityService,
            CompanyService companyService,
            MemberRelationService memberRelationService,
            MessageService messageService,
            MemberValidation memberValidation,
            UserAccountRepository userAccountRepository,
            AuthenticationService authenticationService
    ) {
        this.memberRepository = memberRepository
        this.memberMapper = memberMapper
        this.personService = personService
        this.legalEntityService = legalEntityService
        this.companyService = companyService
        this.memberRelationService = memberRelationService
        this.messageService = messageService
        this.memberValidation = memberValidation
        this.userAccountRepository = userAccountRepository
        this.authenticationService = authenticationService
    }

    @Transactional(readOnly = true)
    List<MemberResponseDto> getAllMembersByCompanyId(Long companyId, Locale locale) {
        Company company = companyService.findCompanyById(companyId)
        if (company == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Επιχείρηση.με.id.", [companyId] as Object[]))
        }
        return memberRepository.findAllByCompany(company).collect { member ->
            mapToMemberResponseDto(member, locale)
        }
    }

    @Transactional(readOnly = true)
    MemberResponseDto getMemberById(Long id, Locale locale) {
        memberValidation.validateFindById(id)
        Member member = memberRepository.findById(id).orElse(null)
        if (member == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Εταίρος.με.id.", [id] as Object[]))
        }
        return mapToMemberResponseDto(member, locale)
    }

    @Transactional
    void updateMember(MemberRequestDto memberDto, Long id, HttpSession session) {
        memberValidation.validateUpdate(memberDto, id)
        Member member = memberRepository.findById(id).orElse(null)
        if (member == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Εταίρος.με.id.", [id] as Object[]))
        }
        populateMemberFromDto(member, memberDto, session)
        memberRepository.save(member)
    }

    @Transactional
    void createMember(MemberRequestDto memberDto, HttpSession session) {
        memberValidation.validateMemberRequestDto(memberDto)
        Member member = new Member()
        populateMemberFromDto(member, memberDto, session)
        memberRepository.save(member)
    }

    @Transactional
    void deleteMemberById(Long id, String changeReason, HttpSession session) {
        memberValidation.validateDeleteById(id)
        if (!memberRepository.existsById(id)) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Εταίρος.με.id.", [id] as Object[]))
        }
        Member member = memberRepository.findById(id).orElse(null)
        UserAccount user = userAccountRepository.findById(AuthenticationService.getCurrentUserId(session)).orElse(null)
        member.changeReason = changeReason
        member.lastUser = user
        memberRepository.saveAndFlush(member)
        memberRepository.deleteById(id)
    }

    private MemberResponseDto mapToMemberResponseDto(Member member, Locale locale) {
        PersonDto person = member.person ? memberMapper.toPersonDto(personService.findPersonById(member.person.id)) : null
        LegalEntityDto legalEntity = member.legalEntity ? memberMapper.toLegalEntityDto(legalEntityService.findLegalEntityById(member.legalEntity.id)) : null
        PersonDto representativeOfMember = member.representativeOfMember ? memberMapper.toPersonDto(personService.findPersonById(member.representativeOfMember.id)) : null
        ParametricDto memberRelation = memberRelationService.findMemberRelationTranslationByLocaleAndMemberRelation(locale, member.memberRelation)
        return memberMapper.toMemberDto(member, person, legalEntity, representativeOfMember, memberRelation)
    }

    private void populateMemberFromDto(Member member, MemberRequestDto memberDto, HttpSession session) {
        Person person = memberDto.personId ? personService.findPersonById(memberDto.personId) : null
        LegalEntity legalEntity = memberDto.legalEntityId ? legalEntityService.findLegalEntityById(memberDto.legalEntityId) : null
        if (person == null && legalEntity == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.ούτε.Φυσικό.ούτε.Νομικό.Πρόσωπο.με.id.", [memberDto.personId, memberDto.legalEntityId] as Object[]))
        }
        Company company = companyService.findCompanyById(memberDto.companyId)
        if (company == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Επιχείρηση.με.id.", [memberDto.companyId] as Object[]))
        }
        Person representativeOfMember = null
        if (memberDto.representativeOfMemberId) {
            representativeOfMember = personService.findPersonById(memberDto.representativeOfMemberId)
            if (representativeOfMember == null) {
                throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Εκπρόσωπος.με.id.", [memberDto.representativeOfMemberId] as Object[]))
            }
        }
        MemberRelation memberRelation = memberRelationService.findMemberRelationById(memberDto.memberRelationId)
        if (memberRelation == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Κατηγορία.μέλους.με.id.", [memberDto.memberRelationId] as Object[]))
        }
        UserAccount user = userAccountRepository.findById(AuthenticationService.getCurrentUserId(session)).orElse(null)
        member.active = memberDto.active
        member.dateFrom = memberDto.dateFrom ? LocalDate.parse(memberDto.dateFrom) : null
        member.dateTo = memberDto.dateTo ? LocalDate.parse(memberDto.dateTo) : null
        member.percentageOfOwnership = memberDto.percentageOfOwnership
        member.person = person
        member.legalEntity = legalEntity
        member.company = company
        member.representativeOfMember = representativeOfMember
        member.representedIndividual = memberDto.representedIndividual
        member.representedTogether = memberDto.representedTogether
        member.memberRelation = memberRelation
        member.lastUser = user
        member.changeReason = memberDto.changeReason
    }
}
