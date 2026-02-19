package com.business.registry.dto.authentication

import groovy.transform.CompileStatic

@CompileStatic
class LoginResponseDto {
    Long userId
    String username
    Boolean authenticated
    Long role
}
