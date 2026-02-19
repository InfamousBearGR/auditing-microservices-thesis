package com.business.registry.controller

import com.business.registry.dto.authentication.LoginRequestDto
import com.business.registry.dto.authentication.LoginResponseDto
import com.business.registry.dto.authentication.LogoutResponseDto
import com.business.registry.service.AuthenticationService
import com.business.registry.service.MessageService
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import jakarta.validation.Valid
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/auth")
@CompileStatic
class AuthenticationController {

    @Autowired
    AuthenticationService authenticationService

    @Autowired
    MessageService messageService

    @PostMapping("/login")
    ResponseEntity<LoginResponseDto> login(@Valid @RequestBody LoginRequestDto loginRequest, HttpSession session) {
        return ResponseEntity.ok(authenticationService.handleLogin(loginRequest, session))
    }

    @PostMapping("/logout")
    ResponseEntity<LogoutResponseDto> logout(HttpSession session) {
        return ResponseEntity.ok(authenticationService.handleLogout(session))
    }

    @GetMapping("/status")
    ResponseEntity<LoginResponseDto> getStatus(HttpSession session) {
        return ResponseEntity.ok(authenticationService.handleGetStatus(session))
    }
}

