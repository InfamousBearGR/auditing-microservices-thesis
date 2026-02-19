package com.business.registry.exception

import groovy.transform.CompileStatic

@CompileStatic
class BadRequestException extends RuntimeException {

    BadRequestException(String message) {
        super(message)
    }
}
