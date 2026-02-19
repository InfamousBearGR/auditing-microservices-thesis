package com.business.registry.controller

import com.business.registry.dto.authentication.LoginRequestDto
import com.business.registry.dto.authentication.LoginResponseDto
import com.business.registry.dto.authentication.LogoutResponseDto
import com.business.registry.service.AuthenticationService
import com.business.registry.service.MessageService
import jakarta.servlet.http.HttpSession
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity

import static org.junit.jupiter.api.Assertions.assertEquals
import static org.mockito.ArgumentMatchers.any
import static org.mockito.Mockito.verify
import static org.mockito.Mockito.when

@ExtendWith(MockitoExtension.class)
class AuthenticationControllerTest {

    @Mock
    AuthenticationService authenticationService

    @Mock
    MessageService messageService

    @Mock
    HttpSession session

    @InjectMocks
    AuthenticationController authenticationController

    @Test
    void "login should return login response"() {
        // Given
        def loginRequest = new LoginRequestDto()
        def loginResponse = new LoginResponseDto()
        when(authenticationService.handleLogin(any(LoginRequestDto.class), any(HttpSession.class))).thenReturn(loginResponse)

        // When
        ResponseEntity<LoginResponseDto> response = authenticationController.login(loginRequest, session)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(loginResponse, response.body)
        verify(authenticationService).handleLogin(loginRequest, session)
    }

    @Test
    void "logout should return logout response"() {
        // Given
        def logoutResponse = new LogoutResponseDto()
        when(authenticationService.handleLogout(any(HttpSession.class))).thenReturn(logoutResponse)

        // When
        ResponseEntity<LogoutResponseDto> response = authenticationController.logout(session)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(logoutResponse, response.body)
        verify(authenticationService).handleLogout(session)
    }

    @Test
    void "getStatus should return login response"() {
        // Given
        def loginResponse = new LoginResponseDto()
        when(authenticationService.handleGetStatus(any(HttpSession.class))).thenReturn(loginResponse)

        // When
        ResponseEntity<LoginResponseDto> response = authenticationController.getStatus(session)

        // Then
        assertEquals(HttpStatus.OK, response.statusCode)
        assertEquals(loginResponse, response.body)
        verify(authenticationService).handleGetStatus(session)
    }
}
