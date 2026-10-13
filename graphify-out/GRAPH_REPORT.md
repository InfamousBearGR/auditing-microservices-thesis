# Graph Report - auditing-microservices-thesis  (2026-10-13)

## Corpus Check
- 342 files · ~94,667 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 41 file(s) not represented in the graph (top: .properties 15, (none) 9, .csv 6)

## Summary
- 1935 nodes · 4166 edges · 143 communities (120 shown, 23 thin omitted)
- Extraction: 94% EXTRACTED · 6% INFERRED · 0% AMBIGUOUS · INFERRED: 259 edges (avg confidence: 0.85)
- Token cost: 88,084 input · 0 output

## Community Hubs (Navigation)
- Client Capital & Autocompletes
- Legal Type Reference API
- Member Relation Reference API
- Language Entity
- Country Controller
- Prefecture Controller
- Country Reference Data
- Region i18n Mapper
- Member Validation
- Person Validation
- Currency Reference Data
- Municipality i18n
- Stock Type i18n Mapper
- Prefecture i18n
- Company Status Service
- Region Reference Data
- Client Legal Entity CRUD
- SSE Auth Filter
- API Exceptions & Cascade Delete
- Stock Type Reference API
- Client Company Gateway
- Client Legal Entity Create
- Generic i18n Mapper
- Capital Form & Stock Modal
- Client Member Create & Search
- Client Company Forms
- SSE R2DBC & API Account
- Company Stock Service
- Client App Shell
- Global Exception Handling
- Auditable Entity Contract
- Password Hashing & Deserialization
- Envers Audit Context
- Authentication Flow
- Client Auth Context
- Client Details Table
- Member DTOs & Mapping
- Spring i18n Config
- Municipality Controller
- SSE Event Model
- Mutation Controllers & Delete DTO
- Audit Consumer DB Service
- Audit Consumer Message Processing
- Company Status i18n
- Capital Response DTOs
- Client Logout & Layout
- Client Stress Test
- SSE Stream Controller
- Legal Entity Controller
- Person Controller
- Capital Request DTOs
- Password Service & Kafka Flux
- Spring Boot Entrypoints
- Company Service
- Legal Entity Service
- Person Service
- JPA Entities & DTOs
- Company Controller
- Member Controller
- Roles
- Company Capital Service
- Legal Entity & Person Entities
- SSE Kafka Config
- Client i18n Setup
- Legal Entity Response Mapping
- Person Response Mapping
- Envers Revision Entity
- Company Capital Controller
- Company Response Mapping
- Company Validation & Messages
- Region Controller
- Audit Consumer Entrypoint
- Entity Validators
- Client Breadcrumbs
- SSE API-Key Auth Service
- Company Status Entity
- k6 Load Workload
- Client Member View
- Request Validators
- Benchmark Summarizer
- Company Tabs & View
- MainDb Schema & Triggers
- Countries I18N Audit Table
- Languages Audit Table
- Legal Types Audit Table
- Legal Types I18N Audit Table
- Member Audit Table
- Member Relations Audit Table
- Member Relations I18N Audit Table
- Municipalities I18N Audit Table
- Person Audit Table
- Prefectures Audit Table
- Prefectures I18N Audit Table
- Regions Audit Table
- Regions I18N Audit Table
- Roles Audit Table
- Stock Types Audit Table
- Stock Types I18N Audit Table
- User Account Audit Table
- Swagger Docs Init
- Audit Consumer Rebuild Script
- AuditDb Timestamp Triggers
- API Rebuild Script
- Debezium Connector Registration
- History API Rebuild Script
- History API Run Script
- Full Stack Rebuild
- SSE Bridge Rebuild Script
- Dev Watch Script
- History API Go Module
- Client Runtime Dependencies
- Client TS Config
- Client Package Manifest
- Audit Consumer Kafka/DB
- History API Parquet Export
- Company Audit Hypertable
- Client Dev Dependencies
- History API Database Queries
- Benchmark Orchestrator
- History API Config & DB
- History API Topics & Users
- History API Handlers
- Client TS Node Config
- History API Auth Middleware
- Client ESLint Config
- Vite Config
- Benchmark Metric Collector
- Client npm Scripts
- API Gradle Wrapper
- Company Capital Audit Table
- Company Statuses Audit Table
- Company Statuses I18N Audit Table
- Company Stocks Audit Table
- Countries Audit Table
- Client Branding Icon
- Audit Methods & Architecture Docs
- UserAccount Type Ref

## God Nodes (most connected - your core abstractions)
1. `react-i18next` - 59 edges
2. `@tanstack/react-query` - 45 edges
3. `@mui/material` - 42 edges
4. `@tanstack/react-router` - 42 edges
5. `react` - 36 edges
6. `user_account` - 33 edges
7. `notistack` - 32 edges
8. `react-hook-form-mui` - 29 edges
9. `set_creation_timestamps()` - 26 edges
10. `Language` - 24 edges

## Surprising Connections (you probably didn't know these)
- `CDC Audit Pipeline` --semantically_similar_to--> `Real-Time Database CDC System`  [INFERRED] [semantically similar]
  CLAUDE.md → README.md
- `models.AuditEntry` --shares_data_with--> `TimescaleDB Audit Hypertables`  [INFERRED]
  history-api/docs/swagger.yaml → README.md
- `Business Registry Application` --references--> `Real-Time Database CDC System`  [INFERRED]
  CLAUDE.md → README.md
- `History API Dual Output (JSON stream + Parquet)` --implements--> `Company History API (Swagger)`  [INFERRED]
  CLAUDE.md → history-api/docs/swagger.yaml
- `UserAccountRepository` --references--> `user_account`  [EXTRACTED]
  business-registry/api/src/main/groovy/com/business/registry/repository/UserAccountRepository.groovy → mainDb/init.sql

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Benchmarked audit methods and scenarios** — benchmark_readme_baseline_scenario, benchmark_readme_cdc_scenario, benchmark_readme_triggers_scenario, benchmark_readme_envers_scenario, claude_audit_method_comparison [EXTRACTED 1.00]
- **CDC data flow: Debezium -> Kafka -> TimescaleDB/SSE** — readme_debezium_cdc, readme_kafka_kraft_cluster, readme_timescaledb_archive, readme_server_sent_events, claude_cdc_audit_pipeline [EXTRACTED 1.00]
- **History API query/export endpoints** — history_api_docs_swagger_gethistorybydaterange, history_api_docs_swagger_gethistorybychangeidrange, history_api_docs_swagger_exporthistorybydaterange, history_api_docs_swagger_exporthistorybychangeidrange [EXTRACTED 1.00]

## Communities (143 total, 23 thin omitted)

### Community 1 - "Client Capital & Autocompletes"
Cohesion: 0.08
Nodes (31): CompanyCapitalRequestDto, CompanyCapitalResponseDto, CompanyStockRequestDto, CompanyStockResponseDto, LegalEntityDto, MemberRequestDto, MemberResponseDto, PersonDto (+23 more)

### Community 10 - "Legal Type Reference API"
Cohesion: 0.09
Nodes (22): LegalTypeController, LegalTypeI18nMapper, LegalType, LegalTypeI18n, LegalTypeI18nRepository, LegalTypeRepository, LegalTypeService, CompileStatic (+14 more)

### Community 11 - "Member Relation Reference API"
Cohesion: 0.09
Nodes (22): MemberRelationController, MemberRelationI18nMapper, MemberRelation, MemberRelationI18n, MemberRelationI18nRepository, MemberRelationRepository, MemberRelationService, CompileStatic (+14 more)

### Community 117 - "Language Entity"
Cohesion: 0.36
Nodes (6): Language, LanguageRepository, CompileStatic, Entity, Table, Repository

### Community 118 - "Country Controller"
Cohesion: 0.53
Nodes (4): CountryController, CompileStatic, RequestMapping, RestController

### Community 119 - "Prefecture Controller"
Cohesion: 0.53
Nodes (4): PrefectureController, CompileStatic, RequestMapping, RestController

### Community 12 - "Country Reference Data"
Cohesion: 0.10
Nodes (18): CountryI18nMapper, Country, CountryI18n, CountryI18nRepository, CountryRepository, CountryService, CompileStatic, Component (+10 more)

### Community 120 - "Region i18n Mapper"
Cohesion: 0.53
Nodes (3): RegionI18nMapper, CompileStatic, Component

### Community 121 - "Member Validation"
Cohesion: 0.31
Nodes (5): MemberRequestDto, MemberValidation, CompileStatic, CompileStatic, Component

### Community 122 - "Person Validation"
Cohesion: 0.31
Nodes (5): PersonRequestDto, PersonValidation, CompileStatic, CompileStatic, Component

### Community 13 - "Currency Reference Data"
Cohesion: 0.10
Nodes (17): CurrencyController, Currency, CurrencyI18nRepository, CurrencyRepository, UserAccountRepository, CurrencyService, CompileStatic, RequestMapping (+9 more)

### Community 14 - "Municipality i18n"
Cohesion: 0.10
Nodes (18): MunicipalityI18nMapper, Municipality, MunicipalityI18n, MunicipalityI18nRepository, MunicipalityRepository, MunicipalityService, CompileStatic, Component (+10 more)

### Community 141 - "Stock Type i18n Mapper"
Cohesion: 0.53
Nodes (3): StockTypeI18nMapper, CompileStatic, Component

### Community 15 - "Prefecture i18n"
Cohesion: 0.10
Nodes (18): PrefectureI18nMapper, Prefecture, PrefectureI18n, PrefectureI18nRepository, PrefectureRepository, PrefectureService, CompileStatic, Component (+10 more)

### Community 16 - "Company Status Service"
Cohesion: 0.21
Nodes (7): CompanyStatusController, CompanyStatusService, CompileStatic, RequestMapping, RestController, CompileStatic, Transactional

### Community 18 - "Region Reference Data"
Cohesion: 0.12
Nodes (15): Region, RegionI18n, RegionI18nRepository, RegionRepository, RegionService, CompileStatic, Entity, Table (+7 more)

### Community 2 - "Client Legal Entity CRUD"
Cohesion: 0.09
Nodes (34): LegalEntityRequestDto, LegalEntityResponseDto, DeleteModalProps, TableActionsProps, CompanyCapitalForm(), deleteLegalEntity(), indexLegalEntity(), useDeleteLegalEntity() (+26 more)

### Community 20 - "SSE Auth Filter"
Cohesion: 0.20
Nodes (9): AuthenticationFilter, gradlew script, die(), warn(), Component, WebFilter, httpstatus, serverwebexchange (+1 more)

### Community 21 - "API Exceptions & Cascade Delete"
Cohesion: 0.12
Nodes (15): BadRequestException, NotFoundException, ChildGroup, DeleteService, CompileStatic, CompileStatic, CompileStatic, CompileStatic (+7 more)

### Community 22 - "Stock Type Reference API"
Cohesion: 0.12
Nodes (13): StockTypeController, StockType, StockTypeI18nRepository, StockTypeRepository, StockTypeService, CompileStatic, RequestMapping, RestController (+5 more)

### Community 24 - "Client Company Gateway"
Cohesion: 0.16
Nodes (15): CompanyRequestDto, CompanyResponseDto, createCompany(), deleteCompany(), indexCompany(), updateCompany(), viewCompany(), useCreateCompany() (+7 more)

### Community 25 - "Client Legal Entity Create"
Cohesion: 0.17
Nodes (14): LegalEntityValidationSchema, createLegalEntity(), useCreateLegalEntity(), Add(), Edit(), LegalEntityForm(), getLegalEntityValidationSchema(), createLegalEntityRoutes() (+6 more)

### Community 27 - "Generic i18n Mapper"
Cohesion: 0.27
Nodes (4): CurrencyI18nMapper, I18nMapper, CompileStatic, Component

### Community 28 - "Capital Form & Stock Modal"
Cohesion: 0.19
Nodes (17): CompanyCapitalFormProps, DeleteStockModalProps, EditAndAddStockModalProps, TableActionsForStocksProps, CompanyCapitalValidationSchema, CompanyStockValidationSchema, DeleteStockModal(), EditAndAddStockModal() (+9 more)

### Community 29 - "Client Member Create & Search"
Cohesion: 0.17
Nodes (14): MemberValidationSchema, createMember(), searchLegalEntities(), searchPersons(), useCreateMember(), useSearchLegalEntities(), useSearchPersons(), Add() (+6 more)

### Community 3 - "Client Company Forms"
Cohesion: 0.11
Nodes (33): CompanyValidationSchema, PersonValidationSchema, CustomDatePickerProps, Add(), Edit(), CompanyForm(), getCompanyValidationSchema(), createPerson() (+25 more)

### Community 30 - "SSE R2DBC & API Account"
Cohesion: 0.14
Nodes (14): ApiUserAccount, JsonNodeToJsonConverter, JsonToJsonNodeConverter, R2dbcConfiguration, Converter, Json, JsonNode, ReadingConverter (+6 more)

### Community 31 - "Company Stock Service"
Cohesion: 0.17
Nodes (8): CompanyStockMapper, CompanyStockRepository, CompanyStockService, CompileStatic, Component, Repository, CompileStatic, CompanyStock

### Community 33 - "Client App Shell"
Cohesion: 0.10
Nodes (19): SupportedLanguage, App(), ConfigurationContextComponent(), configureHttpClient(), MySnackbarProvider(), muiDatePickersLangs, muiLanguagePacks, muiLocaleTextLanguages (+11 more)

### Community 36 - "Global Exception Handling"
Cohesion: 0.13
Nodes (9): ErrorResponseDto, GlobalExceptionHandler, CompileStatic, CompileStatic, ControllerAdvice, exceptionhandler, fielderror, httpmessagenotreadableexception (+1 more)

### Community 38 - "Auditable Entity Contract"
Cohesion: 0.11
Nodes (16): Auditable, Company, Member, CompanyRepository, MemberRepository, Audited, CompileStatic, Entity (+8 more)

### Community 39 - "Password Hashing & Deserialization"
Cohesion: 0.15
Nodes (10): EventDeserializer, EventFactory, CompileStatic, Deserializer, argon2bytesgenerator, argon2parameters, deserializationfeature, logger (+2 more)

### Community 4 - "Envers Audit Context"
Cohesion: 0.06
Nodes (30): AuditContext, AuditContextFilter, AuditRevisionListener, SecurityConfig, SessionAuthenticationFilter, CompileStatic, CompileStatic, Component (+22 more)

### Community 40 - "Authentication Flow"
Cohesion: 0.11
Nodes (14): AuthenticationController, LoginResponseDto, LogoutResponseDto, UnauthorizedException, AuthenticationService, CompileStatic, RequestMapping, RestController (+6 more)

### Community 43 - "Client Auth Context"
Cohesion: 0.19
Nodes (12): AuthProviderProps, IUseAuth, RoleEnum, Error502(), AuthProvider(), checkUserSession(), useCheckUserSession(), AuthContext (+4 more)

### Community 44 - "Client Details Table"
Cohesion: 0.17
Nodes (13): DetailsProps, DetailsRow, PrimitiveCellValues, RenderFunctions, UrlObject, defaultRenderArray(), defaultRenderDates(), defaultRenderObject() (+5 more)

### Community 46 - "Member DTOs & Mapping"
Cohesion: 0.10
Nodes (11): LegalEntityDto, MemberResponseDto, PersonDto, MemberMapper, MemberService, CompileStatic, CompileStatic, CompileStatic (+3 more)

### Community 47 - "Spring i18n Config"
Cohesion: 0.17
Nodes (10): I18nConfig, CompileStatic, Configuration, WebMvcConfigurer, acceptheaderlocaleresolver, interceptorregistry, localechangeinterceptor, localeresolver (+2 more)

### Community 49 - "Municipality Controller"
Cohesion: 0.53
Nodes (4): MunicipalityController, CompileStatic, RequestMapping, RestController

### Community 50 - "SSE Event Model"
Cohesion: 0.16
Nodes (6): EventBaseModel, JsonIgnoreProperties, ToString, instant, jsongetter, jsonsetter

### Community 51 - "Mutation Controllers & Delete DTO"
Cohesion: 0.26
Nodes (9): DeleteRequestDto, CompileStatic, CompileStatic, CompileStatic, CompileStatic, annotation, httpsession, localecontextholder (+1 more)

### Community 52 - "Audit Consumer DB Service"
Cohesion: 0.22
Nodes (7): DatabaseService, KafkaService, gradlew script, die(), warn(), Slf4j, Slf4j

### Community 53 - "Audit Consumer Message Processing"
Cohesion: 0.23
Nodes (4): Utils, Slf4j, objectmapper, objectnode

### Community 54 - "Company Status i18n"
Cohesion: 0.20
Nodes (9): CompanyStatusI18nMapper, CompanyStatusI18n, CompanyStatusI18nRepository, CompileStatic, Component, CompileStatic, Entity, Table (+1 more)

### Community 55 - "Capital Response DTOs"
Cohesion: 0.24
Nodes (10): CompanyCapitalResponseDto, CompanyStockResponseDto, ParametricDto, CompanyCapitalMapper, CompileStatic, CompileStatic, CompileStatic, CompileStatic (+2 more)

### Community 56 - "Client Logout & Layout"
Cohesion: 0.23
Nodes (10): ProfileMenuProps, useAuth(), logout(), useLogout(), Main(), LANG_OPTIONS, ref_mui_icons_material_accountcircle, ref_mui_icons_material_bolt (+2 more)

### Community 57 - "Client Stress Test"
Cohesion: 0.32
Nodes (12): GeoOption, ParametricCache, pick(), rAfm(), rDate(), rFutureDate(), ri(), rPhone() (+4 more)

### Community 58 - "SSE Stream Controller"
Cohesion: 0.19
Nodes (7): StreamController, RestController, flux, getmapping, mediatype, pathvariable, serversentevent

### Community 59 - "Legal Entity Controller"
Cohesion: 0.20
Nodes (4): LegalEntityController, CompileStatic, RequestMapping, RestController

### Community 60 - "Person Controller"
Cohesion: 0.22
Nodes (3): PersonController, RequestMapping, RestController

### Community 61 - "Capital Request DTOs"
Cohesion: 0.22
Nodes (7): CompanyCapitalRequestDto, CompanyStockRequestDto, CompanyCapitalValidation, CompileStatic, CompileStatic, CompileStatic, Component

### Community 66 - "Spring Boot Entrypoints"
Cohesion: 0.25
Nodes (7): BusinessRegistryApplication, SseApplication, CompileStatic, SpringBootApplication, EnableR2dbcRepositories, SpringBootApplication, springapplication

### Community 7 - "JPA Entities & DTOs"
Cohesion: 0.09
Nodes (27): LoginRequestDto, CompanyCapital, CurrencyI18n, StockTypeI18n, UserAccount, CompileStatic, Audited, CompileStatic (+19 more)

### Community 70 - "Company Controller"
Cohesion: 0.22
Nodes (3): CompanyController, RequestMapping, RestController

### Community 71 - "Member Controller"
Cohesion: 0.22
Nodes (3): MemberController, RequestMapping, RestController

### Community 72 - "Roles"
Cohesion: 0.29
Nodes (7): Role, RoleRepository, CompileStatic, Entity, Table, CompileStatic, Repository

### Community 73 - "Company Capital Service"
Cohesion: 0.23
Nodes (3): CompanyCapitalRepository, CompanyCapitalService, Repository

### Community 74 - "Legal Entity & Person Entities"
Cohesion: 0.15
Nodes (15): LegalEntity, Person, LegalEntityRepository, PersonRepository, Audited, CompileStatic, Entity, Table (+7 more)

### Community 75 - "SSE Kafka Config"
Cohesion: 0.17
Nodes (10): KafkaConfig, Configuration, connectableflux, consumerconfig, kafkareceiver, pattern, postconstruct, receiveroptions (+2 more)

### Community 76 - "Client i18n Setup"
Cohesion: 0.28
Nodes (6): ErrorResponse, onErrorFunction(), resources, queryClient, business_registry_client_src_shared_services_languages_el_greek, business_registry_client_src_shared_services_languages_en_english

### Community 79 - "Legal Entity Response Mapping"
Cohesion: 0.36
Nodes (5): LegalEntityResponseDto, LegalEntityMapper, CompileStatic, CompileStatic, Component

### Community 80 - "Person Response Mapping"
Cohesion: 0.36
Nodes (5): PersonResponseDto, PersonMapper, CompileStatic, CompileStatic, Component

### Community 81 - "Envers Revision Entity"
Cohesion: 0.23
Nodes (11): AuditRevisionEntity, CompileStatic, Entity, Table, RevisionEntity, column, generatedvalue, generationtype (+3 more)

### Community 82 - "Company Capital Controller"
Cohesion: 0.33
Nodes (3): CompanyCapitalController, RequestMapping, RestController

### Community 83 - "Company Response Mapping"
Cohesion: 0.43
Nodes (5): CompanyResponseDto, CompanyMapper, CompileStatic, CompileStatic, Component

### Community 84 - "Company Validation & Messages"
Cohesion: 0.19
Nodes (8): CompanyRequestDto, MessageService, CompanyValidation, CompileStatic, CompileStatic, CompileStatic, Component, messagesource

### Community 86 - "Region Controller"
Cohesion: 0.53
Nodes (4): RegionController, CompileStatic, RequestMapping, RestController

### Community 88 - "Audit Consumer Entrypoint"
Cohesion: 0.50
Nodes (3): AuditConsumer, Slf4j, kafkaservice

### Community 9 - "Entity Validators"
Cohesion: 0.11
Nodes (10): LegalEntityRequestDto, CompanyStockValidation, LegalEntityValidation, Validatable, validateId(), CompileStatic, CompileStatic, Component (+2 more)

### Community 91 - "Client Breadcrumbs"
Cohesion: 0.50
Nodes (4): BreadcrumbItem, AppBreadcrumb(), resolveBreadcrumbs(), ref_mui_icons_material_navigatenext

### Community 93 - "SSE API-Key Auth Service"
Cohesion: 0.20
Nodes (5): ApiUserAccountRepository, AuthService, R2dbcRepository, mono, query

### Community 94 - "Company Status Entity"
Cohesion: 0.31
Nodes (7): CompanyStatus, CompanyStatusRepository, CompileStatic, Entity, Table, Repository, persistence

### Community 17 - "k6 Load Workload"
Cohesion: 0.09
Nodes (22): jsonPost(), pad(), pick(), rAfm(), rDate(), rFutureDate(), ri(), rPhone() (+14 more)

### Community 26 - "Client Member View"
Cohesion: 0.15
Nodes (16): viewMember(), useViewMember(), Edit(), View(), NotFound(), login(), useLogin(), Dashboard() (+8 more)

### Community 41 - "Request Validators"
Cohesion: 0.33
Nodes (10): validateAddressFields(), validateAfm(), validateAfmField(), validateChangeReason(), validateDate(), validateLocationIds(), validateRequestNotNull(), validateRequiredId() (+2 more)

### Community 5 - "Benchmark Summarizer"
Cohesion: 0.19
Nodes (15): fmt(), fnum(), load_scenario(), main(), mb(), METRICS(), overhead_pct(), trend() (+7 more)

### Community 6 - "Company Tabs & View"
Cohesion: 0.14
Nodes (25): CompanyTabsLayout(), updateCompanyCapital(), viewCompanyCapital(), useUpdateCompanyCapital(), useViewCompanyCapital(), Edit(), View(), updateLegalEntity() (+17 more)

### Community 0 - "MainDb Schema & Triggers"
Cohesion: 0.06
Nodes (80): company, company_capital, company_statuses, company_statusesI18n, company_stocks, countries, countriesI18n, currency (+72 more)

### Community 100 - "Countries I18N Audit Table"
Cohesion: 0.67
Nodes (3): countriesi18n_audit, idx_countriesi18n_audit_change_id, idx_countriesi18n_audit_changed_at

### Community 101 - "Languages Audit Table"
Cohesion: 0.67
Nodes (3): idx_languages_audit_change_id, idx_languages_audit_changed_at, languages_audit

### Community 102 - "Legal Types Audit Table"
Cohesion: 0.67
Nodes (3): idx_legal_types_audit_change_id, idx_legal_types_audit_changed_at, legal_types_audit

### Community 103 - "Legal Types I18N Audit Table"
Cohesion: 0.67
Nodes (3): idx_legal_typesi18n_audit_change_id, idx_legal_typesi18n_audit_changed_at, legal_typesi18n_audit

### Community 104 - "Member Audit Table"
Cohesion: 0.67
Nodes (3): idx_member_audit_change_id, idx_member_audit_changed_at, member_audit

### Community 105 - "Member Relations Audit Table"
Cohesion: 0.67
Nodes (3): idx_member_relations_audit_change_id, idx_member_relations_audit_changed_at, member_relations_audit

### Community 106 - "Member Relations I18N Audit Table"
Cohesion: 0.67
Nodes (3): idx_member_relationsi18n_audit_change_id, idx_member_relationsi18n_audit_changed_at, member_relationsi18n_audit

### Community 107 - "Municipalities I18N Audit Table"
Cohesion: 0.67
Nodes (3): idx_municipalitiesi18n_audit_change_id, idx_municipalitiesi18n_audit_changed_at, municipalitiesi18n_audit

### Community 108 - "Person Audit Table"
Cohesion: 0.67
Nodes (3): idx_person_audit_change_id, idx_person_audit_changed_at, person_audit

### Community 109 - "Prefectures Audit Table"
Cohesion: 0.67
Nodes (3): idx_prefectures_audit_change_id, idx_prefectures_audit_changed_at, prefectures_audit

### Community 110 - "Prefectures I18N Audit Table"
Cohesion: 0.67
Nodes (3): idx_prefecturesi18n_audit_change_id, idx_prefecturesi18n_audit_changed_at, prefecturesi18n_audit

### Community 111 - "Regions Audit Table"
Cohesion: 0.67
Nodes (3): idx_regions_audit_change_id, idx_regions_audit_changed_at, regions_audit

### Community 112 - "Regions I18N Audit Table"
Cohesion: 0.67
Nodes (3): idx_regionsi18n_audit_change_id, idx_regionsi18n_audit_changed_at, regionsi18n_audit

### Community 113 - "Roles Audit Table"
Cohesion: 0.67
Nodes (3): idx_roles_audit_change_id, idx_roles_audit_changed_at, roles_audit

### Community 114 - "Stock Types Audit Table"
Cohesion: 0.67
Nodes (3): idx_stock_types_audit_change_id, idx_stock_types_audit_changed_at, stock_types_audit

### Community 115 - "Stock Types I18N Audit Table"
Cohesion: 0.67
Nodes (3): idx_stock_typesi18n_audit_change_id, idx_stock_typesi18n_audit_changed_at, stock_typesi18n_audit

### Community 116 - "User Account Audit Table"
Cohesion: 0.67
Nodes (3): idx_user_account_audit_change_id, idx_user_account_audit_changed_at, user_account_audit

### Community 19 - "Client Runtime Dependencies"
Cohesion: 0.08
Nodes (25): dependencies, axios, date-fns, decimal.js, dotenv, @emotion/babel-plugin, @emotion/react, @emotion/styled (+17 more)

### Community 23 - "Client TS Config"
Cohesion: 0.08
Nodes (23): compilerOptions, allowJs, allowSyntheticDefaultImports, baseUrl, esModuleInterop, forceConsistentCasingInFileNames, isolatedModules, jsx (+15 more)

### Community 32 - "Client Package Manifest"
Cohesion: 0.10
Nodes (20): name, private, type, version, decimal.js, dotenv, @emotion/babel-plugin, @emotion/react (+12 more)

### Community 34 - "Audit Consumer Kafka/DB"
Cohesion: 0.19
Nodes (11): atomicboolean, connection, consumerrecord, drivermanager, duration, kafkaconsumer, preparedstatement, sqlexception (+3 more)

### Community 35 - "History API Parquet Export"
Cohesion: 0.13
Nodes (17): github.com/apache/arrow/go/v18/arrow.Schema, buildArrowSchema(), go_pkg_github_com_apache_arrow_go_v18_arrow, go_pkg_github_com_apache_arrow_go_v18_arrow_array, go_pkg_github_com_apache_arrow_go_v18_arrow_memory, go_pkg_github_com_apache_arrow_go_v18_parquet, go_pkg_github_com_apache_arrow_go_v18_parquet_compress, go_pkg_github_com_apache_arrow_go_v18_parquet_pqarrow (+9 more)

### Community 37 - "Company Audit Hypertable"
Cohesion: 0.18
Nodes (16): company_audit, currency_audit, currencyi18n_audit, idx_company_audit_change_id, idx_company_audit_changed_at, idx_currency_audit_change_id, idx_currency_audit_changed_at, idx_currencyi18n_audit_change_id (+8 more)

### Community 42 - "Client Dev Dependencies"
Cohesion: 0.12
Nodes (16): devDependencies, eslint, @eslint/js, eslint-plugin-react-hooks, eslint-plugin-react-refresh, globals, prettier, @types/jquery (+8 more)

### Community 45 - "History API Database Queries"
Cohesion: 0.23
Nodes (9): database/sql.DB, database/sql.Rows, Service, NewService(), scanAuditEntry(), NewHistoryHandler(), NewParquetHandler(), main() (+1 more)

### Community 48 - "Benchmark Orchestrator"
Cohesion: 0.34
Nodes (13): audit_psql(), consumer_total_lag(), log(), main_psql(), run_k6(), run_scenario(), set_triggers(), run-all.sh script (+5 more)

### Community 63 - "History API Config & DB"
Cohesion: 0.18
Nodes (10): database/sql.NullString, Load(), parseJSONField(), go_pkg_database_sql, go_pkg_fmt, go_pkg_github_com_joho_godotenv, go_pkg_github_com_lib_pq, go_pkg_history_api_models (+2 more)

### Community 64 - "History API Topics & Users"
Cohesion: 0.18
Nodes (6): encoding/json.RawMessage, AllTopics(), UserAccount, Topic, TopicAccess, go_pkg_encoding_json

### Community 65 - "History API Handlers"
Cohesion: 0.47
Nodes (7): net/http.Request, net/http.ResponseWriter, HistoryHandler, ParquetHandler, respondWithError(), validateTopic(), CheckTopicAccess()

### Community 77 - "Client TS Node Config"
Cohesion: 0.22
Nodes (8): compilerOptions, allowSyntheticDefaultImports, composite, module, moduleResolution, skipLibCheck, strict, include

### Community 78 - "History API Auth Middleware"
Cohesion: 0.28
Nodes (7): net/http.Handler, extractAPIKey(), NewAuthMiddleware(), AuthMiddleware, contextKey, go_pkg_context, go_pkg_strings

### Community 85 - "Client ESLint Config"
Cohesion: 0.29
Nodes (6): @eslint/js, eslint-plugin-react-hooks, eslint-plugin-react-refresh, globals, typescript-eslint, ref_eslint_config

### Community 87 - "Vite Config"
Cohesion: 0.33
Nodes (5): buildTimestamp, vite, vite-plugin-i18next-loader, vite-tsconfig-paths, @vitejs/plugin-react

### Community 89 - "Benchmark Metric Collector"
Cohesion: 0.60
Nodes (3): audit_psql(), collect_storage(), collect.sh script

### Community 90 - "Client npm Scripts"
Cohesion: 0.40
Nodes (5): scripts, build, dev, lint, preview

### Community 92 - "API Gradle Wrapper"
Cohesion: 0.83
Nodes (3): gradlew script, die(), warn()

### Community 95 - "Company Capital Audit Table"
Cohesion: 0.67
Nodes (3): company_capital_audit, idx_company_capital_audit_change_id, idx_company_capital_audit_changed_at

### Community 96 - "Company Statuses Audit Table"
Cohesion: 0.67
Nodes (3): company_statuses_audit, idx_company_statuses_audit_change_id, idx_company_statuses_audit_changed_at

### Community 97 - "Company Statuses I18N Audit Table"
Cohesion: 0.67
Nodes (3): company_statusesi18n_audit, idx_company_statusesi18n_audit_change_id, idx_company_statusesi18n_audit_changed_at

### Community 98 - "Company Stocks Audit Table"
Cohesion: 0.67
Nodes (3): company_stocks_audit, idx_company_stocks_audit_change_id, idx_company_stocks_audit_changed_at

### Community 99 - "Countries Audit Table"
Cohesion: 0.67
Nodes (3): countries_audit, idx_countries_audit_change_id, idx_countries_audit_changed_at

### Community 8 - "Audit Methods & Architecture Docs"
Cohesion: 0.07
Nodes (40): Docker Compose Prod Stack, models.AuditEntry, /exportHistoryByChangeIdRange (Parquet), /exportHistoryByDateRange (Parquet), /getHistoryByChangeIdRange, /getHistoryByDateRange, Kafka UI Debezium Connect link, Kafka UI local cluster config (+32 more)

## Knowledge Gaps
- **152 isolated node(s):** `CompanyStockRequestDto`, `LegalEntityDto`, `PersonDto`, `LogoutResponse`, `DeleteModalProps` (+147 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 457 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **23 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `user_account` connect `MainDb Schema & Triggers` to `Authentication Flow`, `Currency Reference Data`, `API Exceptions & Cascade Delete`, `Capital Response DTOs`, `Company Stock Service`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Why does `EventBaseModel` connect `SSE Event Model` to `SSE Stream Controller`, `SSE Kafka Config`, `Password Hashing & Deserialization`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Why does `EventDeserializer` connect `Password Hashing & Deserialization` to `SSE Event Model`, `Audit Consumer DB Service`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **What connects `CompanyStockRequestDto`, `LegalEntityDto`, `PersonDto` to the rest of the system?**
  _152 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Client Capital & Autocompletes` be split into smaller, more focused modules?**
  _Cohesion score 0.08470588235294117 - nodes in this community are weakly interconnected._
- **Should `Legal Type Reference API` be split into smaller, more focused modules?**
  _Cohesion score 0.08558558558558559 - nodes in this community are weakly interconnected._
- **Should `Member Relation Reference API` be split into smaller, more focused modules?**
  _Cohesion score 0.08558558558558559 - nodes in this community are weakly interconnected._