package com.business.registry.service

import com.business.registry.dao.CompanyCapitalDao
import com.business.registry.dao.CompanyDao
import com.business.registry.dao.CompanyStockDao
import com.business.registry.dao.MemberDao
import com.business.registry.dao.UserAccountDao
import com.business.registry.dto.company.CompanyRequestDto
import com.business.registry.dto.company.CompanyResponseDto
import com.business.registry.dto.util.ParametricDto
import com.business.registry.exception.NotFoundException
import com.business.registry.mapper.company.CompanyMapper
import com.business.registry.model.*
import com.business.registry.validation.CompanyValidation
import groovy.transform.CompileStatic
import jakarta.servlet.http.HttpSession
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

import java.time.LocalDate

@Service
@CompileStatic
class CompanyService {
    private final CompanyDao companyDao
    private final CompanyMapper companyMapper
    private final CompanyValidation companyValidation
    private final UserAccountDao userAccountDao
    private final MemberDao memberDao
    private final CompanyStockDao companyStockDao
    private final CompanyCapitalDao companyCapitalDao
    private final DeleteService deleteService

    @Autowired
    CountryService countryService

    @Autowired
    PrefectureService prefectureService

    @Autowired
    MunicipalityService municipalityService

    @Autowired
    RegionService regionService

    @Autowired
    LegalTypeService legalTypeService

    @Autowired
    CompanyStatusService companyStatusService

    @Autowired
    MessageService messageService

    @Autowired
    AuthenticationService authenticationService

    CompanyService(
            CompanyDao companyDao,
            CompanyMapper companyMapper,
            CountryService countryService,
            PrefectureService prefectureService,
            MunicipalityService municipalityService,
            RegionService regionService,
            LegalTypeService legalTypeService,
            CompanyStatusService companyStatusService,
            MessageService messageService,
            CompanyValidation companyValidation,
            UserAccountDao userAccountDao,
            AuthenticationService authenticationService,
            MemberDao memberDao,
            CompanyStockDao companyStockDao,
            CompanyCapitalDao companyCapitalDao,
            DeleteService deleteService
    ) {
        this.companyDao = companyDao
        this.companyMapper = companyMapper
        this.countryService = countryService
        this.prefectureService = prefectureService
        this.municipalityService = municipalityService
        this.regionService = regionService
        this.legalTypeService = legalTypeService
        this.companyStatusService = companyStatusService
        this.messageService = messageService
        this.companyValidation = companyValidation
        this.userAccountDao = userAccountDao
        this.authenticationService = authenticationService
        this.memberDao = memberDao
        this.companyStockDao = companyStockDao
        this.companyCapitalDao = companyCapitalDao
        this.deleteService = deleteService
    }

    @Transactional(readOnly = true)
    List<CompanyResponseDto> getAllCompanies(Locale locale) {
        return companyDao.findAllCompanies().collect { company ->
            mapToCompanyResponseDto(company, locale)
        }
    }

    @Transactional(readOnly = true)
    CompanyResponseDto getCompanyById(Long id, Locale locale) {
        companyValidation.validateFindById(id)
        Company company = companyDao.findCompanyById(id)
        if (company == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Επιχείρηση.με.id.", [id] as Object[]))
        }
        return mapToCompanyResponseDto(company, locale)
    }

    @Transactional(readOnly = true)
    Company findCompanyById(Long id) {
        return companyDao.findCompanyById(id)
    }

    @Transactional
    void updateCompany(CompanyRequestDto companyDto, Long id, HttpSession session) {
        companyValidation.validateUpdate(companyDto, id)
        Company company = companyDao.findCompanyById(id)
        if (company == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Επιχείρηση.με.id.", [id] as Object[]))
        }
        populateCompanyFromDto(company, companyDto, session)
        companyDao.save(company)
    }

    @Transactional
    void createCompany(CompanyRequestDto companyDto, HttpSession session) {
        companyValidation.validateCompanyRequestDto(companyDto)
        Company company = new Company()
        populateCompanyFromDto(company, companyDto, session)
        companyDao.save(company)
    }

    @Transactional
    void deleteCompanyById(Long id, String changeReason, HttpSession session) {
        companyValidation.validateDeleteById(id)
        Company company = companyDao.findCompanyById(id)
        if (company == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.Επιχείρηση.με.id.", [id] as Object[]))
        }
        UserAccount user = userAccountDao.findById(AuthenticationService.getCurrentUserId(session)).orElse(null)
        company.lastUser = user
        company.changeReason = changeReason
        companyDao.saveAndFlush(company)

        deleteService.cascadeDelete(
                company,
                user,
                changeReason,
                [
                        new DeleteService.ChildGroup<Member>(
                                { memberDao.findAllMembersByCompany(company) },
                                memberDao
                        ),
                        new DeleteService.ChildGroup<CompanyStock>(
                                { companyStockDao.findAllByCompanyId(company.id) },
                                companyStockDao
                        ),
                        new DeleteService.ChildGroup<CompanyCapital>(
                                { companyCapitalDao.findAllByCompanyId(company.id) },
                                companyCapitalDao
                        )
                ] as List<DeleteService.ChildGroup>,
                { companyDao.deleteCompanyById(id) }
        )
    }

    private CompanyResponseDto mapToCompanyResponseDto(Company company, Locale locale) {
        ParametricDto country = countryService.findCountryTranslationByLocaleAndCountry(locale, company.country)
        ParametricDto prefecture = prefectureService.findPrefectureTranslationByLocaleAndPrefecture(locale, company.prefecture)
        ParametricDto municipality = municipalityService.findMunicipalityTranslationByLocaleAndMunicipality(locale, company.municipality)
        ParametricDto region = regionService.findRegionTranslationByLocaleAndRegion(locale, company.region)
        ParametricDto legalType = legalTypeService.findLegalTypeTranslationByLocaleAndLegalType(locale, company.legalType)
        ParametricDto companyStatus = companyStatusService.findCompanyStatusTranslationByLocaleAndCompanyStatus(locale, company.companyStatus)
        return companyMapper.toCompanyDto(company, country, prefecture, municipality, region, legalType, companyStatus)
    }

    private void populateCompanyFromDto(Company company, CompanyRequestDto companyDto, HttpSession session) {
        Country country = countryService.findCountryById(companyDto.countryId)
        if (country == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.χώρα.με.id.", [companyDto.countryId] as Object[]))
        }
        Prefecture prefecture = prefectureService.findPrefectureById(companyDto.prefectureId)
        if (prefecture == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.νομός.με.id.", [companyDto.prefectureId] as Object[]))
        }
        Municipality municipality = municipalityService.findMunicipalityById(companyDto.municipalityId)
        if (municipality == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.δήμος.με.id.", [companyDto.municipalityId] as Object[]))
        }
        Region region = regionService.findRegionById(companyDto.regionId)
        if (region == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.περιφέρεια.με.id.", [companyDto.regionId] as Object[]))
        }
        LegalType legalType = legalTypeService.findLegalTypeById(companyDto.legalTypeId)
        if (legalType == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.νομική.μορφή.με.id.", [companyDto.legalTypeId] as Object[]))
        }
        CompanyStatus companyStatus = companyStatusService.findCompanyStatusById(companyDto.companyStatusId)
        if (companyStatus == null) {
            throw new NotFoundException(messageService.getMessage("Δεν.βρέθηκε.κατάσταση.επιχείρησης.με.id.", [companyDto.companyStatusId] as Object[]))
        }
        UserAccount user = userAccountDao.findById(AuthenticationService.getCurrentUserId(session)).orElse(null)
        company.name = companyDto.name
        company.city = companyDto.city
        company.street = companyDto.street
        company.streetNumber = companyDto.streetNumber
        company.postalCode = companyDto.postalCode
        company.afm = companyDto.afm
        company.dateIncorporated = companyDto.dateIncorporated ? LocalDate.parse(companyDto.dateIncorporated) : null
        company.registryNumber = companyDto.registryNumber
        company.country = country
        company.prefecture = prefecture
        company.municipality = municipality
        company.region = region
        company.legalType = legalType
        company.companyStatus = companyStatus
        company.lastUser = user
        company.changeReason = companyDto.changeReason
    }
}
