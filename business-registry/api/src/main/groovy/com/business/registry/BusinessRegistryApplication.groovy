package com.business.registry

import groovy.transform.CompileStatic
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
@CompileStatic
class BusinessRegistryApplication {

    static void main(String[] args) {
        SpringApplication.run(BusinessRegistryApplication, args)
    }
}

