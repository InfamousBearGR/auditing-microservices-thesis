package com.business.registry.dto.util

import groovy.transform.CompileStatic

@CompileStatic
class ErrorResponseDto {

    String message
    Integer status

    ErrorResponseDto(String message, Integer status) {
        this.message = message
        this.status = status
    }
}

