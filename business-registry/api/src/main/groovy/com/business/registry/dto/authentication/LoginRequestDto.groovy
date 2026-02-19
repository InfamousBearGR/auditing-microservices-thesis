package com.business.registry.dto.authentication

import groovy.transform.CompileStatic
import jakarta.validation.constraints.NotBlank

@CompileStatic
class LoginRequestDto {
    @NotBlank(message = "Το.username.είναι.υποχρεωτικό")
    String username

    @NotBlank(message = "Το.password.είναι.υποχρεωτικό")
    String password
}

