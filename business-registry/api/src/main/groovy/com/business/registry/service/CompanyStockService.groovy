package com.business.registry.service

import com.business.registry.dto.companyStock.CompanyStockRequestDto
import com.business.registry.dto.companyStock.CompanyStockResponse
import com.business.registry.dto.util.ParametricDto
import com.business.registry.mapper.companyStock.CompanyStockMapper
import com.business.registry.model.CompanyStock
import com.business.registry.model.StockType
import com.business.registry.model.UserAccount
import com.business.registry.repository.CompanyStockRepository
import com.business.registry.repository.UserAccountRepository
import com.business.registry.validation.CompanyStockValidation
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@CompileStatic
class CompanyStockService {
    private final CompanyStockRepository companyStockRepository
    private final CompanyStockMapper companyStockMapper
    private final UserAccountRepository userAccountRepository
    private final CompanyStockValidation companyStockValidation

    @Autowired
    StockTypeService stockTypeService

    @Autowired
    MessageService messageService

    @Autowired
    AuthenticationService authenticationService

    CompanyStockService(
            CompanyStockRepository companyStockRepository,
            CompanyStockMapper companyStockMapper,
            UserAccountRepository userAccountRepository,
            CompanyStockValidation companyStockValidation
    ) {
        this.companyStockRepository = companyStockRepository
        this.companyStockMapper = companyStockMapper
        this.userAccountRepository = userAccountRepository
        this.companyStockValidation = companyStockValidation
    }

    @Transactional
    void updateCompanyStock(CompanyStockRequestDto companyStockDto, HttpSession session, String changeReason) {
        companyStockValidation.validateUpdate(companyStockDto)
        CompanyStock companyStock = companyStockRepository.findByIdAndCompanyId(companyStockDto.id, companyStockDto.companyId)
        if (companyStock == null) {
            createCompanyStock(companyStockDto, session)
        } else {
            if (companyStockDto.toBeDeleted) {
                deleteCompanyStock(companyStock.id, companyStock.companyId, changeReason, session)
                return
            }
            populateCompanyStockFromDto(companyStock, companyStockDto, session)
            companyStockRepository.save(companyStock)
        }
    }

    @Transactional
    void createCompanyStock(CompanyStockRequestDto companyStockDto, HttpSession session) {
        CompanyStock companyStock = new CompanyStock()
        populateCompanyStockFromDto(companyStock, companyStockDto, session)
        companyStockRepository.save(companyStock)
    }

    @Transactional
    void deleteCompanyStock(Long companyStockId, Long companyId, String changeReason, HttpSession session) {
        companyStockValidation.validateDeleteById(companyStockId)
        CompanyStock companyStock = companyStockRepository.findByIdAndCompanyId(companyStockId, companyId)
        if (companyStock == null) {
            throw new IllegalArgumentException(messageService.getMessage("Δεν.βρέθηκε.μετοχή.με.id.και.id.εταιρείας.", [companyStockId, companyId] as Object[]))
        }
        UserAccount user = userAccountRepository.findById(AuthenticationService.getCurrentUserId(session)).orElse(null)
        companyStock.lastUser = user
        companyStock.changeReason = changeReason
        companyStockRepository.saveAndFlush(companyStock)
        companyStockRepository.deleteById(companyStockId)
    }

    private void populateCompanyStockFromDto(CompanyStock companyStock, CompanyStockRequestDto companyStockDto, String changeReason = null, HttpSession session) {
        BigDecimal nominalPrice = companyStockDto.nominalPrice.toBigDecimal()
        StockType stockType = stockTypeService.findStockTypeById(companyStockDto.stockTypeId)
        if (stockType == null) {
            throw new IllegalArgumentException(messageService.getMessage("Δεν.βρέθηκε.τύπος.μετοχής.με.id.", [companyStockDto.stockTypeId] as Object[]))
        }
        UserAccount user = userAccountRepository.findById(AuthenticationService.getCurrentUserId(session)).orElse(null)
        companyStock.changeReason = changeReason
        companyStock.lastUser = user
        companyStock.companyId = companyStockDto.companyId
        companyStock.stockType = stockType
        companyStock.nominalPrice = nominalPrice
        companyStock.amount = companyStockDto.amount
    }

    private CompanyStockResponse mapToCompanyStockResponse(CompanyStock companyStock, Locale locale) {
        ParametricDto stockType = stockTypeService.findStockTypeTranslationByLocaleAndStockType(locale, companyStock.stockType)
        return companyStockMapper.toCompanyStockResponse(companyStock, stockType)
    }
}
