package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.CurrencyService
import groovy.transform.CompileStatic
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@CompileStatic
@RestController
@RequestMapping("/currency")
class CurrencyController {

    private final CurrencyService currencyService

    CurrencyController(CurrencyService currencyService) {
        this.currencyService = currencyService
    }

    @GetMapping("/translations")
    List<ParametricDto> getCurrencyTranslations(@RequestParam Locale locale) {
        return currencyService.findAllCurrencyTranslationsByLocale(locale)
    }
}

