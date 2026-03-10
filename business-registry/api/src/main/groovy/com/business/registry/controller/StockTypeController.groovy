package com.business.registry.controller

import com.business.registry.dto.util.ParametricDto
import com.business.registry.service.StockTypeService
import groovy.transform.CompileStatic
import org.springframework.context.i18n.LocaleContextHolder
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@CompileStatic
@RestController
@RequestMapping("/api/stockType")
class StockTypeController {

    private final StockTypeService stockTypeService

    StockTypeController(StockTypeService stockTypeService) {
        this.stockTypeService = stockTypeService
    }

    @GetMapping("/translations")
    List<ParametricDto> getStockTypeTranslations() {
        Locale locale = LocaleContextHolder.getLocale()
        return stockTypeService.findAllStockTypeTranslationsByLocale(locale)
    }
}

