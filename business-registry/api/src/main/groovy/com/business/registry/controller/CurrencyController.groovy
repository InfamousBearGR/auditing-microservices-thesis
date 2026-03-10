package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.CurrencyService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@CompileStatic
@RestController
@RequestMapping("/api/currency")
class CurrencyController {

    private final CurrencyService currencyService

    CurrencyController(CurrencyService currencyService) {
        this.currencyService = currencyService
    }

    @GetMapping("/translations")
    List<ParametricDto> getCurrencyTranslations() {
        Locale locale = LocaleContextHolder.getLocale()
        return currencyService.findAllCurrencyTranslationsByLocale(locale)
    }
}

