package com.business.registry.controller

import com.business.registry.dto.member.MemberRequestDto
import com.business.registry.dto.member.MemberResponseDto
import com.business.registry.service.MemberService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/member")
@CompileStatic
class MemberController {

    private final MemberService memberService

    MemberController(MemberService memberService) {
        this.memberService = memberService
    }

    @GetMapping("/index/{companyId}")
    ResponseEntity<List<MemberResponseDto>> getAllMembersByCompanyId(@PathVariable Long companyId) {
        Locale locale = LocaleContextHolder.getLocale()
        List<MemberResponseDto> members = memberService.getAllMembersByCompanyId(companyId, locale)
        ResponseEntity.ok(members)
    }

    @GetMapping("/view/{id}")
    ResponseEntity<MemberResponseDto> getMemberById(@PathVariable Long id) {
        Locale locale = LocaleContextHolder.getLocale()
        MemberResponseDto member = memberService.getMemberById(id, locale)
        ResponseEntity.ok(member)
    }

    @PostMapping("/create")
    ResponseEntity<Void> createMember(@RequestBody MemberRequestDto memberDto) {
        memberService.createMember(memberDto)
        ResponseEntity.ok().build()
    }

    @PutMapping("/update/{id}")
    ResponseEntity<Void> updateMember(@RequestBody MemberRequestDto memberDto, @PathVariable Long id) {
        memberService.updateMember(memberDto, id)
        ResponseEntity.ok().build()
    }

    @DeleteMapping("/delete/{id}")
    ResponseEntity<Void> deleteMemberById(@PathVariable Long id) {
        memberService.deleteMemberById(id)
        ResponseEntity.ok().build()
    }
}
