package com.business.registry.service

import com.business.registry.dto.companyCapital.CompanyCapitalRequestDto
import com.business.registry.dto.companyCapital.CompanyCapitalResponse
import com.business.registry.dto.companyStock.CompanyStockResponse
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.companyCapital.CompanyCapitalMapper
import com.business.registry.mapper.companyStock.CompanyStockMapper
import com.business.registry.model.CompanyCapital
import com.business.registry.model.UserAccount
import com.business.registry.repository.CompanyCapitalRepository
import com.business.registry.repository.CompanyStockRepository
import com.business.registry.repository.UserAccountRepository
import com.business.registry.validation.CompanyCapitalValidation
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
class CompanyCapitalService {
    private final CompanyCapitalRepository companyCapitalRepository
    private final CompanyStockRepository companyStockRepository
    private final CompanyCapitalMapper companyCapitalMapper
    private final CompanyStockMapper companyStockMapper
    private final UserAccountRepository userAccountRepository
    private final CompanyCapitalValidation companyCapitalValidation

    @Autowired
    StockTypeService stockTypeService

    @Autowired
    CompanyStockService companyStockService

    @Autowired
    CurrencyService currencyService

    @Autowired
    MessageService messageService

    @Autowired
    AuthenticationService authenticationService

    @Autowired
    DeleteService deleteService

    CompanyCapitalService(
            CompanyCapitalRepository companyCapitalRepository,
            CompanyStockRepository companyStockRepository,
            CompanyCapitalMapper companyCapitalMapper,
            CompanyStockMapper companyStockMapper,
            UserAccountRepository userAccountRepository,
            CompanyCapitalValidation companyCapitalValidation
    ) {
        this.companyCapitalRepository = companyCapitalRepository
        this.companyStockRepository = companyStockRepository
        this.companyCapitalMapper = companyCapitalMapper
        this.companyStockMapper = companyStockMapper
        this.userAccountRepository = userAccountRepository
        this.companyCapitalValidation = companyCapitalValidation
    }

    @Transactional(readOnly = true)
    CompanyCapitalResponse getCompanyCapital(Long companyId, Locale locale) {
        companyCapitalValidation.validateFindById(companyId)
        CompanyCapital companyCapital = companyCapitalRepository.findTopByCompanyId(companyId)
        if (companyCapital == null) {
            return null
        }
        return mapToCompanyCapitalResponse(companyCapital, locale)
    }

    @Transactional
    void updateCompanyCapital(CompanyCapitalRequestDto companyCapitalDto, HttpSession session) {
        companyCapitalValidation.validateUpdate(companyCapitalDto)
        CompanyCapital companyCapital = companyCapitalRepository.findTopByCompanyId(companyCapitalDto.companyId)
        if (companyCapital == null) {
            createCompanyCapital(companyCapitalDto, session)
        } else {
            populateCompanyCapitalFromDto(companyCapital, companyCapitalDto, session)
            companyCapitalRepository.save(companyCapital)
        }
        companyCapitalDto.stocks.each { companyStockDto ->
            companyStockService.updateCompanyStock(companyStockDto, session, companyCapitalDto.changeReason)
        }
    }

    @Transactional
    void createCompanyCapital(CompanyCapitalRequestDto companyCapitalDto, HttpSession session) {
        companyCapitalValidation.validateCompanyCapitalRequestDto(companyCapitalDto)
        CompanyCapital companyCapital = new CompanyCapital()
        populateCompanyCapitalFromDto(companyCapital, companyCapitalDto, session)
        companyCapitalRepository.save(companyCapital)
        companyCapitalDto.stocks.each { companyStockDto ->
            companyStockService.updateCompanyStock(companyStockDto, session, companyCapitalDto.changeReason)
        }
    }

    private CompanyCapitalResponse mapToCompanyCapitalResponse(CompanyCapital companyCapital, Locale locale) {
        ParametricDto currency = currencyService.findCurrencyTranslationByLocaleAndCurrency(locale, companyCapital.currency)
        List<CompanyStockResponse> stocks = companyStockRepository.findAllByCompanyId(companyCapital.companyId).collect { companyStock ->
            ParametricDto stockType = stockTypeService.findStockTypeTranslationByLocaleAndStockType(locale, companyStock.stockType)
            companyStockMapper.toCompanyStockResponse(companyStock, stockType)
        }
        return companyCapitalMapper.toCompanyCapitalResponse(companyCapital, currency, stocks)
    }

    private void populateCompanyCapitalFromDto(CompanyCapital companyCapital, CompanyCapitalRequestDto companyCapitalDto, HttpSession session) {
        companyCapital.companyId = companyCapitalDto.companyId
        companyCapital.totalAmount = new BigDecimal(companyCapitalDto.totalAmount)
        companyCapital.currency = currencyService.findCurrencyById(companyCapitalDto.currencyId)
        companyCapital.changeReason = companyCapitalDto.changeReason
        UserAccount user = userAccountRepository.findById(AuthenticationService.getCurrentUserId(session)).orElse(null)
        companyCapital.lastUser = user
    }
}
