package com.business.registry.exception

import groovy.transform.CompileStatic

@CompileStatic
class UnauthorizedException extends RuntimeException {

    UnauthorizedException(String message) {
        super(message)
    }
}

