package com.business.registry.exception

import groovy.transform.CompileStatic

@CompileStatic
class NotFoundException extends RuntimeException {

    NotFoundException(String message) {
        super(message)
    }
}

