package com.business.registry.controller

import com.business.registry.dto.member.MemberRequestDto
import com.business.registry.dto.member.MemberResponseDto
import com.business.registry.service.MemberService
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
class MemberControllerTest {

    @Mock
    MemberService memberService

    @InjectMocks
    MemberController memberController

    @BeforeEach
    void setUp() {
        LocaleContextHolder.setLocale(Locale.ENGLISH)
    }

    @Test
    void "getAllMembersByCompanyId should return list of members"() {
        // Given
        def companyId = 1L
        def members = [new MemberResponseDto(), new MemberResponseDto()]
        when(memberService.getAllMembersByCompanyId(eq(companyId), any(Locale.class))).thenReturn(members)

        // When
        ResponseEntity<List<MemberResponseDto>> response = memberController.getAllMembersByCompanyId(companyId)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(members, response.body)
        verify(memberService).getAllMembersByCompanyId(eq(companyId), any(Locale.class))
    }

    @Test
    void "getMemberById should return member"() {
        // Given
        def id = 1L
        def member = new MemberResponseDto()
        when(memberService.getMemberById(eq(id), any(Locale.class))).thenReturn(member)

        // When
        ResponseEntity<MemberResponseDto> response = memberController.getMemberById(id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(member, response.body)
        verify(memberService).getMemberById(eq(id), any(Locale.class))
    }

    @Test
    void "createMember should return ok"() {
        // Given
        def requestDto = new MemberRequestDto()

        // When
        ResponseEntity<Void> response = memberController.createMember(requestDto)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(memberService).createMember(requestDto)
    }

    @Test
    void "updateMember should return ok"() {
        // Given
        def id = 1L
        def requestDto = new MemberRequestDto()

        // When
        ResponseEntity<Void> response = memberController.updateMember(requestDto, id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(memberService).updateMember(requestDto, id)
    }

    @Test
    void "deleteMemberById should return ok"() {
        // Given
        def id = 1L

        // When
        ResponseEntity<Void> response = memberController.deleteMemberById(id)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        verify(memberService).deleteMemberById(id)
    }
}
