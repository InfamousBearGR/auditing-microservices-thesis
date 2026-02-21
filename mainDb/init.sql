CREATE TABLE roles
(
    id            BIGSERIAL PRIMARY KEY,
    description   VARCHAR(255) NOT NULL UNIQUE,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now()
);
ALTER TABLE roles
    REPLICA IDENTITY FULL;

CREATE TABLE user_account
(
    id            BIGSERIAL PRIMARY KEY,
    username      VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id       BIGINT       NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_user_account_role_id FOREIGN KEY (role_id) REFERENCES roles (id)
);
ALTER TABLE user_account
    REPLICA IDENTITY FULL;

CREATE TABLE languages
(
    id            BIGSERIAL PRIMARY KEY,
    description   VARCHAR(255) NOT NULL UNIQUE,
    code          VARCHAR(10)  NOT NULL UNIQUE,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_languages_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);
ALTER TABLE languages
    REPLICA IDENTITY FULL;

CREATE TABLE countries
(
    id            BIGSERIAL PRIMARY KEY,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_countries_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE countries
    REPLICA IDENTITY FULL;

CREATE TABLE countriesI18n
(
    id            BIGSERIAL PRIMARY KEY,
    country_id    BIGINT       NOT NULL,
    description   VARCHAR(255) NOT NULL,
    language_id   BIGINT       NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_countriesI18n_languages_id FOREIGN KEY (language_id) REFERENCES languages (id),
    CONSTRAINT fk_countriesI18n_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    CONSTRAINT fk_countriesI18n_country_id FOREIGN KEY (country_id) REFERENCES countries (id),
    UNIQUE (country_id, language_id)
);

ALTER TABLE countriesI18n
    REPLICA IDENTITY FULL;

CREATE TABLE regions
(
    id            BIGSERIAL PRIMARY KEY,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_regions_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE regions
    REPLICA IDENTITY FULL;

CREATE TABLE regionsI18n
(
    id            BIGSERIAL PRIMARY KEY,
    region_id     BIGINT       NOT NULL,
    description   VARCHAR(255) NOT NULL,
    language_id   BIGINT       NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_regionsI18n_languages_id FOREIGN KEY (language_id) REFERENCES languages (id),
    CONSTRAINT fk_regionsI18n_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    CONSTRAINT fk_regionsI18n_region_id FOREIGN KEY (region_id) REFERENCES regions (id),
    UNIQUE (region_id, language_id)
);

ALTER TABLE regionsI18n
    REPLICA IDENTITY FULL;

CREATE TABLE prefectures
(
    id            BIGSERIAL PRIMARY KEY,
    region_id     BIGINT       NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_prefectures_region_id FOREIGN KEY (region_id) REFERENCES regions (id),
    CONSTRAINT fk_prefectures_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE prefectures
    REPLICA IDENTITY FULL;

CREATE TABLE prefecturesI18n
(
    id            BIGSERIAL PRIMARY KEY,
    prefecture_id BIGINT       NOT NULL,
    description   VARCHAR(255) NOT NULL,
    language_id   BIGINT       NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_prefecturesI18n_languages_id FOREIGN KEY (language_id) REFERENCES languages (id),
    CONSTRAINT fk_prefecturesI18n_prefecture_id FOREIGN KEY (prefecture_id) REFERENCES prefectures (id),
    CONSTRAINT fk_prefecturesI18n_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    UNIQUE (prefecture_id, language_id)
);

ALTER TABLE prefecturesI18n
    REPLICA IDENTITY FULL;

CREATE TABLE municipalities
(
    id            BIGSERIAL PRIMARY KEY,
    prefecture_id BIGINT       NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_municipalities_prefecture_id FOREIGN KEY (prefecture_id) REFERENCES prefectures (id),
    CONSTRAINT fk_municipalities_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE municipalities
    REPLICA IDENTITY FULL;

CREATE TABLE municipalitiesI18n
(
    id              BIGSERIAL PRIMARY KEY,
    municipality_id BIGINT       NOT NULL,
    description     VARCHAR(255) NOT NULL,
    language_id     BIGINT       NOT NULL,
    last_user_id    BIGINT,
    change_reason   VARCHAR(255) NOT NULL,
    date_created    TIMESTAMP DEFAULT now(),
    last_updated    TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_municipalitiesI18n_languages_id FOREIGN KEY (language_id) REFERENCES languages (id),
    CONSTRAINT fk_municipalitiesI18n_municipality_id FOREIGN KEY (municipality_id) REFERENCES municipalities (id),
    CONSTRAINT fk_municipalitiesI18n_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    UNIQUE (municipality_id, language_id)
);

ALTER TABLE municipalitiesI18n
    REPLICA IDENTITY FULL;

CREATE TABLE company_statuses
(
    id            BIGSERIAL PRIMARY KEY,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_company_statuses_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE company_statuses
    REPLICA IDENTITY FULL;

CREATE TABLE company_statusesI18n
(
    id                BIGSERIAL PRIMARY KEY,
    company_status_id BIGINT       NOT NULL,
    description       VARCHAR(255) NOT NULL,
    language_id       BIGINT       NOT NULL,
    last_user_id      BIGINT,
    change_reason     VARCHAR(255) NOT NULL,
    date_created      TIMESTAMP DEFAULT now(),
    last_updated      TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_company_statusesI18n_languages_id FOREIGN KEY (language_id) REFERENCES languages (id),
    CONSTRAINT fk_company_statusesI18n_company_status_id FOREIGN KEY (company_status_id) REFERENCES company_statuses (id),
    CONSTRAINT fk_company_statusesI18n_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    UNIQUE (company_status_id, language_id)
);

ALTER TABLE company_statusesI18n
    REPLICA IDENTITY FULL;

CREATE TABLE legal_types
(
    id            BIGSERIAL PRIMARY KEY,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_legal_types_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE legal_types
    REPLICA IDENTITY FULL;

CREATE TABLE legal_typesI18n
(
    id            BIGSERIAL PRIMARY KEY,
    legal_type_id BIGINT       NOT NULL,
    description   VARCHAR(255) NOT NULL,
    language_id   BIGINT       NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_legal_typesI18n_language_id FOREIGN KEY (language_id) REFERENCES languages (id),
    CONSTRAINT fk_legal_typesI18n_legal_type_id FOREIGN KEY (legal_type_id) REFERENCES legal_types (id),
    CONSTRAINT fk_legal_typesI18n_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    UNIQUE (legal_type_id, language_id)
);

ALTER TABLE legal_typesI18n
    REPLICA IDENTITY FULL;

CREATE TABLE member_relations
(
    id            BIGSERIAL PRIMARY KEY,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_member_relations_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE member_relations
    REPLICA IDENTITY FULL;

CREATE TABLE member_relationsI18n
(
    id                 BIGSERIAL PRIMARY KEY,
    member_relation_id BIGINT       NOT NULL,
    description        VARCHAR(255) NOT NULL,
    language_id        BIGINT       NOT NULL,
    last_user_id       BIGINT,
    change_reason      VARCHAR(255) NOT NULL,
    date_created       TIMESTAMP DEFAULT now(),
    last_updated       TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_member_relationsI18n_language_id FOREIGN KEY (language_id) REFERENCES languages (id),
    CONSTRAINT fk_member_relationsI18n_member_relation_id FOREIGN KEY (member_relation_id) REFERENCES member_relations (id),
    CONSTRAINT fk_member_relationsI18n_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    UNIQUE (member_relation_id, language_id)
);

ALTER TABLE member_relationsI18n
    REPLICA IDENTITY FULL;

CREATE TABLE stock_types
(
    id            BIGSERIAL PRIMARY KEY,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_stock_types_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE stock_types
    REPLICA IDENTITY FULL;

CREATE TABLE stock_typesI18n
(
    id            BIGSERIAL PRIMARY KEY,
    stock_type_id BIGINT       NOT NULL,
    description   VARCHAR(255) NOT NULL,
    language_id   BIGINT       NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_stock_typesI18n_language_id FOREIGN KEY (language_id) REFERENCES languages (id),
    CONSTRAINT fk_stock_typesI18n_stock_type_id FOREIGN KEY (stock_type_id) REFERENCES stock_types (id),
    CONSTRAINT fk_stock_typesI18n_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    UNIQUE (stock_type_id, language_id)
);

ALTER TABLE stock_typesI18n
    REPLICA IDENTITY FULL;

CREATE TABLE currency
(
    id            BIGSERIAL PRIMARY KEY,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_currency_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE currency
    REPLICA IDENTITY FULL;

CREATE TABLE currencyI18n
(
    id            BIGSERIAL PRIMARY KEY,
    currency_id   BIGINT       NOT NULL,
    description   VARCHAR(255) NOT NULL,
    language_id   BIGINT       NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_currencyI18n_language_id FOREIGN KEY (language_id) REFERENCES languages (id),
    CONSTRAINT fk_currencyI18n_currency_id FOREIGN KEY (currency_id) REFERENCES currency (id),
    CONSTRAINT fk_currencyI18n_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    UNIQUE (currency_id, language_id)
);

ALTER TABLE currencyI18n
    REPLICA IDENTITY FULL;

CREATE TABLE company
(
    id                BIGSERIAL PRIMARY KEY,
    name              VARCHAR(255) NOT NULL,
    city              VARCHAR(255),
    street            VARCHAR(255),
    country_id        BIGINT,
    prefecture_id     BIGINT,
    municipality_id   BIGINT,
    street_number     VARCHAR(50),
    region_id         BIGINT,
    postal_code       VARCHAR(20),
    afm               VARCHAR(9)   NOT NULL,
    legal_type_id     BIGINT       NOT NULL,
    date_incorporated DATE         NOT NULL,
    gemi_number       VARCHAR(12)  NOT NULL,
    company_status_id BIGINT       NOT NULL,
    last_user_id      BIGINT,
    change_reason     VARCHAR(255) NOT NULL,
    date_created      TIMESTAMP DEFAULT now(),
    last_updated      TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    CONSTRAINT fk_company_prefecture_id FOREIGN KEY (prefecture_id) REFERENCES prefectures (id),
    CONSTRAINT fk_company_municipality_id FOREIGN KEY (municipality_id) REFERENCES municipalities (id),
    CONSTRAINT fk_company_region_id FOREIGN KEY (region_id) REFERENCES regions (id),
    CONSTRAINT fk_company_country_id FOREIGN KEY (country_id) REFERENCES countries (id),
    CONSTRAINT fk_company_legal_type_id FOREIGN KEY (legal_type_id) REFERENCES legal_types (id),
    CONSTRAINT fk_company_company_status_id FOREIGN KEY (company_status_id) REFERENCES company_statuses (id)
);
ALTER TABLE company
    REPLICA IDENTITY FULL;

CREATE TABLE person
(
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    surname         VARCHAR(255) NOT NULL,
    afm             VARCHAR(9)   NOT NULL,
    city            VARCHAR(255),
    street          VARCHAR(255),
    country_id      BIGINT,
    prefecture_id   BIGINT,
    municipality_id BIGINT,
    street_number   VARCHAR(50),
    region_id       BIGINT,
    postal_code     VARCHAR(20),
    birth_date      DATE         NOT NULL,
    birth_place     VARCHAR(255) NOT NULL,
    identity_number VARCHAR(20)  NOT NULL,
    phone_number    VARCHAR(20),
    last_user_id    BIGINT,
    change_reason   VARCHAR(255) NOT NULL,
    date_created    TIMESTAMP DEFAULT now(),
    last_updated    TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_person_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    CONSTRAINT fk_person_prefecture_id FOREIGN KEY (prefecture_id) REFERENCES prefectures (id),
    CONSTRAINT fk_person_municipality_id FOREIGN KEY (municipality_id) REFERENCES municipalities (id),
    CONSTRAINT fk_person_region_id FOREIGN KEY (region_id) REFERENCES regions (id),
    CONSTRAINT fk_person_country_id FOREIGN KEY (country_id) REFERENCES countries (id)
);
ALTER TABLE person
    REPLICA IDENTITY FULL;

CREATE TABLE legal_entity
(
    id              BIGSERIAL PRIMARY KEY,
    gemi_number     VARCHAR(12)  NOT NULL,
    business_name   VARCHAR(255) NOT NULL,
    phone_number    VARCHAR(20),
    afm             VARCHAR(9)   NOT NULL,
    city            VARCHAR(255),
    street          VARCHAR(255),
    country_id      BIGINT,
    prefecture_id   BIGINT,
    municipality_id BIGINT,
    street_number   VARCHAR(50),
    region_id       BIGINT,
    postal_code     VARCHAR(20),
    last_user_id    BIGINT,
    change_reason   VARCHAR(255) NOT NULL,
    date_created    TIMESTAMP DEFAULT now(),
    last_updated    TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_legal_entity_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    CONSTRAINT fk_legal_entity_prefecture_id FOREIGN KEY (prefecture_id) REFERENCES prefectures (id),
    CONSTRAINT fk_legal_entity_municipality_id FOREIGN KEY (municipality_id) REFERENCES municipalities (id),
    CONSTRAINT fk_legal_entity_region_id FOREIGN KEY (region_id) REFERENCES regions (id),
    CONSTRAINT fk_legal_entity_country_id FOREIGN KEY (country_id) REFERENCES countries (id)
);
ALTER TABLE legal_entity
    REPLICA IDENTITY FULL;

CREATE TABLE member
(
    id                       BIGSERIAL PRIMARY KEY,
    active                   BOOLEAN      NOT NULL,
    date_from                DATE         NOT NULL,
    date_to                  DATE         NOT NULL,
    percentage_of_ownership  VARCHAR(10)  NOT NULL,
    person_id                BIGINT       NULL,
    legal_entity_id          BIGINT       NULL,
    company_id               BIGINT       NOT NULL,
    representative_of_member BIGINT       NULL,
    represented_individual   BOOLEAN      NOT NULL,
    represented_together     BOOLEAN      NOT NULL,
    member_relation_id       BIGINT       NOT NULL,
    last_user_id             BIGINT,
    change_reason            VARCHAR(255) NOT NULL,
    date_created             TIMESTAMP DEFAULT now(),
    last_updated             TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_member_person_id FOREIGN KEY (person_id) REFERENCES person (id),
    CONSTRAINT fk_member_legal_entity_id FOREIGN KEY (legal_entity_id) REFERENCES legal_entity (id),
    CONSTRAINT fk_member_company_id FOREIGN KEY (company_id) REFERENCES company (id),
    CONSTRAINT fk_member_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    CONSTRAINT fk_member_representative_of_member FOREIGN KEY (representative_of_member) REFERENCES person (id),
    CONSTRAINT fk_member_member_relation_id FOREIGN KEY (member_relation_id) REFERENCES member_relations (id)
);

CREATE TABLE company_stocks
(
    id            BIGSERIAL PRIMARY KEY,
    company_id    BIGINT         NOT NULL,
    stock_type_id BIGINT         NOT NULL,
    amount        BIGINT         NOT NULL,
    nominal_price NUMERIC(15, 2) NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255)   NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_company_stocks_company_id FOREIGN KEY (company_id) REFERENCES company (id),
    CONSTRAINT fk_company_stocks_stock_type_id FOREIGN KEY (stock_type_id) REFERENCES stock_types (id),
    CONSTRAINT fk_company_stocks_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id)
);

ALTER TABLE company_stocks
    REPLICA IDENTITY FULL;

CREATE TABLE company_capital
(
    id            BIGSERIAL PRIMARY KEY,
    company_id    BIGINT         NOT NULL,
    total_amount  NUMERIC(15, 2) NOT NULL,
    currency_id   BIGINT         NOT NULL,
    last_user_id  BIGINT,
    change_reason VARCHAR(255)   NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_company_capital_company_id FOREIGN KEY (company_id) REFERENCES company (id),
    CONSTRAINT fk_company_capital_last_user_id FOREIGN KEY (last_user_id) REFERENCES user_account (id),
    CONSTRAINT fk_company_capital_currency_id FOREIGN KEY (currency_id) REFERENCES currency (id)
);

ALTER TABLE company_capital
    REPLICA IDENTITY FULL;

ALTER TABLE member
    REPLICA IDENTITY FULL;

CREATE OR REPLACE FUNCTION update_last_updated_column()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_company_last_updated
    BEFORE UPDATE
    ON company
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE OR REPLACE FUNCTION set_creation_timestamps()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.date_created = now();
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER insert_company_timestamps
    BEFORE INSERT
    ON company
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_person_last_updated
    BEFORE UPDATE
    ON person
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_person_timestamps
    BEFORE INSERT
    ON person
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_user_account_last_updated
    BEFORE UPDATE
    ON user_account
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_user_account_timestamps
    BEFORE INSERT
    ON user_account
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_roles_last_updated
    BEFORE UPDATE
    ON roles
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_roles_timestamps
    BEFORE INSERT
    ON roles
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_languages_last_updated
    BEFORE UPDATE
    ON languages
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_languages_timestamps
    BEFORE INSERT
    ON languages
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_countries_last_updated
    BEFORE UPDATE
    ON countries
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_countries_timestamps
    BEFORE INSERT
    ON countries
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_regions_last_updated
    BEFORE UPDATE
    ON regions
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_regions_timestamps
    BEFORE INSERT
    ON regions
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_prefectures_last_updated
    BEFORE UPDATE
    ON prefectures
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_prefectures_timestamps
    BEFORE INSERT
    ON prefectures
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_municipalities_last_updated
    BEFORE UPDATE
    ON municipalities
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_municipalities_timestamps
    BEFORE INSERT
    ON municipalities
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_company_statuses_last_updated
    BEFORE UPDATE
    ON company_statuses
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_company_statuses_timestamps
    BEFORE INSERT
    ON company_statuses
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_legal_types_last_updated
    BEFORE UPDATE
    ON legal_types
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_legal_types_timestamps
    BEFORE INSERT
    ON legal_types
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_member_relations_last_updated
    BEFORE UPDATE
    ON member_relations
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_member_relations_timestamps
    BEFORE INSERT
    ON member_relations
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_legal_entity_last_updated
    BEFORE UPDATE
    ON legal_entity
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_legal_entity_timestamps
    BEFORE INSERT
    ON legal_entity
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_member_last_updated
    BEFORE UPDATE
    ON member
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_member_timestamps
    BEFORE INSERT
    ON member
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_countriesI18n_last_updated
    BEFORE UPDATE
    ON countriesI18n
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_countriesI18n_timestamps
    BEFORE INSERT
    ON countriesI18n
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_regionsI18n_last_updated
    BEFORE UPDATE
    ON regionsI18n
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_regionsI18n_timestamps
    BEFORE INSERT
    ON regionsI18n
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_prefecturesI18n_last_updated
    BEFORE UPDATE
    ON prefecturesI18n
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_prefecturesI18n_timestamps
    BEFORE INSERT
    ON prefecturesI18n
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_municipalitiesI18n_last_updated
    BEFORE UPDATE
    ON municipalitiesI18n
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_municipalitiesI18n_timestamps
    BEFORE INSERT
    ON municipalitiesI18n
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_company_statusesI18n_last_updated
    BEFORE UPDATE
    ON company_statusesI18n
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_company_statusesI18n_timestamps
    BEFORE INSERT
    ON company_statusesI18n
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_legal_typesI18n_last_updated
    BEFORE UPDATE
    ON legal_typesI18n
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_legal_typesI18n_timestamps
    BEFORE INSERT
    ON legal_typesI18n
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_member_relationsI18n_last_updated
    BEFORE UPDATE
    ON member_relationsI18n
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_member_relationsI18n_timestamps
    BEFORE INSERT
    ON member_relationsI18n
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_stock_types_last_updated
    BEFORE UPDATE
    ON stock_types
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_stock_types_timestamps
    BEFORE INSERT
    ON stock_types
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_stock_typesI18n_last_updated
    BEFORE UPDATE
    ON stock_typesI18n
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_stock_typesI18n_timestamps
    BEFORE INSERT
    ON stock_typesI18n
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_company_stocks_last_updated
    BEFORE UPDATE
    ON company_stocks
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_company_stocks_timestamps
    BEFORE INSERT
    ON company_stocks
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

CREATE TRIGGER update_company_capital_last_updated
    BEFORE UPDATE
    ON company_capital
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE TRIGGER insert_company_capital_timestamps
    BEFORE INSERT
    ON company_capital
    FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();

INSERT INTO roles (description, change_reason)
VALUES ('Admin', 'Initialization'),
       ('User', 'Initialization');

INSERT INTO user_account (username, password_hash, role_id, change_reason)
VALUES ('admin', 'ud4k9Q7SrDX/IoDhB95m3Q==:Y0AD/f7morva6T4Ru7PFZEMPTY5rneTBe+SO9oNSX4g=', 1, 'Initialization'),
       ('user1', 'ud4k9Q7SrDX/IoDhB95m3Q==:Y0AD/f7morva6T4Ru7PFZEMPTY5rneTBe+SO9oNSX4g=', 2, 'Initialization'),
       ('user2', 'ud4k9Q7SrDX/IoDhB95m3Q==:Y0AD/f7morva6T4Ru7PFZEMPTY5rneTBe+SO9oNSX4g=', 2, 'Initialization'),
       ('user3', 'ud4k9Q7SrDX/IoDhB95m3Q==:Y0AD/f7morva6T4Ru7PFZEMPTY5rneTBe+SO9oNSX4g=', 2, 'Initialization'),
       ('user4', 'ud4k9Q7SrDX/IoDhB95m3Q==:Y0AD/f7morva6T4Ru7PFZEMPTY5rneTBe+SO9oNSX4g=', 2, 'Initialization');

INSERT INTO languages (description, code, last_user_id, change_reason, date_created, last_updated)
VALUES ('Ελληνικά', 'el', 1, 'Initialization', now(), now()),
       ('English', 'en', 1, 'Initialization', now(), now());

-- Insert base legal_types records
INSERT INTO legal_types (last_user_id, change_reason)
WITH RECURSIVE cnt(n) AS (SELECT 1
                          UNION ALL
                          SELECT n + 1
                          FROM cnt
                          WHERE n < 29)
SELECT 1, 'Initialization'
FROM cnt;

-- Insert legal_types translations
INSERT INTO legal_typesI18n (legal_type_id, description, language_id, last_user_id, change_reason)
VALUES (1, 'Inadequate Info', 1, 1, 'Initialization'),
       (2, 'ΑΕ', 1, 1, 'Initialization'),
       (3, 'ΟΕ', 1, 1, 'Initialization'),
       (4, 'ΣυνΠΕ', 1, 1, 'Initialization'),
       (5, 'ΕΕ', 1, 1, 'Initialization'),
       (6, 'Φυσικό Πρόσωπο', 1, 1, 'Initialization'),
       (7, 'ΠΑΕ', 1, 1, 'Initialization'),
       (8, 'ΚΑΕ', 1, 1, 'Initialization'),
       (9, 'ΕΠΕ', 1, 1, 'Initialization'),
       (10, 'ΚΟΙΝΩΝΙΑ', 1, 1, 'Initialization'),
       (11, 'Ευρωπαϊκός Όμιλος Οικονομικού Σκοπού', 1, 1, 'Initialization'),
       (12, 'Συνεταιρισμός', 1, 1, 'Initialization'),
       (13, 'Ευρωπαϊκή Εταιρία (SE)', 1, 1, 'Initialization'),
       (14, 'Ευρωπαϊκή Συνεταιριστική Εταιρία (SCE)', 1, 1, 'Initialization'),
       (15, 'Κοινοπραξία', 1, 1, 'Initialization'),
       (16, 'Υποκατάστημα Αλλοδαπής', 1, 1, 'Initialization'),
       (17, 'ΑΤΟΜΙΚΗ', 1, 1, 'Initialization'),
       (18, 'ΕΝΩΣΗ ΠΡΟΣΩΠΩΝ', 1, 1, 'Initialization'),
       (19, 'ΑΣΤΙΚΗ ΕΤΑΙΡΕΙΑ 784 Α.Κ.', 1, 1, 'Initialization'),
       (20, 'ΙΚΕ', 1, 1, 'Initialization'),
       (21, 'ΚΟΙ.Σ.Π.Ε', 1, 1, 'Initialization'),
       (22, 'Αγροτικός Συνεταιρισμός', 1, 1, 'Initialization'),
       (23, 'ΛΟΙΠΩΝ ΥΠΟΧΡΕΩΝ', 1, 1, 'Initialization'),
       (24, 'Ενεργειακή Κοινότητα', 1, 1, 'Initialization'),
       (25, 'Κοιν.Σ.Επ.', 1, 1, 'Initialization'),
       (26, 'Συνεταιρισμός Εργαζομένων', 1, 1, 'Initialization'),
       (27, 'ΕΕ κατά μετοχές', 1, 1, 'Initialization'),
       (28, 'ΚΟΙΝΟΤΗΤΑ ΑΝΑΝΕΩΣΙΜΗΣ ΕΝΕΡΓΕΙΑΣ', 1, 1, 'Initialization'),
       (29, 'ΕΝΕΡΓΕΙΑΚΗ ΚΟΙΝΟΤΗΤΑ ΠΟΛΙΤΩΝ ', 1, 1, 'Initialization'),
       (1, 'Inadequate Info', 2, 1, 'Initialization'),
       (2, 'SA', 2, 1, 'Initialization'),
       (3, 'GP', 2, 1, 'Initialization'),
       (4, 'CoR', 2, 1, 'Initialization'),
       (5, 'LP', 2, 1, 'Initialization'),
       (6, 'Natural Person', 2, 1, 'Initialization'),
       (7, 'PAE', 2, 1, 'Initialization'),
       (8, 'OEM', 2, 1, 'Initialization'),
       (9, 'LTD.', 2, 1, 'Initialization'),
       (10, 'SOCIETY', 2, 1, 'Initialization'),
       (11, 'European Economic Interest Group', 2, 1, 'Initialization'),
       (12, 'Partnership', 2, 1, 'Initialization'),
       (13, 'European Company (SE)', 2, 1, 'Initialization'),
       (14, 'European Cooperative Society (SCE)', 2, 1, 'Initialization'),
       (15, 'Consortium', 2, 1, 'Initialization'),
       (16, 'Foreign Branch', 2, 1, 'Initialization'),
       (17, 'PERSONAL', 2, 1, 'Initialization'),
       (18, 'ASSOCIATION OF PERSONS', 2, 1, 'Initialization'),
       (19, 'Civil Company 784 S.A.K.', 2, 1, 'Initialization'),
       (20, 'IKE', 2, 1, 'Initialization'),
       (21, 'KOI.S.P.E.', 2, 1, 'Initialization'),
       (22, 'Agricultural Partnership', 2, 1, 'Initialization'),
       (23, 'OTHER OBLIGATIONS', 2, 1, 'Initialization'),
       (24, 'Energy Community', 2, 1, 'Initialization'),
       (25, 'Joint Committee.', 2, 1, 'Initialization'),
       (26, 'Workers'' Cooperatives', 2, 1, 'Initialization'),
       (27, 'LP by shares', 2, 1, 'Initialization'),
       (28, 'Renewable energy community', 2, 1, 'Initialization'),
       (29, 'Citizen energy communities', 2, 1, 'Initialization');

-- Insert base member_relations records
INSERT INTO member_relations (last_user_id, change_reason)
WITH RECURSIVE cnt(n) AS (SELECT 1
                          UNION ALL
                          SELECT n + 1
                          FROM cnt
                          WHERE n < 17)
SELECT 1, 'Initialization'
FROM cnt;

-- Insert member_relations translations
INSERT INTO member_relationsI18n (member_relation_id, description, language_id, last_user_id, change_reason)
VALUES (1, 'no info', 1, 1, 'Initialization'),
       (2, 'Ετερόρρυθμο Μέλος', 1, 1, 'Initialization'),
       (3, 'Μέλος & Διαχειριστής', 1, 1, 'Initialization'),
       (4, 'Ομόρρυθμο Μέλος', 1, 1, 'Initialization'),
       (5, 'Άλλο', 1, 1, 'Initialization'),
       (6, 'Μοναδικός Μέτοχος', 1, 1, 'Initialization'),
       (7, 'Μοναδικός Εταίρος', 1, 1, 'Initialization'),
       (8, 'Ομόρρυθμο Μέλος & Διαχειριστής', 1, 1, 'Initialization'),
       (9, 'Ετερόρρυθμο Μέλος & Διαχειριστής', 1, 1, 'Initialization'),
       (10, 'Εταίρος - Μέλος', 1, 1, 'Initialization'),
       (11, 'Ετερόρρυθμο Μέλος & Εκπρόσωπος', 1, 1, 'Initialization'),
       (12, 'Ετερόρρυθμο Μέλος, Διαχειριστής & Εκπρόσωπος', 1, 1, 'Initialization'),
       (13, 'Ομόρρυθμο Μέλος & Εκπρόσωπος', 1, 1, 'Initialization'),
       (14, 'Ομόρρυθμο Μέλος, Διαχειριστής & Εκπρόσωπος', 1, 1, 'Initialization'),
       (15, 'Μοναδικός Εταίρος και Διαχειριστής', 1, 1, 'Initialization'),
       (16, 'Μέλος & Εκπρόσωπος', 1, 1, 'Initialization'),
       (17, 'Μέλος, Διαχειριστής & Εκπρόσωπος', 1, 1, 'Initialization'),
       (1, 'no info', 2, 1, 'Initialization'),
       (2, 'Interregional Member', 2, 1, 'Initialization'),
       (3, 'Member', 2, 1, 'Initialization'),
       (4, 'General Partner', 2, 1, 'Initialization'),
       (5, 'Other', 2, 1, 'Initialization'),
       (6, 'Sole Shareholder', 2, 1, 'Initialization'),
       (7, 'Unique Partner', 2, 1, 'Initialization'),
       (8, 'General Partner', 2, 1, 'Initialization'),
       (9, 'Interregional Member', 2, 1, 'Initialization'),
       (10, 'Partner - Member', 2, 1, 'Initialization'),
       (11, 'Interregional Member', 2, 1, 'Initialization'),
       (12, 'Alternate Member, Administrator', 2, 1, 'Initialization'),
       (13, 'General Partner', 2, 1, 'Initialization'),
       (14, 'General Partner, Administrator', 2, 1, 'Initialization'),
       (15, 'Sole Partner and Administrator', 2, 1, 'Initialization'),
       (16, 'Member & Representative', 2, 1, 'Initialization'),
       (17, 'Member, Administrator & Representative', 2, 1, 'Initialization');

INSERT INTO countries (last_user_id, change_reason)
WITH RECURSIVE cnt(n) AS (SELECT 1
                          UNION ALL
                          SELECT n + 1
                          FROM cnt
                          WHERE n < 255)
SELECT 1, 'Initialization'
FROM cnt;


INSERT INTO countriesI18n (country_id, description, language_id, last_user_id, change_reason)
VALUES (1, 'ΝΙΓΗΡΙΑ', 1, 1, 'Initialization'),
       (2, 'ΝΙΚΑΡΑΓΟΥΑ', 1, 1, 'Initialization'),
       (3, 'ΟΛΛΑΝΔΙΑ', 1, 1, 'Initialization'),
       (4, 'ΝΟΡΒΗΓΙΑ', 1, 1, 'Initialization'),
       (5, 'ΝΕΠΑΛ', 1, 1, 'Initialization'),
       (6, 'ΝΑΟΥΡΟΥ', 1, 1, 'Initialization'),
       (7, 'ΝΕΑ ΖΗΛΑΝΔΙΑ', 1, 1, 'Initialization'),
       (8, 'ΟΜΑΝ', 1, 1, 'Initialization'),
       (9, 'ΩΚΕΑΝΙΑ-ΝΕΑ ΖΗΛΑΝΔΙΑ', 1, 1, 'Initialization'),
       (10, 'ΠΑΚΙΣΤΑΝ', 1, 1, 'Initialization'),
       (11, 'ΠΑΝΑΜΑΣ', 1, 1, 'Initialization'),
       (12, 'ΠΕΡΟΥ', 1, 1, 'Initialization'),
       (13, 'ΦΙΛΙΠΠΙΝΕΣ', 1, 1, 'Initialization'),
       (14, 'ΠΑΠΟΥΑ-ΝΕΑ ΓΟΥΙΝΕΑ', 1, 1, 'Initialization'),
       (15, 'ΠΟΛΩΝΙΑ', 1, 1, 'Initialization'),
       (16, 'ΒΟΡΕΙΑ ΚΟΡΕΑ', 1, 1, 'Initialization'),
       (17, 'ΠΟΡΤΟΓΑΛΙΑ', 1, 1, 'Initialization'),
       (18, 'ΠΑΡΑΓΟΥΑΗ', 1, 1, 'Initialization'),
       (19, 'ΓΑΛΛΙΚΗ ΠΟΛΥΝΗΣΙΑ', 1, 1, 'Initialization'),
       (20, 'ΚΑΤΑΡ', 1, 1, 'Initialization'),
       (21, 'ΡΟΥΜΑΝΙΑ', 1, 1, 'Initialization'),
       (22, 'ΡΩΣΙΑ', 1, 1, 'Initialization'),
       (23, 'ΡΟΥΑΝΤΑ', 1, 1, 'Initialization'),
       (24, 'ΣΑΟΥΔΙΚΗ ΑΡΑΒΙΑ', 1, 1, 'Initialization'),
       (25, 'ΣΟΥΔΑΝ', 1, 1, 'Initialization'),
       (26, 'ΣΕΝΕΓΑΛΗ', 1, 1, 'Initialization'),
       (27, 'ΣΙΓΚΑΠΟΥΡΗ', 1, 1, 'Initialization'),
       (28, 'ΑΓΙΑ ΕΛΕΝΗ', 1, 1, 'Initialization'),
       (29, 'ΝΗΣΙΑ ΣΟΛΟΜΩΝΤΟΣ', 1, 1, 'Initialization'),
       (30, 'ΣΙΕΡΡΑ ΛΕΟΝΕ', 1, 1, 'Initialization'),
       (31, 'ΕΛ ΣΑΛΒΑΔΟΡ', 1, 1, 'Initialization'),
       (32, 'ΣΟΜΑΛΙΑ', 1, 1, 'Initialization'),
       (33, 'ΣΑΝΤΟ ΤΟΜΕ ΚΑΙ ΠΡΙΝΣΙΠΕ', 1, 1, 'Initialization'),
       (34, 'ΣΟΥΡΙΝΑΜ', 1, 1, 'Initialization'),
       (35, 'ΣΛΟΒΑΚΙΑ', 1, 1, 'Initialization'),
       (36, 'ΣΛΟΒΕΝΙΑ', 1, 1, 'Initialization'),
       (37, 'ΣΟΥΗΔΙΑ', 1, 1, 'Initialization'),
       (38, 'ΖΟΥΑΖΗΛΑΝΔΗ', 1, 1, 'Initialization'),
       (39, 'ΣΕΥΧΕΛΕΣ', 1, 1, 'Initialization'),
       (40, 'ΣΥΡΙΑ', 1, 1, 'Initialization'),
       (41, 'ΝΗΣΙΑ ΤΕΡΚΣ ΚΑΙ ΚΑΙΚΟΣ', 1, 1, 'Initialization'),
       (42, 'ΤΣΑΝΤ', 1, 1, 'Initialization'),
       (43, 'ΤΟΓΚΟ', 1, 1, 'Initialization'),
       (44, 'ΤΑΙΛΑΝΔΗ', 1, 1, 'Initialization'),
       (45, 'ΤΑΤΖΙΚΙΣΤΑΝ', 1, 1, 'Initialization'),
       (46, 'ΤΟΥΡΚΜΕΝΙΣΤΑΝ', 1, 1, 'Initialization'),
       (47, 'ΑΝΑΤΟΛΙΚΟ ΤΙΜΟΡ', 1, 1, 'Initialization'),
       (48, 'ΤΟΝΓΚΑ', 1, 1, 'Initialization'),
       (49, 'ΤΡΙΝΙΝΤΑΝ ΚΑΙ ΤΟΜΠΑΓΚΟ', 1, 1, 'Initialization'),
       (50, 'ΤΥΝΗΣΙΑ', 1, 1, 'Initialization'),
       (51, 'ΤΟΥΡΚΙΑ', 1, 1, 'Initialization'),
       (52, 'ΤΟΥΒΑΛΟΥ', 1, 1, 'Initialization'),
       (53, 'ΤΑΙΒΑΝ', 1, 1, 'Initialization'),
       (54, 'ΤΑΝΖΑΝΙΑ', 1, 1, 'Initialization'),
       (55, 'ΟΥΓΚΑΝΤΑ', 1, 1, 'Initialization'),
       (56, 'ΟΥΚΡΑΝΙΑ', 1, 1, 'Initialization'),
       (57, 'ΝΗΣΙΑ ΜΙΚΡΑ ΤΩΝ Η.Π.Α.', 1, 1, 'Initialization'),
       (58, 'ΟΥΡΟΥΓΟΥΑΗ', 1, 1, 'Initialization'),
       (59, 'Η.Π.Α.', 1, 1, 'Initialization'),
       (60, 'ΟΥΖΜΠΕΚΙΣΤΑΝ', 1, 1, 'Initialization'),
       (61, 'ΒΑΤΙΚΑΝΟ', 1, 1, 'Initialization'),
       (62, 'ΑΓΙΟΣ ΒΙΚΕΝΤΙΟΣ', 1, 1, 'Initialization'),
       (63, 'ΒΕΝΕΖΟΥΕΛΑ', 1, 1, 'Initialization'),
       (64, 'ΠΑΡΘΕΝΟΙ ΝΗΣΟΙ ΚΑΙ ΜΟΝΤΣΕΡΑ', 1, 1, 'Initialization'),
       (65, 'ΠΑΡΘΕΝΟΙ ΝΗΣΟΙ ΤΩΝ Η.Π.Α.', 1, 1, 'Initialization'),
       (66, 'ΒΙΕΤΝΑΜ', 1, 1, 'Initialization'),
       (67, 'ΒΑΝΟΥΑΤΟΥ', 1, 1, 'Initialization'),
       (68, 'ΣΑΜΟΑ ΔΥΤΙΚΗ', 1, 1, 'Initialization'),
       (69, 'ΕΥΡΩΠΑΙΚΗ ΕΝΩΣΗ', 1, 1, 'Initialization'),
       (70, 'ΥΕΜΕΝΗ', 1, 1, 'Initialization'),
       (71, 'ΣΕΡΒΙΑ ΚΑΙ ΜΑΥΡΟΒΟΥΝΙΟ', 1, 1, 'Initialization'),
       (72, 'ΔΗΜΟΚΡΑΤΙΑ ΝΟΤΙΟΥ ΑΦΡΙΚΗΣ', 1, 1, 'Initialization'),
       (73, 'ΖΑΙΡ', 1, 1, 'Initialization'),
       (74, 'ΖΑΜΠΙΑ', 1, 1, 'Initialization'),
       (75, 'ΖΙΜΠΑΜΠΟΥΕ', 1, 1, 'Initialization'),
       (76, 'Π.Γ.Δ.Μ.', 1, 1, 'Initialization'),
       (77, 'ΑΡΟΥΜΠΑ', 1, 1, 'Initialization'),
       (78, 'ΑΦΓΑΝΙΣΤΑΝ', 1, 1, 'Initialization'),
       (79, 'ΑΓΚΟΛΑ', 1, 1, 'Initialization'),
       (80, 'ΑΝΓΚΟΥΙΛΛΑ', 1, 1, 'Initialization'),
       (81, 'ΑΛΒΑΝΙΑ', 1, 1, 'Initialization'),
       (82, 'ΑΝΔΟΡΡΑ', 1, 1, 'Initialization'),
       (83, 'ΟΛΛΑΝΔΙΚΕΣ ΑΝΤΙΛΛΕΣ', 1, 1, 'Initialization'),
       (84, 'ΕΝΩΜΕΝΑ ΑΡΑΒΙΚΑ ΕΜΙΡΑΤΑ', 1, 1, 'Initialization'),
       (85, 'ΑΡΓΕΝΤΙΝΗ', 1, 1, 'Initialization'),
       (86, 'ΑΡΜΕΝΙΑ', 1, 1, 'Initialization'),
       (87, 'ΣΑΜΟΑ ΑΜΕΡΙΚΑΝΙΚΗ', 1, 1, 'Initialization'),
       (88, 'ΓΑΛΛΙΚΕΣ ΝΟΤΙΕΣ ΠΕΡΙΟΧΕΣ', 1, 1, 'Initialization'),
       (89, 'ΑΝΤΙΓΚΟΥΑ ΚΑΙ ΜΠΑΡΜΠΟΥΝΤΑ', 1, 1, 'Initialization'),
       (90, 'ΑΥΣΤΡΑΛΙΑ', 1, 1, 'Initialization'),
       (91, 'ΑΥΣΤΡΙΑ', 1, 1, 'Initialization'),
       (92, 'ΑΖΕΡΜΠΑΙΤΖΑΝ', 1, 1, 'Initialization'),
       (93, 'ΜΠΟΥΡΟΥΝΤΙ', 1, 1, 'Initialization'),
       (94, 'ΒΕΛΓΙΟ', 1, 1, 'Initialization'),
       (95, 'ΜΠΕΝΙΝ', 1, 1, 'Initialization'),
       (96, 'ΜΠΟΥΡΚΙΝΑ ΦΑΣΟ', 1, 1, 'Initialization'),
       (97, 'ΜΠΑΓΚΛΑΝΤΕΣ', 1, 1, 'Initialization'),
       (98, 'ΒΟΥΛΓΑΡΙΑ', 1, 1, 'Initialization'),
       (99, 'ΜΠΑΧΡΕΙΝ', 1, 1, 'Initialization'),
       (100, 'ΜΠΑΧΑΜΕΣ', 1, 1, 'Initialization'),
       (101, 'ΒΟΣΝΙΑ-ΕΡΖΕΓΟΒΙΝΗ', 1, 1, 'Initialization'),
       (102, 'ΛΕΥΚΟΡΩΣΙΑ', 1, 1, 'Initialization'),
       (103, 'ΜΠΕΛΙΖ', 1, 1, 'Initialization'),
       (104, 'ΒΕΡΜΟΥΔΕΣ', 1, 1, 'Initialization'),
       (105, 'ΒΟΛΙΒΙΑ', 1, 1, 'Initialization'),
       (106, 'ΒΡΑΖΙΛΙΑ', 1, 1, 'Initialization'),
       (107, 'ΜΠΑΡΜΠΑΝΤΟΣ', 1, 1, 'Initialization'),
       (108, 'ΜΠΡΟΥΝΕΙ', 1, 1, 'Initialization'),
       (109, 'ΜΠΟΥΤΑΝ', 1, 1, 'Initialization'),
       (110, 'ΒΙΡΜΑΝΙΑ (ΜΙΑΝΜΑΡ)', 1, 1, 'Initialization'),
       (111, 'ΜΠΟΤΣΟΥΑΝΑ', 1, 1, 'Initialization'),
       (112, 'ΔΗΜΟΚΡΑΤΙΑ ΚΕΝΤΡΙΚΗΣ ΑΦΡΙΚΗΣ', 1, 1, 'Initialization'),
       (113, 'ΚΑΝΑΔΑΣ', 1, 1, 'Initialization'),
       (114, 'ΕΛΒΕΤΙΑ', 1, 1, 'Initialization'),
       (115, 'ΧΙΛΗ', 1, 1, 'Initialization'),
       (116, 'ΚΙΝΑ', 1, 1, 'Initialization'),
       (117, 'ΑΚΤΗ ΕΛΕΦΑΝΤΟΣΤΟΥ', 1, 1, 'Initialization'),
       (118, 'ΚΑΜΕΡΟΥΝ', 1, 1, 'Initialization'),
       (119, 'ΚΟΝΓΚΟ', 1, 1, 'Initialization'),
       (120, 'ΝΗΣΙΑ ΚΟΥΚ', 1, 1, 'Initialization'),
       (121, 'ΚΟΛΟΜΒΙΑ', 1, 1, 'Initialization'),
       (122, 'ΚΟΜΟΡΕΣ', 1, 1, 'Initialization'),
       (123, 'ΠΡΑΣΙΝΟ ΑΚΡΩΤΗΡΙ', 1, 1, 'Initialization'),
       (124, 'ΚΟΣΤΑ ΡΙΚΑ', 1, 1, 'Initialization'),
       (125, 'ΚΟΥΒΑ', 1, 1, 'Initialization'),
       (126, 'ΝΗΣΙΑ ΚΑΙΜΑΝ', 1, 1, 'Initialization'),
       (127, 'ΚΥΠΡΟΣ', 1, 1, 'Initialization'),
       (128, 'ΤΣΕΧΙΑ', 1, 1, 'Initialization'),
       (129, 'ΓΕΡΜΑΝΙΑ', 1, 1, 'Initialization'),
       (130, 'ΤΖΙΜΠΟΥΤΙ', 1, 1, 'Initialization'),
       (131, 'ΔΑΝΙΑ', 1, 1, 'Initialization'),
       (132, 'ΔΟΜΙΝΙΚΑΝΗ ΔΗΜΟΚΡΑΤΙΑ', 1, 1, 'Initialization'),
       (133, 'ΑΛΓΕΡΙΑ', 1, 1, 'Initialization'),
       (134, 'ΙΣΗΜΕΡΙΝΟΣ (ΕΚΟΥΑΔΟΡ)', 1, 1, 'Initialization'),
       (135, 'ΑΙΓΥΠΤΟΣ', 1, 1, 'Initialization'),
       (136, 'ΕΡΥΘΡΑΙΑ', 1, 1, 'Initialization'),
       (137, 'ΙΣΠΑΝΙΑ', 1, 1, 'Initialization'),
       (138, 'ΕΣΘΟΝΙΑ', 1, 1, 'Initialization'),
       (139, 'ΑΙΘΙΟΠΙΑ', 1, 1, 'Initialization'),
       (140, 'ΦΙΝΛΑΝΔΙΑ', 1, 1, 'Initialization'),
       (141, 'ΦΙΤΖΙ', 1, 1, 'Initialization'),
       (142, 'ΝΗΣΙΑ ΦΩΚΛΑΝΤ', 1, 1, 'Initialization'),
       (143, 'ΓΑΛΛΙΑ', 1, 1, 'Initialization'),
       (144, 'ΓΚΑΜΠΟΝ', 1, 1, 'Initialization'),
       (145, 'ΗΝΩΜΕΝΟ ΒΑΣΙΛΕΙΟ', 1, 1, 'Initialization'),
       (146, 'ΓΕΩΡΓΙΑ', 1, 1, 'Initialization'),
       (147, 'ΓΚΑΝΑ', 1, 1, 'Initialization'),
       (148, 'ΓΙΒΡΑΛΤΑΡ', 1, 1, 'Initialization'),
       (149, 'ΓΟΥΙΝΕΑ', 1, 1, 'Initialization'),
       (150, 'ΓΚΑΜΠΙΑ', 1, 1, 'Initialization'),
       (151, 'ΓΟΥΙΝΕΑ ΜΠΙΣΑΟΥ', 1, 1, 'Initialization'),
       (152, 'ΙΣΗΜΕΡΙΝΗ ΓΟΥΙΝΕΑ', 1, 1, 'Initialization'),
       (153, 'ΓΡΕΝΑΔΑ', 1, 1, 'Initialization'),
       (154, 'ΕΛΛΑΔΑ', 1, 1, 'Initialization'),
       (155, 'ΓΟΥΑΤΕΜΑΛΑ', 1, 1, 'Initialization'),
       (156, 'ΓΟΥΙΑΝΑ', 1, 1, 'Initialization'),
       (157, 'ΧΟΝΓΚ-ΚΟΝΓΚ', 1, 1, 'Initialization'),
       (158, 'ΟΝΔΟΥΡΑ', 1, 1, 'Initialization'),
       (159, 'ΚΡΟΑΤΙΑ', 1, 1, 'Initialization'),
       (160, 'ΑΙΤΗ', 1, 1, 'Initialization'),
       (161, 'ΟΥΓΓΑΡΙΑ', 1, 1, 'Initialization'),
       (162, 'ΙΝΔΟΝΗΣΙΑ', 1, 1, 'Initialization'),
       (163, 'ΙΝΔΙΑ', 1, 1, 'Initialization'),
       (164, 'ΙΡΛΑΝΔΙΑ', 1, 1, 'Initialization'),
       (165, 'ΙΡΑΝ', 1, 1, 'Initialization'),
       (166, 'ΙΡΑΚ', 1, 1, 'Initialization'),
       (167, 'ΙΣΛΑΝΔΙΑ', 1, 1, 'Initialization'),
       (168, 'ΙΣΡΑΗΛ', 1, 1, 'Initialization'),
       (169, 'ΙΤΑΛΙΑ', 1, 1, 'Initialization'),
       (170, 'ΤΖΑΜΑΙΚΑ', 1, 1, 'Initialization'),
       (171, 'ΙΟΡΔΑΝΙΑ', 1, 1, 'Initialization'),
       (172, 'ΙΑΠΩΝΙΑ', 1, 1, 'Initialization'),
       (173, 'ΚΑΖΑΚΣΤΑΝ', 1, 1, 'Initialization'),
       (174, 'ΚΕΝΥΑ', 1, 1, 'Initialization'),
       (175, 'ΚΥΡΤΖΙΣΤΑΝ', 1, 1, 'Initialization'),
       (176, 'ΚΑΜΠΟΤΖΗ', 1, 1, 'Initialization'),
       (177, 'ΚΙΡΙΜΠΑΤΙ', 1, 1, 'Initialization'),
       (178, 'ΑΓΙΟΣ ΧΡΙΣΤΟΦΟΡΟΣ ΚΑΙ ΝΕΒΙΣ', 1, 1, 'Initialization'),
       (179, 'ΝΟΤΙΑ ΚΟΡΕΑ', 1, 1, 'Initialization'),
       (180, 'ΚΟΥΒΕΙΤ', 1, 1, 'Initialization'),
       (181, 'ΛΑΟΣ', 1, 1, 'Initialization'),
       (182, 'ΛΙΒΑΝΟΣ', 1, 1, 'Initialization'),
       (183, 'ΛΙΒΕΡΙΑ', 1, 1, 'Initialization'),
       (184, 'ΛΙΒΥΗ', 1, 1, 'Initialization'),
       (185, 'ΑΓΙΑ ΛΟΥΚΙΑ', 1, 1, 'Initialization'),
       (186, 'ΛΙΧΤΕΝΣΤΑΙΝ', 1, 1, 'Initialization'),
       (187, 'ΣΡΙ ΛΑΝΚΑ', 1, 1, 'Initialization'),
       (188, 'ΛΕΣΟΘΟ', 1, 1, 'Initialization'),
       (189, 'ΛΙΘΟΥΑΝΙΑ', 1, 1, 'Initialization'),
       (190, 'ΛΟΥΞΕΜΒΟΥΡΓΟ', 1, 1, 'Initialization'),
       (191, 'ΛΕΤΟΝΙΑ', 1, 1, 'Initialization'),
       (192, 'ΜΑΚΑΟ', 1, 1, 'Initialization'),
       (193, 'ΜΑΡΟΚΟ', 1, 1, 'Initialization'),
       (194, 'ΜΟΝΑΚΟ', 1, 1, 'Initialization'),
       (195, 'ΜΟΛΔΑΒΙΑ', 1, 1, 'Initialization'),
       (196, 'ΜΑΔΑΓΑΣΚΑΡΗ', 1, 1, 'Initialization'),
       (197, 'ΜΑΛΒΙΔΕΣ', 1, 1, 'Initialization'),
       (198, 'ΜΕΞΙΚΟ', 1, 1, 'Initialization'),
       (199, 'ΝΗΣΙΑ ΜΑΡΣΑΛΛ', 1, 1, 'Initialization'),
       (200, 'ΜΑΛΙ', 1, 1, 'Initialization'),
       (201, 'ΜΑΛΤΑ', 1, 1, 'Initialization'),
       (202, 'ΜΥΑΝΜΑΡ', 1, 1, 'Initialization'),
       (203, 'ΜΟΓΓΟΛΙΑ', 1, 1, 'Initialization'),
       (204, 'ΝΗΣΙΑ ΒΟΡΕΙΕΣ ΜΑΡΙΑΝΕΣ', 1, 1, 'Initialization'),
       (205, 'ΜΟΖΑΜΒΙΚΗ', 1, 1, 'Initialization'),
       (206, 'ΜΑΥΡΙΤΑΝΙΑ', 1, 1, 'Initialization'),
       (207, 'ΜΑΥΡΙΚΙΟΣ', 1, 1, 'Initialization'),
       (208, 'ΜΑΛΑΟΥΙ', 1, 1, 'Initialization'),
       (209, 'ΜΑΛΑΙΣΙΑ', 1, 1, 'Initialization'),
       (210, 'ΝΑΜΙΜΠΙΑ', 1, 1, 'Initialization'),
       (211, 'Άγιος Βαρθολομαίος', 1, 1, 'Initialization'),
       (212, 'Άγιος Μαρτίνος (Γαλλία)', 1, 1, 'Initialization'),
       (213, 'Άγιος Μαρτίνος (Ολλανδία)', 1, 1, 'Initialization'),
       (214, 'Άγιος Μαρίνος', 1, 1, 'Initialization'),
       (215, 'Σαιν Πιερ και Μικελόν', 1, 1, 'Initialization'),
       (216, 'Ανταρκτική', 1, 1, 'Initialization'),
       (217, 'Βρετανικό Έδαφος Ινδικού Ωκεανού', 1, 1, 'Initialization'),
       (218, 'Γαλλική Γουιάνα', 1, 1, 'Initialization'),
       (219, 'Γκέρνσεϊ', 1, 1, 'Initialization'),
       (220, 'Γκουάμ', 1, 1, 'Initialization'),
       (221, 'Γουαδελούπη', 1, 1, 'Initialization'),
       (222, 'Γροιλανδία', 1, 1, 'Initialization'),
       (223, 'ΠΑΛΑΙΣΤΙΝΗ', 1, 1, 'Initialization'),
       (224, 'Δυτική Σαχάρα', 1, 1, 'Initialization'),
       (225, 'Κουρασάο', 1, 1, 'Initialization'),
       (226, 'Λαϊκή Δημοκρατία του Κογκό', 1, 1, 'Initialization'),
       (227, 'Μαγιότ', 1, 1, 'Initialization'),
       (228, 'Μαρτινίκα', 1, 1, 'Initialization'),
       (229, 'Μαυροβούνιο', 1, 1, 'Initialization'),
       (230, 'Μοντσερράτ', 1, 1, 'Initialization'),
       (231, 'Μποναίρ, Άγιος Ευστάθιος και Σάμπα', 1, 1, 'Initialization'),
       (232, 'Νέα Καληδονία', 1, 1, 'Initialization'),
       (233, 'Νησί Νόρφολκ', 1, 1, 'Initialization'),
       (234, 'Νήσος των Χριστουγέννων', 1, 1, 'Initialization'),
       (235, 'Νησιά Κόκος (Keeling)', 1, 1, 'Initialization'),
       (236, 'Ώλαντ', 1, 1, 'Initialization'),
       (237, 'Νησιά Πίτκερν', 1, 1, 'Initialization'),
       (238, 'Νήσοι Φερόες', 1, 1, 'Initialization'),
       (239, 'Νήσος Μαν', 1, 1, 'Initialization'),
       (240, 'Νήσοι Χερντ και Μακντόναλντ', 1, 1, 'Initialization'),
       (241, 'Νίγηρας', 1, 1, 'Initialization'),
       (242, 'Νιούε', 1, 1, 'Initialization'),
       (243, 'Νήσοι Νότια Γεωργία και Νότιες Σάντουιτς', 1, 1, 'Initialization'),
       (244, 'Νότιο Σουδάν', 1, 1, 'Initialization'),
       (245, 'Δομινίκα', 1, 1, 'Initialization'),
       (246, 'Ομόσπονδες Πολιτείες της Μικρονησίας', 1, 1, 'Initialization'),
       (247, 'Ουαλίς και Φουτουνά', 1, 1, 'Initialization'),
       (248, 'Παλάου', 1, 1, 'Initialization'),
       (249, 'Πουέρτο Ρίκο', 1, 1, 'Initialization'),
       (250, 'Ρεϊνιόν', 1, 1, 'Initialization'),
       (251, 'Σβάλμπαρντ', 1, 1, 'Initialization'),
       (252, 'Σερβία', 1, 1, 'Initialization'),
       (253, 'Τζέρσεϊ', 1, 1, 'Initialization'),
       (254, 'Τοκελάου', 1, 1, 'Initialization'),
       (1, 'NIGERIA', 2, 1, 'Initialization'),
       (2, 'NICARAGUA', 2, 1, 'Initialization'),
       (3, 'NETHERLANDS', 2, 1, 'Initialization'),
       (4, 'NORWAY', 2, 1, 'Initialization'),
       (5, 'NEPAL', 2, 1, 'Initialization'),
       (6, 'NAURU', 2, 1, 'Initialization'),
       (7, 'NEW ZEALAND', 2, 1, 'Initialization'),
       (8, 'OMAN', 2, 1, 'Initialization'),
       (9, 'OCEANIA-NEW ZEALANDIA', 2, 1, 'Initialization'),
       (10, 'PAKISTAN', 2, 1, 'Initialization'),
       (11, 'PANAMA', 2, 1, 'Initialization'),
       (12, 'PERU', 2, 1, 'Initialization'),
       (13, 'PHILIPPINES', 2, 1, 'Initialization'),
       (14, 'PAPUA-NEA GUINEA', 2, 1, 'Initialization'),
       (15, 'POLAND', 2, 1, 'Initialization'),
       (16, 'NORTH KOREA', 2, 1, 'Initialization'),
       (17, 'PORTUGAL', 2, 1, 'Initialization'),
       (18, 'PARAGUAY', 2, 1, 'Initialization'),
       (19, 'FRENCH POLYNESIA', 2, 1, 'Initialization'),
       (20, 'CATTAR', 2, 1, 'Initialization'),
       (21, 'ROMANIA', 2, 1, 'Initialization'),
       (22, 'RUSSIA', 2, 1, 'Initialization'),
       (23, 'ROYADA', 2, 1, 'Initialization'),
       (24, 'SAUDI ARABIA', 2, 1, 'Initialization'),
       (25, 'SWEDISH', 2, 1, 'Initialization'),
       (26, 'SENEGALI', 2, 1, 'Initialization'),
       (27, 'SINGAPORE', 2, 1, 'Initialization'),
       (28, 'SAINT HELEN', 2, 1, 'Initialization'),
       (29, 'SALMON ISLANDS', 2, 1, 'Initialization'),
       (30, 'SIERRA LEONE', 2, 1, 'Initialization'),
       (31, 'EL SALVADOR', 2, 1, 'Initialization'),
       (32, 'SOMALIA', 2, 1, 'Initialization'),
       (33, 'SANDO TOME AND BEFORE', 2, 1, 'Initialization'),
       (34, 'SURINAM', 2, 1, 'Initialization'),
       (35, 'SLOVAKIA', 2, 1, 'Initialization'),
       (36, 'SLOVENIA', 2, 1, 'Initialization'),
       (37, 'SWEDEN', 2, 1, 'Initialization'),
       (38, 'ZOUAZILAND', 2, 1, 'Initialization'),
       (39, 'SEXELES', 2, 1, 'Initialization'),
       (40, 'SYRIA', 2, 1, 'Initialization'),
       (41, 'TERKS AND ICOS ISLANDS', 2, 1, 'Initialization'),
       (42, 'CHANT', 2, 1, 'Initialization'),
       (43, 'TOGO', 2, 1, 'Initialization'),
       (44, 'TALAND', 2, 1, 'Initialization'),
       (45, 'TAJIKISTAN', 2, 1, 'Initialization'),
       (46, 'TURKMENISTAN', 2, 1, 'Initialization'),
       (47, 'EASTERN TIMOR', 2, 1, 'Initialization'),
       (48, 'TONGA', 2, 1, 'Initialization'),
       (49, 'TRINIDAD AND TOBAGO', 2, 1, 'Initialization'),
       (50, 'TUNISIA', 2, 1, 'Initialization'),
       (51, 'TURKEY', 2, 1, 'Initialization'),
       (52, 'TOBALOU', 2, 1, 'Initialization'),
       (53, 'TAIWAN', 2, 1, 'Initialization'),
       (54, 'TANZANIA', 2, 1, 'Initialization'),
       (55, 'HUNGARY', 2, 1, 'Initialization'),
       (56, 'HUNGARY', 2, 1, 'Initialization'),
       (57, 'SMALL ISLANDS OF THE UNITED STATES OF AMERICA', 2, 1, 'Initialization'),
       (58, 'ORIGIN', 2, 1, 'Initialization'),
       (59, 'Η.Π.Α.', 2, 1, 'Initialization'),
       (60, 'OUZBEKISTAN', 2, 1, 'Initialization'),
       (61, 'BATHQUAIN', 2, 1, 'Initialization'),
       (62, 'SAINT VINCENT', 2, 1, 'Initialization'),
       (63, 'VENEZUELA', 2, 1, 'Initialization'),
       (64, 'VIRGIN ISLANDS AND MONTSERRA', 2, 1, 'Initialization'),
       (65, 'VIRGIN ISLANDS OF THE UNITED STATES OF AMERICA', 2, 1, 'Initialization'),
       (66, 'VIETNAM', 2, 1, 'Initialization'),
       (67, 'VANUATOU', 2, 1, 'Initialization'),
       (68, 'SAMOA WEST', 2, 1, 'Initialization'),
       (69, 'EUROPEAN UNION', 2, 1, 'Initialization'),
       (70, 'YEMENI', 2, 1, 'Initialization'),
       (71, 'SERVIA AND BLACK MOUNTAIN', 2, 1, 'Initialization'),
       (72, 'REPUBLIC OF SOUTH AFRICA', 2, 1, 'Initialization'),
       (73, 'ZAIR', 2, 1, 'Initialization'),
       (74, 'ZAMBIA', 2, 1, 'Initialization'),
       (75, 'ZIMBABWE', 2, 1, 'Initialization'),
       (76, 'Π.Γ.Δ.Μ.', 2, 1, 'Initialization'),
       (77, 'ARUMBA', 2, 1, 'Initialization'),
       (78, 'AFGHANISTAN', 2, 1, 'Initialization'),
       (79, 'WILD', 2, 1, 'Initialization'),
       (80, 'ANGUILA', 2, 1, 'Initialization'),
       (81, 'ALBANIA', 2, 1, 'Initialization'),
       (82, 'ANDORRA', 2, 1, 'Initialization'),
       (83, 'DUTCH ANTILLES', 2, 1, 'Initialization'),
       (84, 'UNITED ARAB EMIRATES', 2, 1, 'Initialization'),
       (85, 'ARGENTINA', 2, 1, 'Initialization'),
       (86, 'ARMENIA', 2, 1, 'Initialization'),
       (87, 'SAMOA AMERICAN', 2, 1, 'Initialization'),
       (88, 'FRENCH SOUTHERN REGIONS', 2, 1, 'Initialization'),
       (89, 'ANTIGUA AND BARBUDA', 2, 1, 'Initialization'),
       (90, 'AUSTRALIA', 2, 1, 'Initialization'),
       (91, 'AUSTRIA', 2, 1, 'Initialization'),
       (92, 'AZERBAIJAN', 2, 1, 'Initialization'),
       (93, 'BURUNDI', 2, 1, 'Initialization'),
       (94, 'BELGIUM', 2, 1, 'Initialization'),
       (95, 'BENIN', 2, 1, 'Initialization'),
       (96, 'BURKINA FASO', 2, 1, 'Initialization'),
       (97, 'BAGLADES', 2, 1, 'Initialization'),
       (98, 'BULGARIA', 2, 1, 'Initialization'),
       (99, 'BAHRAIN', 2, 1, 'Initialization'),
       (100, 'BAHAMES', 2, 1, 'Initialization'),
       (101, 'BOSNIA-HERZEGOVINA', 2, 1, 'Initialization'),
       (102, 'LEYCOROSIA', 2, 1, 'Initialization'),
       (103, 'BELIZ', 2, 1, 'Initialization'),
       (104, 'BERMUDES', 2, 1, 'Initialization'),
       (105, 'BOLIVIA', 2, 1, 'Initialization'),
       (106, 'BRAZIL', 2, 1, 'Initialization'),
       (107, 'BARBADOS', 2, 1, 'Initialization'),
       (108, 'MORE', 2, 1, 'Initialization'),
       (109, 'BUTTAN', 2, 1, 'Initialization'),
       (110, 'BURMA (EINMAR)', 2, 1, 'Initialization'),
       (111, 'BOTSWANA', 2, 1, 'Initialization'),
       (112, 'REPUBLIC OF CENTRAL AFRICA', 2, 1, 'Initialization'),
       (113, 'CANADA', 2, 1, 'Initialization'),
       (114, 'SWITZERLAND', 2, 1, 'Initialization'),
       (115, 'CHILE', 2, 1, 'Initialization'),
       (116, 'CHINA', 2, 1, 'Initialization'),
       (117, 'IVORY COAST', 2, 1, 'Initialization'),
       (118, 'CAMEROON', 2, 1, 'Initialization'),
       (119, 'KONGO', 2, 1, 'Initialization'),
       (120, 'COOK ISLANDS', 2, 1, 'Initialization'),
       (121, 'COLOMBIA', 2, 1, 'Initialization'),
       (122, 'COMES', 2, 1, 'Initialization'),
       (123, 'GREEN CAPE', 2, 1, 'Initialization'),
       (124, 'COST OF RICA', 2, 1, 'Initialization'),
       (125, 'CUBA', 2, 1, 'Initialization'),
       (126, 'CAIMAN ISLANDS', 2, 1, 'Initialization'),
       (127, 'CYPRUS', 2, 1, 'Initialization'),
       (128, 'CZECH REPUBLIC', 2, 1, 'Initialization'),
       (129, 'GERMANY', 2, 1, 'Initialization'),
       (130, 'JIBOUTI', 2, 1, 'Initialization'),
       (131, 'DENMARK', 2, 1, 'Initialization'),
       (132, 'DOMINICAN REPUBLIC', 2, 1, 'Initialization'),
       (133, 'ALGERIA', 2, 1, 'Initialization'),
       (134, 'EQUATORIAL (ECUADOR)', 2, 1, 'Initialization'),
       (135, 'EGYPT', 2, 1, 'Initialization'),
       (136, 'ERYTHRAIA', 2, 1, 'Initialization'),
       (137, 'SPAIN', 2, 1, 'Initialization'),
       (138, 'ESTHONIA', 2, 1, 'Initialization'),
       (139, 'AITHOPIA', 2, 1, 'Initialization'),
       (140, 'FINLAND', 2, 1, 'Initialization'),
       (141, 'FITZI', 2, 1, 'Initialization'),
       (142, 'FOCALAND ISLANDS', 2, 1, 'Initialization'),
       (143, 'FRANCE', 2, 1, 'Initialization'),
       (144, 'GABON', 2, 1, 'Initialization'),
       (145, 'UNITED KINGDOM', 2, 1, 'Initialization'),
       (146, 'GEORGIA', 2, 1, 'Initialization'),
       (147, 'GANA', 2, 1, 'Initialization'),
       (148, 'YIVRALTAR', 2, 1, 'Initialization'),
       (149, 'WINE', 2, 1, 'Initialization'),
       (150, 'GABIA', 2, 1, 'Initialization'),
       (151, 'WINEA BISSAU', 2, 1, 'Initialization'),
       (152, 'EQUATORIAL GUINEA', 2, 1, 'Initialization'),
       (153, 'GREENADA', 2, 1, 'Initialization'),
       (154, 'GREECE', 2, 1, 'Initialization'),
       (155, 'WATTEMALA', 2, 1, 'Initialization'),
       (156, 'GUIANA', 2, 1, 'Initialization'),
       (157, 'HONG KONG-CONG', 2, 1, 'Initialization'),
       (158, 'ONDURA', 2, 1, 'Initialization'),
       (159, 'CROATIA', 2, 1, 'Initialization'),
       (160, 'AITI', 2, 1, 'Initialization'),
       (161, 'HUNGARY', 2, 1, 'Initialization'),
       (162, 'INDONESIA', 2, 1, 'Initialization'),
       (163, 'INDIA', 2, 1, 'Initialization'),
       (164, 'IRELAND', 2, 1, 'Initialization'),
       (165, 'IRAN', 2, 1, 'Initialization'),
       (166, 'IRAQ', 2, 1, 'Initialization'),
       (167, 'ICELAND', 2, 1, 'Initialization'),
       (168, 'ISRAEL', 2, 1, 'Initialization'),
       (169, 'ITALY', 2, 1, 'Initialization'),
       (170, 'JAMAICA', 2, 1, 'Initialization'),
       (171, 'JORDAN', 2, 1, 'Initialization'),
       (172, 'JAPAN', 2, 1, 'Initialization'),
       (173, 'CAZAKSTAN', 2, 1, 'Initialization'),
       (174, 'KENYA', 2, 1, 'Initialization'),
       (175, 'CURTZISTAN', 2, 1, 'Initialization'),
       (176, 'KABOTZI', 2, 1, 'Initialization'),
       (177, 'KIRIBATI', 2, 1, 'Initialization'),
       (178, 'SAINT CHRISTOPHORUS AND NEVIS', 2, 1, 'Initialization'),
       (179, 'SOUTH KOREA', 2, 1, 'Initialization'),
       (180, 'KUWAIT', 2, 1, 'Initialization'),
       (181, 'L.A.', 2, 1, 'Initialization'),
       (182, 'LIBANOS', 2, 1, 'Initialization'),
       (183, 'LIBERIA', 2, 1, 'Initialization'),
       (184, 'LIBYA', 2, 1, 'Initialization'),
       (185, 'HOLY LUKE', 2, 1, 'Initialization'),
       (186, 'LIHTENSTEIN', 2, 1, 'Initialization'),
       (187, 'SRI LANKA', 2, 1, 'Initialization'),
       (188, 'LESO', 2, 1, 'Initialization'),
       (189, 'LITHUANIA', 2, 1, 'Initialization'),
       (190, 'LUXEMBOURG', 2, 1, 'Initialization'),
       (191, 'LETONIA', 2, 1, 'Initialization'),
       (192, 'MACAO', 2, 1, 'Initialization'),
       (193, 'MAROCO', 2, 1, 'Initialization'),
       (194, 'MONACO', 2, 1, 'Initialization'),
       (195, 'MOLDOVA', 2, 1, 'Initialization'),
       (196, 'MADAGASKARI', 2, 1, 'Initialization'),
       (197, 'MALVIDES', 2, 1, 'Initialization'),
       (198, 'MEXICO', 2, 1, 'Initialization'),
       (199, 'MARSHALL ISLANDS', 2, 1, 'Initialization'),
       (200, 'MALI', 2, 1, 'Initialization'),
       (201, 'MALTA', 2, 1, 'Initialization'),
       (202, 'MYANMAR', 2, 1, 'Initialization'),
       (203, 'MOGOLIA', 2, 1, 'Initialization'),
       (204, 'ISLANDS NORTH MARIANA ISLANDS', 2, 1, 'Initialization'),
       (205, 'MOZAMBIQUE', 2, 1, 'Initialization'),
       (206, 'MYRITANIA', 2, 1, 'Initialization'),
       (207, 'MAYOR', 2, 1, 'Initialization'),
       (208, 'MALAWI', 2, 1, 'Initialization'),
       (209, 'MALAYSIA', 2, 1, 'Initialization'),
       (210, 'NAMIBIA', 2, 1, 'Initialization'),
       (211, 'Saint Bartholomew', 2, 1, 'Initialization'),
       (212, 'Saint Martin (France)', 2, 1, 'Initialization'),
       (213, 'Saint Martin (Netherlands)', 2, 1, 'Initialization'),
       (214, 'Saint Marinos', 2, 1, 'Initialization'),
       (215, 'Saint Pierre and Miquelon', 2, 1, 'Initialization'),
       (216, 'Antarctica', 2, 1, 'Initialization'),
       (217, 'British Indian Ocean Territory', 2, 1, 'Initialization'),
       (218, 'French Guiana', 2, 1, 'Initialization'),
       (219, 'Guernsey', 2, 1, 'Initialization'),
       (220, 'Guam', 2, 1, 'Initialization'),
       (221, 'Guadeloupe', 2, 1, 'Initialization'),
       (222, 'Greenland', 2, 1, 'Initialization'),
       (223, 'PALESTINE', 2, 1, 'Initialization'),
       (224, 'Western Sahara', 2, 1, 'Initialization'),
       (225, 'Curacao', 2, 1, 'Initialization'),
       (226, 'Democratic Republic of the Congo', 2, 1, 'Initialization'),
       (227, 'Mayotte', 2, 1, 'Initialization'),
       (228, 'Martinique', 2, 1, 'Initialization'),
       (229, 'Montenegro', 2, 1, 'Initialization'),
       (230, 'Montserrat', 2, 1, 'Initialization'),
       (231, 'Bonaire, St Eustatius and Samba', 2, 1, 'Initialization'),
       (232, 'New Caledonia', 2, 1, 'Initialization'),
       (233, 'Norfolk Island', 2, 1, 'Initialization'),
       (234, 'Christmas Island', 2, 1, 'Initialization'),
       (235, 'Cocos Islands (Keeling)', 2, 1, 'Initialization'),
       (236, 'Aaland', 2, 1, 'Initialization'),
       (237, 'Pitcairn Islands', 2, 1, 'Initialization'),
       (238, 'Faroe Islands', 2, 1, 'Initialization'),
       (239, 'Isle of Man', 2, 1, 'Initialization'),
       (240, 'Herd and MacDonald Islands', 2, 1, 'Initialization'),
       (241, 'Niger', 2, 1, 'Initialization'),
       (242, 'Newe', 2, 1, 'Initialization'),
       (243, 'South Georgia and South Sandwich Islands', 2, 1, 'Initialization'),
       (244, 'South Sudan', 2, 1, 'Initialization'),
       (245, 'Dominica', 2, 1, 'Initialization'),
       (246, 'Federated States of Micronesia', 2, 1, 'Initialization'),
       (247, 'Welsh and Futuna', 2, 1, 'Initialization'),
       (248, 'Palau', 2, 1, 'Initialization'),
       (249, 'Puerto Rico', 2, 1, 'Initialization'),
       (250, 'Reunion', 2, 1, 'Initialization'),
       (251, 'Svalbard', 2, 1, 'Initialization'),
       (252, 'Serbia', 2, 1, 'Initialization'),
       (253, 'Jersey', 2, 1, 'Initialization'),
       (254, 'Tokelau', 2, 1, 'Initialization');

-- Insert base company_statuses records
INSERT INTO company_statuses (last_user_id, change_reason)
WITH RECURSIVE cnt(n) AS (SELECT 1
                          UNION ALL
                          SELECT n + 1
                          FROM cnt
                          WHERE n < 13)
SELECT 1, 'Initialization'
FROM cnt;

-- Insert company_statuses translations
INSERT INTO company_statusesI18n (company_status_id, description, language_id, last_user_id, change_reason)
VALUES (1, 'Άλλο', 1, 1, 'Initialization'),
       (1, 'Other', 2, 1, 'Initialization'),
       (2, 'Προεγγραφή', 1, 1, 'Initialization'),
       (2, 'Pre-registration', 2, 1, 'Initialization'),
       (3, 'Ενεργή', 1, 1, 'Initialization'),
       (3, 'Active', 2, 1, 'Initialization'),
       (4, 'Σε Αδράνεια', 1, 1, 'Initialization'),
       (4, 'In Inactivity', 2, 1, 'Initialization'),
       (5, 'Πτώχευση', 1, 1, 'Initialization'),
       (5, 'Bankruptcy', 2, 1, 'Initialization'),
       (6, 'Λύση - Εκκαθάριση', 1, 1, 'Initialization'),
       (6, 'Solution - Clearance', 2, 1, 'Initialization'),
       (7, 'Υπό εκκαθάριση', 1, 1, 'Initialization'),
       (7, 'Under clearance', 2, 1, 'Initialization'),
       (8, 'Διαδικασία Συνδιαλλαγής', 1, 1, 'Initialization'),
       (8, 'Conciliation procedure', 2, 1, 'Initialization'),
       (9, 'Διαγραφή', 1, 1, 'Initialization'),
       (9, 'Delete', 2, 1, 'Initialization'),
       (10, 'Διαγραφή λόγω συγχώνευσης', 1, 1, 'Initialization'),
       (10, 'Deletion due to merger', 2, 1, 'Initialization'),
       (11, 'Αναγκαστική διαχείριση', 1, 1, 'Initialization'),
       (11, 'Forced management', 2, 1, 'Initialization'),
       (12, 'Διαγραφή λόγω διάσπασης', 1, 1, 'Initialization'),
       (12, 'Deletion due to division', 2, 1, 'Initialization'),
       (13, 'Αναστολή καταχώρησης', 1, 1, 'Initialization'),
       (13, 'Suspension of entry', 2, 1, 'Initialization');

-- Insert base region records
INSERT INTO regions (last_user_id, change_reason)
WITH RECURSIVE cnt(n) AS (SELECT 1
                          UNION ALL
                          SELECT n + 1
                          FROM cnt
                          WHERE n < 13)
SELECT 1, 'Initialization'
FROM cnt;

-- Insert region translations
INSERT INTO regionsI18n (region_id, description, language_id, last_user_id, change_reason)
VALUES (1, 'Ανατολική Μακεδονία και Θράκη', 1, 1, 'Initialization'),
       (2, 'Κεντρική Μακεδονία', 1, 1, 'Initialization'),
       (3, 'Δυτική Μακεδονία', 1, 1, 'Initialization'),
       (4, 'Ήπειρος', 1, 1, 'Initialization'),
       (5, 'Θεσσαλία', 1, 1, 'Initialization'),
       (6, 'Ιόνιοι Νήσοι', 1, 1, 'Initialization'),
       (7, 'Δυτική Ελλάδα', 1, 1, 'Initialization'),
       (8, 'Στερεά Ελλάδα', 1, 1, 'Initialization'),
       (9, 'Αττική', 1, 1, 'Initialization'),
       (10, 'Πελοπόννησος', 1, 1, 'Initialization'),
       (11, 'Βόρειο Αιγαίο', 1, 1, 'Initialization'),
       (12, 'Νότιο Αιγαίο', 1, 1, 'Initialization'),
       (13, 'Κρήτη', 1, 1, 'Initialization'),
       (1, 'Eastern Macedonia and Thrace', 2, 1, 'Initialization'),
       (2, 'Central Macedonia', 2, 1, 'Initialization'),
       (3, 'Western Macedonia', 2, 1, 'Initialization'),
       (4, 'Epirus', 2, 1, 'Initialization'),
       (5, 'Thessaly', 2, 1, 'Initialization'),
       (6, 'Ionian Islands', 2, 1, 'Initialization'),
       (7, 'Western Greece', 2, 1, 'Initialization'),
       (8, 'Central Greece', 2, 1, 'Initialization'),
       (9, 'Attica', 2, 1, 'Initialization'),
       (10, 'Peloponnese', 2, 1, 'Initialization'),
       (11, 'North Aegean Sea', 2, 1, 'Initialization'),
       (12, 'South Aegean Sea', 2, 1, 'Initialization'),
       (13, 'Crete', 2, 1, 'Initialization');

-- Insert base prefecture records with their region associations
INSERT INTO prefectures (region_id, last_user_id, change_reason)
VALUES (8, 1, 'Initialization'),  -- 1: ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ
       (10, 1, 'Initialization'), -- 2: ΑΡΓΟΛΙΔΑΣ
       (10, 1, 'Initialization'), -- 3: ΑΡΚΑΔΙΑΣ
       (4, 1, 'Initialization'),  -- 4: ΑΡΤΑΣ
       (9, 1, 'Initialization'),  -- 5: ΑΤΤΙΚΗΣ
       (7, 1, 'Initialization'),  -- 6: ΑΧΑΙΑΣ
       (8, 1, 'Initialization'),  -- 7: ΒΟΙΩΤΙΑΣ
       (3, 1, 'Initialization'),  -- 8: ΓΡΕΒΕΝΩΝ
       (1, 1, 'Initialization'),  -- 9: ΔΡΑΜΑΣ
       (12, 1, 'Initialization'), -- 10: ΔΩΔΕΚΑΝΗΣΟΥ
       (1, 1, 'Initialization'),  -- 11: ΕΒΡΟΥ
       (8, 1, 'Initialization'),  -- 12: ΕΥΒΟΙΑΣ
       (8, 1, 'Initialization'),  -- 13: ΕΥΡΥΤΑΝΙΑΣ
       (6, 1, 'Initialization'),  -- 14: ΖΑΚΥΝΘΟΥ
       (7, 1, 'Initialization'),  -- 15: ΗΛΕΙΑΣ
       (2, 1, 'Initialization'),  -- 16: ΗΜΑΘΙΑΣ
       (13, 1, 'Initialization'), -- 17: ΗΡΑΚΛΕΙΟΥ
       (4, 1, 'Initialization'),  -- 18: ΘΕΣΠΡΩΤΙΑΣ
       (2, 1, 'Initialization'),  -- 19: ΘΕΣΣΑΛΟΝΙΚΗΣ
       (4, 1, 'Initialization'),  -- 20: ΙΩΑΝΝΙΝΩΝ
       (1, 1, 'Initialization'),  -- 21: ΚΑΒΑΛΑΣ
       (5, 1, 'Initialization'),  -- 22: ΚΑΡΔΙΤΣΑΣ
       (3, 1, 'Initialization'),  -- 23: ΚΑΣΤΟΡΙΑΣ
       (6, 1, 'Initialization'),  -- 24: ΚΕΡΚΥΡΑΣ
       (6, 1, 'Initialization'),  -- 25: ΚΕΦΑΛΛΗΝΙΑΣ
       (2, 1, 'Initialization'),  -- 26: ΚΙΛΚΙΣ
       (3, 1, 'Initialization'),  -- 27: ΚΟΖΑΝΗΣ
       (10, 1, 'Initialization'), -- 28: ΚΟΡΙΝΘΙΑΣ
       (12, 1, 'Initialization'), -- 29: ΚΥΚΛΑΔΩΝ
       (10, 1, 'Initialization'), -- 30: ΛΑΚΩΝΙΑΣ
       (5, 1, 'Initialization'),  -- 31: ΛΑΡΙΣΑΣ
       (13, 1, 'Initialization'), -- 32: ΛΑΣΙΘΙΟΥ
       (11, 1, 'Initialization'), -- 33: ΛΕΣΒΟΥ
       (6, 1, 'Initialization'),  -- 34: ΛΕΥΚΑΔΑΣ
       (5, 1, 'Initialization'),  -- 35: ΜΑΓΝΗΣΙΑΣ
       (10, 1, 'Initialization'), -- 36: ΜΕΣΣΗΝΙΑΣ
       (1, 1, 'Initialization'),  -- 37: ΞΑΝΘΗΣ
       (2, 1, 'Initialization'),  -- 38: ΠΕΛΛΗΣ
       (2, 1, 'Initialization'),  -- 39: ΠΙΕΡΙΑΣ
       (4, 1, 'Initialization'),  -- 40: ΠΡΕΒΕΖΑΣ
       (13, 1, 'Initialization'), -- 41: ΡΕΘΥΜΝΗΣ
       (1, 1, 'Initialization'),  -- 42: ΡΟΔΟΠΗΣ
       (11, 1, 'Initialization'), -- 43: ΣΑΜΟΥ
       (2, 1, 'Initialization'),  -- 44: ΣΕΡΡΩΝ
       (5, 1, 'Initialization'),  -- 45: ΤΡΙΚΑΛΩΝ
       (8, 1, 'Initialization'),  -- 46: ΦΘΙΩΤΙΔΑΣ
       (3, 1, 'Initialization'),  -- 47: ΦΛΩΡΙΝΑΣ
       (8, 1, 'Initialization'),  -- 48: ΦΩΚΙΔΑΣ
       (2, 1, 'Initialization'),  -- 49: ΧΑΛΚΙΔΙΚΗΣ
       (13, 1, 'Initialization'), -- 50: ΧΑΝΙΩΝ
       (11, 1, 'Initialization'), -- 51: ΧΙΟΥ
       (9, 1, 'Initialization'),  -- 52: ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ
       (9, 1, 'Initialization'),  -- 53: ΔΥΤΙΚΗΣ ΑΤΤΙΚΗΣ
       (9, 1, 'Initialization'),  -- 54: ΑΘΗΝΩΝ
       (9, 1, 'Initialization');
-- 55: ΠΕΙΡΑΙΑ

-- Insert prefecture translations
INSERT INTO prefecturesI18n (prefecture_id, description, language_id, last_user_id, change_reason)
VALUES (1, 'ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ', 1, 1, 'Initialization'),
       (1, 'ETOLOAKARNANIA', 2, 1, 'Initialization'),
       (2, 'ΑΡΓΟΛΙΔΑΣ', 1, 1, 'Initialization'),
       (2, 'ARGOLIDA', 2, 1, 'Initialization'),
       (3, 'ΑΡΚΑΔΙΑΣ', 1, 1, 'Initialization'),
       (3, 'ARKADIA', 2, 1, 'Initialization'),
       (4, 'ΑΡΤΑΣ', 1, 1, 'Initialization'),
       (4, 'ARTA', 2, 1, 'Initialization'),
       (5, 'ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (5, 'ATTICA', 2, 1, 'Initialization'),
       (6, 'ΑΧΑΙΑΣ', 1, 1, 'Initialization'),
       (6, 'ACHAIA', 2, 1, 'Initialization'),
       (7, 'ΒΟΙΩΤΙΑΣ', 1, 1, 'Initialization'),
       (7, 'VIOTIA', 2, 1, 'Initialization'),
       (8, 'ΓΡΕΒΕΝΩΝ', 1, 1, 'Initialization'),
       (8, 'GREVENA', 2, 1, 'Initialization'),
       (9, 'ΔΡΑΜΑΣ', 1, 1, 'Initialization'),
       (9, 'DRAMA', 2, 1, 'Initialization'),
       (10, 'ΔΩΔΕΚΑΝΗΣΟΥ', 1, 1, 'Initialization'),
       (10, 'DODECANESE', 2, 1, 'Initialization'),
       (11, 'ΕΒΡΟΥ', 1, 1, 'Initialization'),
       (11, 'EVROU', 2, 1, 'Initialization'),
       (12, 'ΕΥΒΟΙΑΣ', 1, 1, 'Initialization'),
       (12, 'EVVIA', 2, 1, 'Initialization'),
       (13, 'ΕΥΡΥΤΑΝΙΑΣ', 1, 1, 'Initialization'),
       (13, 'EURITANIA', 2, 1, 'Initialization'),
       (14, 'ΖΑΚΥΝΘΟΥ', 1, 1, 'Initialization'),
       (14, 'ZAKINTHOS', 2, 1, 'Initialization'),
       (15, 'ΗΛΕΙΑΣ', 1, 1, 'Initialization'),
       (15, 'ILEIA', 2, 1, 'Initialization'),
       (16, 'ΗΜΑΘΙΑΣ', 1, 1, 'Initialization'),
       (16, 'IMATHIA', 2, 1, 'Initialization'),
       (17, 'ΗΡΑΚΛΕΙΟΥ', 1, 1, 'Initialization'),
       (17, 'HERAKLION', 2, 1, 'Initialization'),
       (18, 'ΘΕΣΠΡΩΤΙΑΣ', 1, 1, 'Initialization'),
       (18, 'THESPROTIA', 2, 1, 'Initialization'),
       (19, 'ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (19, 'THESSALONIKI', 2, 1, 'Initialization'),
       (20, 'ΙΩΑΝΝΙΝΩΝ', 1, 1, 'Initialization'),
       (20, 'IOANNINA', 2, 1, 'Initialization'),
       (21, 'ΚΑΒΑΛΑΣ', 1, 1, 'Initialization'),
       (21, 'KAVALA', 2, 1, 'Initialization'),
       (22, 'ΚΑΡΔΙΤΣΑΣ', 1, 1, 'Initialization'),
       (22, 'KARDITSA', 2, 1, 'Initialization'),
       (23, 'ΚΑΣΤΟΡΙΑΣ', 1, 1, 'Initialization'),
       (23, 'KASTORIA', 2, 1, 'Initialization'),
       (24, 'ΚΕΡΚΥΡΑΣ', 1, 1, 'Initialization'),
       (24, 'KERKIRA', 2, 1, 'Initialization'),
       (25, 'ΚΕΦΑΛΛΗΝΙΑΣ', 1, 1, 'Initialization'),
       (25, 'KEFALLINIA', 2, 1, 'Initialization'),
       (26, 'ΚΙΛΚΙΣ', 1, 1, 'Initialization'),
       (26, 'KILKIS', 2, 1, 'Initialization'),
       (27, 'ΚΟΖΑΝΗΣ', 1, 1, 'Initialization'),
       (27, 'KOZANI', 2, 1, 'Initialization'),
       (28, 'ΚΟΡΙΝΘΙΑΣ', 1, 1, 'Initialization'),
       (28, 'KORINTHIA', 2, 1, 'Initialization'),
       (29, 'ΚΥΚΛΑΔΩΝ', 1, 1, 'Initialization'),
       (29, 'CYCLADES', 2, 1, 'Initialization'),
       (30, 'ΛΑΚΩΝΙΑΣ', 1, 1, 'Initialization'),
       (30, 'LAKONIA', 2, 1, 'Initialization'),
       (31, 'ΛΑΡΙΣΑΣ', 1, 1, 'Initialization'),
       (31, 'LARISA', 2, 1, 'Initialization'),
       (32, 'ΛΑΣΙΘΙΟΥ', 1, 1, 'Initialization'),
       (32, 'LASITHI', 2, 1, 'Initialization'),
       (33, 'ΛΕΣΒΟΥ', 1, 1, 'Initialization'),
       (33, 'LESVOS', 2, 1, 'Initialization'),
       (34, 'ΛΕΥΚΑΔΑΣ', 1, 1, 'Initialization'),
       (34, 'LEFKADA', 2, 1, 'Initialization'),
       (35, 'ΜΑΓΝΗΣΙΑΣ', 1, 1, 'Initialization'),
       (35, 'MAGNESIA', 2, 1, 'Initialization'),
       (36, 'ΜΕΣΣΗΝΙΑΣ', 1, 1, 'Initialization'),
       (36, 'MESSINIA', 2, 1, 'Initialization'),
       (37, 'ΞΑΝΘΗΣ', 1, 1, 'Initialization'),
       (37, 'XANTHI', 2, 1, 'Initialization'),
       (38, 'ΠΕΛΛΗΣ', 1, 1, 'Initialization'),
       (38, 'PELLA', 2, 1, 'Initialization'),
       (39, 'ΠΙΕΡΙΑΣ', 1, 1, 'Initialization'),
       (39, 'PIERIA', 2, 1, 'Initialization'),
       (40, 'ΠΡΕΒΕΖΑΣ', 1, 1, 'Initialization'),
       (40, 'PREVEZA', 2, 1, 'Initialization'),
       (41, 'ΡΕΘΥΜΝΗΣ', 1, 1, 'Initialization'),
       (41, 'RETHYMNO', 2, 1, 'Initialization'),
       (42, 'ΡΟΔΟΠΗΣ', 1, 1, 'Initialization'),
       (42, 'RODOPI', 2, 1, 'Initialization'),
       (43, 'ΣΑΜΟΥ', 1, 1, 'Initialization'),
       (43, 'SAMOU', 2, 1, 'Initialization'),
       (44, 'ΣΕΡΡΩΝ', 1, 1, 'Initialization'),
       (44, 'SERRES', 2, 1, 'Initialization'),
       (45, 'ΤΡΙΚΑΛΩΝ', 1, 1, 'Initialization'),
       (45, 'TRIKALA', 2, 1, 'Initialization'),
       (46, 'ΦΘΙΩΤΙΔΑΣ', 1, 1, 'Initialization'),
       (46, 'FTHIOTIDA', 2, 1, 'Initialization'),
       (47, 'ΦΛΩΡΙΝΑΣ', 1, 1, 'Initialization'),
       (47, 'FLORINA', 2, 1, 'Initialization'),
       (48, 'ΦΩΚΙΔΑΣ', 1, 1, 'Initialization'),
       (48, 'FOKIDA', 2, 1, 'Initialization'),
       (49, 'ΧΑΛΚΙΔΙΚΗΣ', 1, 1, 'Initialization'),
       (49, 'CHALKIDIKI', 2, 1, 'Initialization'),
       (50, 'ΧΑΝΙΩΝ', 1, 1, 'Initialization'),
       (50, 'CHANIA', 2, 1, 'Initialization'),
       (51, 'ΧΙΟΥ', 1, 1, 'Initialization'),
       (51, 'CHIOS', 2, 1, 'Initialization'),
       (52, 'ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (52, 'EASTERN ATTICA', 2, 1, 'Initialization'),
       (53, 'ΔΥΤΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (53, 'WESTERN ATTICA', 2, 1, 'Initialization'),
       (54, 'ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (54, 'ATHENS', 2, 1, 'Initialization'),
       (55, 'ΠΕΙΡΑΙΑ', 1, 1, 'Initialization'),
       (55, 'PIRAEUS', 2, 1, 'Initialization');

-- Insert base municipality records with their prefecture associations
INSERT INTO municipalities (prefecture_id, last_user_id, change_reason)
VALUES (9, 1, 'Initialization'),  -- 1
       (9, 1, 'Initialization'),  -- 2
       (9, 1, 'Initialization'),  -- 3
       (9, 1, 'Initialization'),  -- 4
       (9, 1, 'Initialization'),  -- 5
       (11, 1, 'Initialization'), -- 6
       (11, 1, 'Initialization'), -- 7
       (11, 1, 'Initialization'), -- 8
       (11, 1, 'Initialization'), -- 9
       (11, 1, 'Initialization'), -- 10
       (21, 1, 'Initialization'), -- 11
       (21, 1, 'Initialization'), -- 12
       (21, 1, 'Initialization'), -- 13
       (21, 1, 'Initialization'), -- 14
       (37, 1, 'Initialization'), -- 15
       (37, 1, 'Initialization'), -- 16
       (37, 1, 'Initialization'), -- 17
       (37, 1, 'Initialization'), -- 18
       (42, 1, 'Initialization'), -- 19
       (42, 1, 'Initialization'), -- 20
       (42, 1, 'Initialization'), -- 21
       (42, 1, 'Initialization'), -- 22
       (16, 1, 'Initialization'), -- 23
       (16, 1, 'Initialization'), -- 24
       (16, 1, 'Initialization'), -- 25
       (19, 1, 'Initialization'), -- 26
       (19, 1, 'Initialization'), -- 27
       (19, 1, 'Initialization'), -- 28
       (19, 1, 'Initialization'), -- 29
       (19, 1, 'Initialization'), -- 30
       (19, 1, 'Initialization'), -- 31
       (19, 1, 'Initialization'), -- 32
       (19, 1, 'Initialization'), -- 33
       (19, 1, 'Initialization'), -- 34
       (19, 1, 'Initialization'), -- 35
       (19, 1, 'Initialization'), -- 36
       (19, 1, 'Initialization'), -- 37
       (19, 1, 'Initialization'), -- 38
       (19, 1, 'Initialization'), -- 39
       (26, 1, 'Initialization'), -- 40
       (26, 1, 'Initialization'), -- 41
       (38, 1, 'Initialization'), -- 42
       (38, 1, 'Initialization'), -- 43
       (38, 1, 'Initialization'), -- 44
       (38, 1, 'Initialization'), -- 45
       (39, 1, 'Initialization'), -- 46
       (39, 1, 'Initialization'), -- 47
       (39, 1, 'Initialization'), -- 48
       (44, 1, 'Initialization'), -- 49
       (44, 1, 'Initialization'), -- 50
       (44, 1, 'Initialization'), -- 51
       (44, 1, 'Initialization'), -- 52
       (44, 1, 'Initialization'), -- 53
       (44, 1, 'Initialization'), -- 54
       (44, 1, 'Initialization'), -- 55
       (49, 1, 'Initialization'), -- 56
       (49, 1, 'Initialization'), -- 57
       (49, 1, 'Initialization'), -- 58
       (49, 1, 'Initialization'), -- 59
       (49, 1, 'Initialization'), -- 60
       (8, 1, 'Initialization'),  -- 61
       (8, 1, 'Initialization'),  -- 62
       (23, 1, 'Initialization'), -- 63
       (23, 1, 'Initialization'), -- 64
       (23, 1, 'Initialization'), -- 65
       (27, 1, 'Initialization'), -- 66
       (27, 1, 'Initialization'), -- 67
       (27, 1, 'Initialization'), -- 68
       (27, 1, 'Initialization'), -- 69
       (47, 1, 'Initialization'), -- 70
       (47, 1, 'Initialization'), -- 71
       (47, 1, 'Initialization'), -- 72
       (4, 1, 'Initialization'),  -- 73
       (4, 1, 'Initialization'),  -- 74
       (4, 1, 'Initialization'),  -- 75
       (4, 1, 'Initialization'),  -- 76
       (18, 1, 'Initialization'), -- 77
       (18, 1, 'Initialization'), -- 78
       (18, 1, 'Initialization'), -- 79
       (20, 1, 'Initialization'), -- 80
       (20, 1, 'Initialization'), -- 81
       (20, 1, 'Initialization'), -- 82
       (20, 1, 'Initialization'), -- 83
       (20, 1, 'Initialization'), -- 84
       (20, 1, 'Initialization'), -- 85
       (20, 1, 'Initialization'), -- 86
       (20, 1, 'Initialization'), -- 87
       (40, 1, 'Initialization'), -- 88
       (40, 1, 'Initialization'), -- 89
       (40, 1, 'Initialization'), -- 90
       (22, 1, 'Initialization'), -- 91
       (22, 1, 'Initialization'), -- 92
       (22, 1, 'Initialization'), -- 93
       (22, 1, 'Initialization'), -- 94
       (22, 1, 'Initialization'), -- 95
       (22, 1, 'Initialization'), -- 96
       (31, 1, 'Initialization'), -- 97
       (31, 1, 'Initialization'), -- 98
       (31, 1, 'Initialization'), -- 99
       (31, 1, 'Initialization'), -- 100
       (31, 1, 'Initialization'), -- 101
       (31, 1, 'Initialization'), -- 102
       (31, 1, 'Initialization'), -- 103
       (35, 1, 'Initialization'), -- 104
       (35, 1, 'Initialization'), -- 105
       (35, 1, 'Initialization'), -- 106
       (35, 1, 'Initialization'), -- 107
       (35, 1, 'Initialization'), -- 108
       (35, 1, 'Initialization'), -- 109
       (35, 1, 'Initialization'), -- 110
       (35, 1, 'Initialization'), -- 111
       (45, 1, 'Initialization'), -- 112
       (45, 1, 'Initialization'), -- 113
       (45, 1, 'Initialization'), -- 114
       (45, 1, 'Initialization'), -- 115
       (14, 1, 'Initialization'), -- 116
       (25, 1, 'Initialization'), -- 117
       (24, 1, 'Initialization'), -- 118
       (24, 1, 'Initialization'), -- 119
       (25, 1, 'Initialization'), -- 120
       (34, 1, 'Initialization'), -- 121
       (34, 1, 'Initialization'), -- 122
       (1, 1, 'Initialization'),  -- 123
       (1, 1, 'Initialization'),  -- 124
       (1, 1, 'Initialization'),  -- 125
       (1, 1, 'Initialization'),  -- 126
       (1, 1, 'Initialization'),  -- 127
       (1, 1, 'Initialization'),  -- 128
       (1, 1, 'Initialization'),  -- 129
       (6, 1, 'Initialization'),  -- 130
       (6, 1, 'Initialization'),  -- 131
       (6, 1, 'Initialization'),  -- 132
       (6, 1, 'Initialization'),  -- 133
       (6, 1, 'Initialization'),  -- 134
       (15, 1, 'Initialization'), -- 135
       (15, 1, 'Initialization'), -- 136
       (15, 1, 'Initialization'), -- 137
       (15, 1, 'Initialization'), -- 138
       (15, 1, 'Initialization'), -- 139
       (15, 1, 'Initialization'), -- 140
       (15, 1, 'Initialization'), -- 141
       (7, 1, 'Initialization'),  -- 142
       (7, 1, 'Initialization'),  -- 143
       (7, 1, 'Initialization'),  -- 144
       (7, 1, 'Initialization'),  -- 145
       (7, 1, 'Initialization'),  -- 146
       (7, 1, 'Initialization'),  -- 147
       (12, 1, 'Initialization'), -- 148
       (12, 1, 'Initialization'), -- 149
       (12, 1, 'Initialization'), -- 150
       (12, 1, 'Initialization'), -- 151
       (12, 1, 'Initialization'), -- 152
       (12, 1, 'Initialization'), -- 153
       (12, 1, 'Initialization'), -- 154
       (12, 1, 'Initialization'), -- 155
       (13, 1, 'Initialization'), -- 156
       (13, 1, 'Initialization'), -- 157
       (46, 1, 'Initialization'), -- 158
       (46, 1, 'Initialization'), -- 159
       (46, 1, 'Initialization'), -- 160
       (46, 1, 'Initialization'), -- 161
       (46, 1, 'Initialization'), -- 162
       (46, 1, 'Initialization'), -- 163
       (46, 1, 'Initialization'), -- 164
       (48, 1, 'Initialization'), -- 165
       (48, 1, 'Initialization'), -- 166
       (5, 1, 'Initialization'),  -- 167
       (5, 1, 'Initialization'),  -- 168
       (5, 1, 'Initialization'),  -- 169
       (5, 1, 'Initialization'),  -- 170
       (5, 1, 'Initialization'),  -- 171
       (5, 1, 'Initialization'),  -- 172
       (5, 1, 'Initialization'),  -- 173
       (5, 1, 'Initialization'),  -- 174
       (5, 1, 'Initialization'),  -- 175
       (5, 1, 'Initialization'),  -- 176
       (5, 1, 'Initialization'),  -- 177
       (5, 1, 'Initialization'),  -- 178
       (5, 1, 'Initialization'),  -- 179
       (5, 1, 'Initialization'),  -- 180
       (5, 1, 'Initialization'),  -- 181
       (5, 1, 'Initialization'),  -- 182
       (5, 1, 'Initialization'),  -- 183
       (5, 1, 'Initialization'),  -- 184
       (5, 1, 'Initialization'),  -- 185
       (5, 1, 'Initialization'),  -- 186
       (5, 1, 'Initialization'),  -- 187
       (5, 1, 'Initialization'),  -- 188
       (5, 1, 'Initialization'),  -- 189
       (5, 1, 'Initialization'),  -- 190
       (5, 1, 'Initialization'),  -- 191
       (5, 1, 'Initialization'),  -- 192
       (5, 1, 'Initialization'),  -- 193
       (5, 1, 'Initialization'),  -- 194
       (5, 1, 'Initialization'),  -- 195
       (5, 1, 'Initialization'),  -- 196
       (5, 1, 'Initialization'),  -- 197
       (5, 1, 'Initialization'),  -- 198
       (5, 1, 'Initialization'),  -- 199
       (5, 1, 'Initialization'),  -- 200
       (5, 1, 'Initialization'),  -- 201
       (5, 1, 'Initialization'),  -- 202
       (5, 1, 'Initialization'),  -- 203
       (5, 1, 'Initialization'),  -- 204
       (5, 1, 'Initialization'),  -- 205
       (5, 1, 'Initialization'),  -- 206
       (5, 1, 'Initialization'),  -- 207
       (5, 1, 'Initialization'),  -- 208
       (5, 1, 'Initialization'),  -- 209
       (5, 1, 'Initialization'),  -- 210
       (5, 1, 'Initialization'),  -- 211
       (5, 1, 'Initialization'),  -- 212
       (5, 1, 'Initialization'),  -- 213
       (5, 1, 'Initialization'),  -- 214
       (5, 1, 'Initialization'),  -- 215
       (5, 1, 'Initialization'),  -- 216
       (5, 1, 'Initialization'),  -- 217
       (5, 1, 'Initialization'),  -- 218
       (5, 1, 'Initialization'),  -- 219
       (5, 1, 'Initialization'),  -- 220
       (5, 1, 'Initialization'),  -- 221
       (5, 1, 'Initialization'),  -- 222
       (5, 1, 'Initialization'),  -- 223
       (5, 1, 'Initialization'),  -- 224
       (5, 1, 'Initialization'),  -- 225
       (5, 1, 'Initialization'),  -- 226
       (5, 1, 'Initialization'),  -- 227
       (5, 1, 'Initialization'),  -- 228
       (5, 1, 'Initialization'),  -- 229
       (5, 1, 'Initialization'),  -- 230
       (5, 1, 'Initialization'),  -- 231
       (5, 1, 'Initialization'),  -- 232
       (2, 1, 'Initialization'),  -- 233
       (2, 1, 'Initialization'),  -- 234
       (2, 1, 'Initialization'),  -- 235
       (2, 1, 'Initialization'),  -- 236
       (3, 1, 'Initialization'),  -- 237
       (3, 1, 'Initialization'),  -- 238
       (3, 1, 'Initialization'),  -- 239
       (3, 1, 'Initialization'),  -- 240
       (3, 1, 'Initialization'),  -- 241
       (28, 1, 'Initialization'), -- 242
       (28, 1, 'Initialization'), -- 243
       (28, 1, 'Initialization'), -- 244
       (28, 1, 'Initialization'), -- 245
       (28, 1, 'Initialization'), -- 246
       (28, 1, 'Initialization'), -- 247
       (30, 1, 'Initialization'), -- 248
       (30, 1, 'Initialization'), -- 249
       (30, 1, 'Initialization'), -- 250
       (30, 1, 'Initialization'), -- 251
       (30, 1, 'Initialization'), -- 252
       (36, 1, 'Initialization'), -- 253
       (36, 1, 'Initialization'), -- 254
       (36, 1, 'Initialization'), -- 255
       (36, 1, 'Initialization'), -- 256
       (36, 1, 'Initialization'), -- 257
       (36, 1, 'Initialization'), -- 258
       (43, 1, 'Initialization'), -- 259
       (43, 1, 'Initialization'), -- 260
       (33, 1, 'Initialization'), -- 261
       (33, 1, 'Initialization'), -- 262
       (33, 1, 'Initialization'), -- 263
       (43, 1, 'Initialization'), -- 264
       (51, 1, 'Initialization'), -- 265
       (51, 1, 'Initialization'), -- 266
       (51, 1, 'Initialization'), -- 267
       (29, 1, 'Initialization'), -- 268
       (29, 1, 'Initialization'), -- 269
       (29, 1, 'Initialization'), -- 270
       (29, 1, 'Initialization'), -- 271
       (29, 1, 'Initialization'), -- 272
       (29, 1, 'Initialization'), -- 273
       (10, 1, 'Initialization'), -- 274
       (10, 1, 'Initialization'), -- 275
       (10, 1, 'Initialization'), -- 276
       (10, 1, 'Initialization'), -- 277
       (10, 1, 'Initialization'), -- 278
       (10, 1, 'Initialization'), -- 279
       (10, 1, 'Initialization'), -- 280
       (10, 1, 'Initialization'), -- 281
       (29, 1, 'Initialization'), -- 282
       (29, 1, 'Initialization'), -- 283
       (10, 1, 'Initialization'), -- 284
       (10, 1, 'Initialization'), -- 285
       (29, 1, 'Initialization'), -- 286
       (29, 1, 'Initialization'), -- 287
       (29, 1, 'Initialization'), -- 288
       (29, 1, 'Initialization'), -- 289
       (29, 1, 'Initialization'), -- 290
       (29, 1, 'Initialization'), -- 291
       (29, 1, 'Initialization'), -- 292
       (29, 1, 'Initialization'), -- 293
       (29, 1, 'Initialization'), -- 294
       (10, 1, 'Initialization'), -- 295
       (10, 1, 'Initialization'), -- 296
       (10, 1, 'Initialization'), -- 297
       (10, 1, 'Initialization'), -- 298
       (10, 1, 'Initialization'), -- 299
       (29, 1, 'Initialization'), -- 300
       (29, 1, 'Initialization'), -- 301
       (17, 1, 'Initialization'), -- 302
       (17, 1, 'Initialization'), -- 303
       (17, 1, 'Initialization'), -- 304
       (17, 1, 'Initialization'), -- 305
       (17, 1, 'Initialization'), -- 306
       (17, 1, 'Initialization'), -- 307
       (17, 1, 'Initialization'), -- 308
       (17, 1, 'Initialization'), -- 309
       (32, 1, 'Initialization'), -- 310
       (32, 1, 'Initialization'), -- 311
       (32, 1, 'Initialization'), -- 312
       (32, 1, 'Initialization'), -- 313
       (41, 1, 'Initialization'), -- 314
       (41, 1, 'Initialization'), -- 315
       (41, 1, 'Initialization'), -- 316
       (41, 1, 'Initialization'), -- 317
       (41, 1, 'Initialization'), -- 318
       (50, 1, 'Initialization'), -- 319
       (50, 1, 'Initialization'), -- 320
       (50, 1, 'Initialization'), -- 321
       (50, 1, 'Initialization'), -- 322
       (50, 1, 'Initialization'), -- 323
       (50, 1, 'Initialization'), -- 324
       (50, 1, 'Initialization'), -- 325
       (24, 1, 'Initialization'), -- 326
       (24, 1, 'Initialization'), -- 327
       (25, 1, 'Initialization'), -- 328
       (25, 1, 'Initialization'), -- 329
       (27, 1, 'Initialization'), -- 330
       (33, 1, 'Initialization'), -- 331
       (43, 1, 'Initialization'), -- 332
       (49, 1, 'Initialization');
-- 333

-- Insert municipality translations
INSERT INTO municipalitiesI18n (municipality_id, description, language_id, last_user_id, change_reason)
VALUES (1, 'ΔΟΞΑΤΟΥ / ΔΡΑΜΑΣ', 1, 1, 'Initialization'),
       (2, 'ΔΡΑΜΑΣ / ΔΡΑΜΑΣ', 1, 1, 'Initialization'),
       (3, 'ΚΑΤΩ ΝΕΥΡΟΚΟΠΙΟΥ / ΔΡΑΜΑΣ', 1, 1, 'Initialization'),
       (4, 'ΠΑΡΑΝΕΣΤΙΟΥ / ΔΡΑΜΑΣ', 1, 1, 'Initialization'),
       (5, 'ΠΡΟΣΟΤΣΑΝΗΣ / ΔΡΑΜΑΣ', 1, 1, 'Initialization'),
       (6, 'ΑΛΕΞΑΝΔΡΟΥΠΟΛΗΣ / ΕΒΡΟΥ', 1, 1, 'Initialization'),
       (7, 'ΔΙΔΥΜΟΤΕΙΧΟΥ / ΕΒΡΟΥ', 1, 1, 'Initialization'),
       (8, 'ΟΡΕΣΤΙΑΔΑΣ / ΕΒΡΟΥ', 1, 1, 'Initialization'),
       (9, 'ΣΑΜΟΘΡΑΚΗΣ / ΕΒΡΟΥ', 1, 1, 'Initialization'),
       (10, 'ΣΟΥΦΛΙΟΥ / ΕΒΡΟΥ', 1, 1, 'Initialization'),
       (11, 'ΘΑΣΟΥ / ΘΑΣΟΥ', 1, 1, 'Initialization'),
       (12, 'ΚΑΒΑΛΑΣ / ΚΑΒΑΛΑΣ', 1, 1, 'Initialization'),
       (13, 'ΝΕΣΤΟΥ / ΚΑΒΑΛΑΣ', 1, 1, 'Initialization'),
       (14, 'ΠΑΓΓΑΙΟΥ / ΚΑΒΑΛΑΣ', 1, 1, 'Initialization'),
       (15, 'ΑΒΔΗΡΩΝ / ΞΑΝΘΗΣ', 1, 1, 'Initialization'),
       (16, 'ΜΥΚΗΣ / ΞΑΝΘΗΣ', 1, 1, 'Initialization'),
       (17, 'ΞΑΝΘΗΣ / ΞΑΝΘΗΣ', 1, 1, 'Initialization'),
       (18, 'ΤΟΠΕΙΡΟΥ / ΞΑΝΘΗΣ', 1, 1, 'Initialization'),
       (19, 'ΑΡΡΙΑΝΩΝ / ΡΟΔΟΠΗΣ', 1, 1, 'Initialization'),
       (20, 'ΙΑΣΜΟΥ / ΡΟΔΟΠΗΣ', 1, 1, 'Initialization'),
       (21, 'ΚΟΜΟΤΗΝΗΣ / ΡΟΔΟΠΗΣ', 1, 1, 'Initialization'),
       (22, 'ΜΑΡΩΝΕΙΑΣ-ΣΑΠΩΝ / ΡΟΔΟΠΗΣ', 1, 1, 'Initialization'),
       (23, 'ΑΛΕΞΑΝΔΡΕΙΑΣ / ΗΜΑΘΙΑΣ', 1, 1, 'Initialization'),
       (24, 'ΒΕΡΟΙΑΣ / ΗΜΑΘΙΑΣ', 1, 1, 'Initialization'),
       (25, 'ΗΡΩΙΚΗΣ ΠΟΛΕΩΣ ΝΑΟΥΣΑΣ/ ΗΜΑΘΙΑΣ', 1, 1, 'Initialization'),
       (26, 'ΑΜΠΕΛΟΚΗΠΩΝ-ΜΕΝΕΜΕΝΗΣ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (27, 'ΒΟΛΒΗΣ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (28, 'ΔΕΛΤΑ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (29, 'ΘΕΡΜΑΪΚΟΥ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (30, 'ΘΕΡΜΗΣ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (31, 'ΘΕΣΣΑΛΟΝΙΚΗΣ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (32, 'ΚΑΛΑΜΑΡΙΑΣ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (33, 'ΚΟΡΔΕΛΙΟΥ-ΕΥΟΣΜΟΥ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (34, 'ΛΑΓΚΑΔΑ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (35, 'ΝΕΑΠΟΛΗΣ-ΣΥΚΕΩΝ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (36, 'ΠΑΥΛΟΥ ΜΕΛΑ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (37, 'ΠΥΛΑΙΑΣ-ΧΟΡΤΙΑΤΗ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (38, 'ΧΑΛΚΗΔΟΝΟΣ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (39, 'ΩΡΑΙΟΚΑΣΤΡΟΥ / ΘΕΣΣΑΛΟΝΙΚΗΣ', 1, 1, 'Initialization'),
       (40, 'ΚΙΛΚΙΣ / ΚΙΛΚΙΣ', 1, 1, 'Initialization'),
       (41, 'ΠΑΙΟΝΙΑΣ / ΚΙΛΚΙΣ', 1, 1, 'Initialization'),
       (42, 'ΑΛΜΩΠΙΑΣ / ΠΕΛΛΑΣ', 1, 1, 'Initialization'),
       (43, 'ΕΔΕΣΣΑΣ / ΠΕΛΛΑΣ', 1, 1, 'Initialization'),
       (44, 'ΠΕΛΛΑΣ / ΠΕΛΛΑΣ', 1, 1, 'Initialization'),
       (45, 'ΣΚΥΔΡΑΣ / ΠΕΛΛΑΣ', 1, 1, 'Initialization'),
       (46, 'ΔΙΟΥ-ΟΛΥΜΠΟΥ / ΠΙΕΡΙΑΣ', 1, 1, 'Initialization'),
       (47, 'ΚΑΤΕΡΙΝΗΣ / ΠΙΕΡΙΑΣ', 1, 1, 'Initialization'),
       (48, 'ΠΥΔΝΑΣ-ΚΟΛΙΝΔΡΟΥ / ΠΙΕΡΙΑΣ', 1, 1, 'Initialization'),
       (49, 'ΑΜΦΙΠΟΛΗΣ / ΣΕΡΡΩΝ', 1, 1, 'Initialization'),
       (50, 'ΒΙΣΑΛΤΙΑΣ / ΣΕΡΡΩΝ', 1, 1, 'Initialization'),
       (51, 'ΕΜΜΑΝΟΥΗΛ ΠΑΠΠΑ / ΣΕΡΡΩΝ', 1, 1, 'Initialization'),
       (52, 'ΗΡΑΚΛΕΙΑΣ / ΣΕΡΡΩΝ', 1, 1, 'Initialization'),
       (53, 'ΝΕΑΣ ΖΙΧΝΗΣ / ΣΕΡΡΩΝ', 1, 1, 'Initialization'),
       (54, 'ΣΕΡΡΩΝ / ΣΕΡΡΩΝ', 1, 1, 'Initialization'),
       (55, 'ΣΙΝΤΙΚΗΣ / ΣΕΡΡΩΝ', 1, 1, 'Initialization'),
       (56, 'ΑΡΙΣΤΟΤΕΛΗ / ΧΑΛΚΙΔΙΚΗΣ', 1, 1, 'Initialization'),
       (57, 'ΚΑΣΣΑΝΔΡΑΣ / ΧΑΛΚΙΔΙΚΗΣ', 1, 1, 'Initialization'),
       (58, 'ΝΕΑΣ ΠΡΟΠΟΝΤΙΔΑΣ / ΧΑΛΚΙΔΙΚΗΣ', 1, 1, 'Initialization'),
       (59, 'ΠΟΛΥΓΥΡΟΥ / ΧΑΛΚΙΔΙΚΗΣ', 1, 1, 'Initialization'),
       (60, 'ΣΙΘΩΝΙΑΣ / ΧΑΛΚΙΔΙΚΗΣ', 1, 1, 'Initialization'),
       (61, 'ΓΡΕΒΕΝΩΝ / ΓΡΕΒΕΝΩΝ', 1, 1, 'Initialization'),
       (62, 'ΔΕΣΚΑΤΗΣ / ΓΡΕΒΕΝΩΝ', 1, 1, 'Initialization'),
       (63, 'ΚΑΣΤΟΡΙΑΣ / ΚΑΣΤΟΡΙΑΣ', 1, 1, 'Initialization'),
       (64, 'ΝΕΣΤΟΡΙΟΥ / ΚΑΣΤΟΡΙΑΣ', 1, 1, 'Initialization'),
       (65, 'ΑΡΓΟΥΣ ΟΡΕΣΤΙΚΟΥ / ΚΑΣΤΟΡΙΑΣ', 1, 1, 'Initialization'),
       (66, 'ΒΟΙΟΥ / ΚΟΖΑΝΗΣ', 1, 1, 'Initialization'),
       (67, 'ΕΟΡΔΑΙΑΣ / ΚΟΖΑΝΗΣ', 1, 1, 'Initialization'),
       (68, 'ΚΟΖΑΝΗΣ / ΚΟΖΑΝΗΣ', 1, 1, 'Initialization'),
       (69, 'ΣΕΡΒΙΩΝ / ΚΟΖΑΝΗΣ', 1, 1, 'Initialization'),
       (70, 'ΑΜΥΝΤΑΙΟΥ / ΦΛΩΡΙΝΑΣ', 1, 1, 'Initialization'),
       (71, 'ΠΡΕΣΠΩΝ / ΦΛΩΡΙΝΑΣ', 1, 1, 'Initialization'),
       (72, 'ΦΛΩΡΙΝΑΣ / ΦΛΩΡΙΝΑΣ', 1, 1, 'Initialization'),
       (73, 'ΑΡΤΑΙΩΝ / ΑΡΤΑΣ', 1, 1, 'Initialization'),
       (74, 'ΓΕΩΡΓΙΟΥ ΚΑΡΑΙΣΚΑΚΗ / ΑΡΤΑΣ', 1, 1, 'Initialization'),
       (75, 'ΚΕΝΤΡΙΚΩΝ ΤΖΟΥΜΕΡΚΩΝ / ΑΡΤΑΣ', 1, 1, 'Initialization'),
       (76, 'ΝΙΚΟΛΑΟΥ ΣΚΟΥΦΑ / ΑΡΤΑΣ', 1, 1, 'Initialization'),
       (77, 'ΗΓΟΥΜΕΝΙΤΣΑΣ / ΘΕΣΠΡΩΤΙΑΣ', 1, 1, 'Initialization'),
       (78, 'ΣΟΥΛΙΟΥ / ΘΕΣΠΡΩΤΙΑΣ', 1, 1, 'Initialization'),
       (79, 'ΦΙΛΙΑΤΩΝ / ΘΕΣΠΡΩΤΙΑΣ', 1, 1, 'Initialization'),
       (80, 'ΒΟΡΕΙΩΝ ΤΖΟΥΜΕΡΚΩΝ / ΙΩΑΝΝΙΝΩΝ', 1, 1, 'Initialization'),
       (81, 'ΔΩΔΩΝΗΣ / ΙΩΑΝΝΙΝΩΝ', 1, 1, 'Initialization'),
       (82, 'ΖΑΓΟΡΙΟΥ / ΙΩΑΝΝΙΝΩΝ', 1, 1, 'Initialization'),
       (83, 'ΖΙΤΣΑΣ / ΙΩΑΝΝΙΝΩΝ', 1, 1, 'Initialization'),
       (84, 'ΙΩΑΝΝΙΤΩΝ / ΙΩΑΝΝΙΝΩΝ', 1, 1, 'Initialization'),
       (85, 'ΚΟΝΙΤΣΑΣ / ΙΩΑΝΝΙΝΩΝ', 1, 1, 'Initialization'),
       (86, 'ΜΕΤΣΟΒΟΥ / ΙΩΑΝΝΙΝΩΝ', 1, 1, 'Initialization'),
       (87, 'ΠΩΓΩΝΙΟΥ / ΙΩΑΝΝΙΝΩΝ', 1, 1, 'Initialization'),
       (88, 'ΖΗΡΟΥ / ΠΡΕΒΕΖΑΣ', 1, 1, 'Initialization'),
       (89, 'ΠΑΡΓΑΣ / ΠΡΕΒΕΖΑΣ', 1, 1, 'Initialization'),
       (90, 'ΠΡΕΒΕΖΑΣ / ΠΡΕΒΕΖΑΣ', 1, 1, 'Initialization'),
       (91, 'ΑΡΓΙΘΕΑΣ / ΚΑΡΔΙΤΣΑΣ', 1, 1, 'Initialization'),
       (92, 'ΚΑΡΔΙΤΣΑΣ / ΚΑΡΔΙΤΣΑΣ', 1, 1, 'Initialization'),
       (93, 'ΛΙΜΝΗΣ ΠΛΑΣΤΗΡΑ / ΚΑΡΔΙΤΣΑΣ', 1, 1, 'Initialization'),
       (94, 'ΜΟΥΖΑΚΙΟΥ / ΚΑΡΔΙΤΣΑΣ', 1, 1, 'Initialization'),
       (95, 'ΠΑΛΑΜΑ / ΚΑΡΔΙΤΣΑΣ', 1, 1, 'Initialization'),
       (96, 'ΣΟΦΑΔΩΝ / ΚΑΡΔΙΤΣΑΣ', 1, 1, 'Initialization'),
       (97, 'ΑΓΙΑΣ / ΛΑΡΙΣΑΣ', 1, 1, 'Initialization'),
       (98, 'ΕΛΑΣΣΟΝΑΣ / ΛΑΡΙΣΑΣ', 1, 1, 'Initialization'),
       (99, 'ΚΙΛΕΛΕΡ / ΛΑΡΙΣΑΣ', 1, 1, 'Initialization'),
       (100, 'ΛΑΡΙΣΑΙΩΝ / ΛΑΡΙΣΑΣ', 1, 1, 'Initialization'),
       (101, 'ΤΕΜΠΩΝ / ΛΑΡΙΣΑΣ', 1, 1, 'Initialization'),
       (102, 'ΤΥΡΝΑΒΟΥ / ΛΑΡΙΣΑΣ', 1, 1, 'Initialization'),
       (103, 'ΦΑΡΣΑΛΩΝ / ΛΑΡΙΣΑΣ', 1, 1, 'Initialization'),
       (104, 'ΑΛΜΥΡΟΥ / ΜΑΓΝΗΣΙΑΣ', 1, 1, 'Initialization'),
       (105, 'ΒΟΛΟΥ / ΜΑΓΝΗΣΙΑΣ', 1, 1, 'Initialization'),
       (106, 'ΖΑΓΟΡΑΣ-ΜΟΥΡΕΣΙΟΥ / ΜΑΓΝΗΣΙΑΣ', 1, 1, 'Initialization'),
       (107, 'ΝΟΤΙΟΥ ΠΗΛΙΟΥ / ΜΑΓΝΗΣΙΑΣ', 1, 1, 'Initialization'),
       (108, 'ΡΗΓΑ ΦΕΡΑΙΟΥ / ΜΑΓΝΗΣΙΑΣ', 1, 1, 'Initialization'),
       (109, 'ΑΛΟΝΝΗΣΟΥ / ΣΠΟΡΑΔΩΝ', 1, 1, 'Initialization'),
       (110, 'ΣΚΙΑΘΟΥ / ΣΠΟΡΑΔΩΝ', 1, 1, 'Initialization'),
       (111, 'ΣΚΟΠΕΛΟΥ / ΣΠΟΡΑΔΩΝ', 1, 1, 'Initialization'),
       (112, 'ΜΕΤΕΩΡΩΝ / ΤΡΙΚΑΛΩΝ', 1, 1, 'Initialization'),
       (113, 'ΠΥΛΗΣ / ΤΡΙΚΑΛΩΝ', 1, 1, 'Initialization'),
       (114, 'ΤΡΙΚΚΑΙΩΝ / ΤΡΙΚΑΛΩΝ', 1, 1, 'Initialization'),
       (115, 'ΦΑΡΚΑΔΟΝΑΣ / ΤΡΙΚΑΛΩΝ', 1, 1, 'Initialization'),
       (116, 'ΖΑΚΥΝΘΟΥ / ΖΑΚΥΝΘΟΥ', 1, 1, 'Initialization'),
       (117, 'ΙΘΑΚΗΣ / ΙΘΑΚΗΣ', 1, 1, 'Initialization'),
       (118, 'ΚΕΝΤΡΙΚΗΣ ΚΕΡΚΥΡΑΣ ΚΑΙ ΔΙΑΠΟΝΤΙΩΝ ΝΗΣΩΝ / ΚΕΡΚΥΡΑΣ', 1, 1, 'Initialization'),
       (119, 'ΠΑΞΩΝ / ΚΕΡΚΥΡΑΣ', 1, 1, 'Initialization'),
       (120, 'ΑΡΓΟΣΤΟΛΙΟΥ / ΚΕΦΑΛΛΗΝΙΑΣ', 1, 1, 'Initialization'),
       (121, 'ΛΕΥΚΑΔΑΣ / ΛΕΥΚΑΔΑΣ', 1, 1, 'Initialization'),
       (122, 'ΜΕΓΑΝΗΣΙΟΥ / ΛΕΥΚΑΔΑΣ', 1, 1, 'Initialization'),
       (123, 'ΑΓΡΙΝΙΟΥ / ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ', 1, 1, 'Initialization'),
       (124, 'ΑΚΤΙΟΥ-ΒΟΝΙΤΣΑΣ / ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ', 1, 1, 'Initialization'),
       (125, 'ΑΜΦΙΛΟΧΙΑΣ / ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ', 1, 1, 'Initialization'),
       (126, 'ΘΕΡΜΟΥ / ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ', 1, 1, 'Initialization'),
       (127, 'ΙΕΡΑΣ ΠΟΛΗΣ ΜΕΣΟΛΟΓΓΙΟΥ / ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ', 1, 1, 'Initialization'),
       (128, 'ΝΑΥΠΑΚΤΙΑΣ / ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ', 1, 1, 'Initialization'),
       (129, 'ΞΗΡΟΜΕΡΟΥ / ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ', 1, 1, 'Initialization'),
       (130, 'ΑΙΓΙΑΛΕΙΑΣ / ΑΧΑΙΑΣ', 1, 1, 'Initialization'),
       (131, 'ΔΥΤΙΚΗΣ ΑΧΑΙΑΣ / ΑΧΑΙΑΣ', 1, 1, 'Initialization'),
       (132, 'ΕΡΥΜΑΝΘΟΥ / ΑΧΑΙΑΣ', 1, 1, 'Initialization'),
       (133, 'ΚΑΛΑΒΡΥΤΩΝ / ΑΧΑΙΑΣ', 1, 1, 'Initialization'),
       (134, 'ΠΑΤΡΕΩΝ / ΑΧΑΙΑΣ', 1, 1, 'Initialization'),
       (135, 'ΑΝΔΡΑΒΙΔΑΣ-ΚΥΛΛΗΝΗΣ / ΗΛΕΙΑΣ', 1, 1, 'Initialization'),
       (136, 'ΑΝΔΡΙΤΣΑΙΝΑΣ-ΚΡΕΣΤΕΝΩΝ / ΗΛΕΙΑΣ', 1, 1, 'Initialization'),
       (137, 'ΑΡΧΑΙΑΣ ΟΛΥΜΠΙΑΣ / ΗΛΕΙΑΣ', 1, 1, 'Initialization'),
       (138, 'ΖΑΧΑΡΩΣ / ΗΛΕΙΑΣ', 1, 1, 'Initialization'),
       (139, 'ΗΛΙΔΑΣ / ΗΛΕΙΑΣ', 1, 1, 'Initialization'),
       (140, 'ΠΗΝΕΙΟΥ / ΗΛΕΙΑΣ', 1, 1, 'Initialization'),
       (141, 'ΠΥΡΓΟΥ / ΗΛΕΙΑΣ', 1, 1, 'Initialization'),
       (142, 'ΑΛΙΑΡΤΟΥ-ΘΕΣΠΙΕΩΝ / ΒΟΙΩΤΙΑΣ', 1, 1, 'Initialization'),
       (143, 'ΔΙΣΤΟΜΟΥ - ΑΡΑΧΟΒΑΣ - ΑΝΤΙΚΥΡΑΣ / ΒΟΙΩΤΙΑΣ', 1, 1, 'Initialization'),
       (144, 'ΘΗΒΑΙΩΝ / ΒΟΙΩΤΙΑΣ', 1, 1, 'Initialization'),
       (145, 'ΛΕΒΑΔΕΩΝ / ΒΟΙΩΤΙΑΣ', 1, 1, 'Initialization'),
       (146, 'ΟΡΧΟΜΕΝΟΥ / ΒΟΙΩΤΙΑΣ', 1, 1, 'Initialization'),
       (147, 'ΤΑΝΑΓΡΑΣ / ΒΟΙΩΤΙΑΣ', 1, 1, 'Initialization'),
       (148, 'ΔΙΡΦΥΩΝ-ΜΕΣΣΑΠΙΩΝ / ΕΥΒΟΙΑΣ', 1, 1, 'Initialization'),
       (149, 'ΕΡΕΤΡΙΑΣ / ΕΥΒΟΙΑΣ', 1, 1, 'Initialization'),
       (150, 'ΙΣΤΙΑΙΑΣ-ΑΙΔΗΨΟΥ / ΕΥΒΟΙΑΣ', 1, 1, 'Initialization'),
       (151, 'ΚΑΡΥΣΤΟΥ / ΕΥΒΟΙΑΣ', 1, 1, 'Initialization'),
       (152, 'ΚΥΜΗΣ-ΑΛΙΒΕΡΙΟΥ / ΕΥΒΟΙΑΣ', 1, 1, 'Initialization'),
       (153, 'ΜΑΝΤΟΥΔΙΟΥ-ΛΙΜΝΗΣ-ΑΓΙΑΣ ΑΝΝΑΣ / ΕΥΒΟΙΑΣ', 1, 1, 'Initialization'),
       (154, 'ΣΚΥΡΟΥ / ΕΥΒΟΙΑΣ', 1, 1, 'Initialization'),
       (155, 'ΧΑΛΚΙΔΕΩΝ / ΕΥΒΟΙΑΣ', 1, 1, 'Initialization'),
       (156, 'ΑΓΡΑΦΩΝ / ΕΥΡΥΤΑΝΙΑΣ', 1, 1, 'Initialization'),
       (157, 'ΚΑΡΠΕΝΗΣΙΟΥ / ΕΥΡΥΤΑΝΙΑΣ', 1, 1, 'Initialization'),
       (158, 'ΑΜΦΙΚΛΕΙΑΣ - ΕΛΑΤΕΙΑΣ / ΦΘΙΩΤΙΔΑΣ', 1, 1, 'Initialization'),
       (159, 'ΔΟΜΟΚΟΥ / ΦΘΙΩΤΙΔΑΣ', 1, 1, 'Initialization'),
       (160, 'ΛΑΜΙΕΩΝ / ΦΘΙΩΤΙΔΑΣ', 1, 1, 'Initialization'),
       (161, 'ΛΟΚΡΩΝ / ΦΘΙΩΤΙΔΑΣ', 1, 1, 'Initialization'),
       (162, 'ΜΑΚΡΑΚΩΜΗΣ / ΦΘΙΩΤΙΔΑΣ', 1, 1, 'Initialization'),
       (163, 'ΚΑΜΕΝΩΝ ΒΟΥΡΛΩΝ / ΦΘΙΩΤΙΔΑΣ', 1, 1, 'Initialization'),
       (164, 'ΣΤΥΛΙΔΑΣ / ΦΘΙΩΤΙΔΑΣ', 1, 1, 'Initialization'),
       (165, 'ΔΕΛΦΩΝ / ΦΩΚΙΔΑΣ', 1, 1, 'Initialization'),
       (166, 'ΔΩΡΙΔΟΣ / ΦΩΚΙΔΑΣ', 1, 1, 'Initialization'),
       (167, 'ΑΓΙΑΣ ΠΑΡΑΣΚΕΥΗΣ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (168, 'ΑΜΑΡΟΥΣΙΟΥ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (169, 'ΒΡΙΛΗΣΣΙΩΝ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (170, 'ΗΡΑΚΛΕΙΟΥ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (171, 'ΚΗΦΙΣΙΑΣ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (172, 'ΛΥΚΟΒΡΥΣΗΣ - ΠΕΥΚΗΣ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (173, 'ΜΕΤΑΜΟΡΦΩΣΕΩΣ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (174, 'ΝΕΑΣ ΙΩΝΙΑΣ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (175, 'ΠΑΠΑΓΟΥ - ΧΟΛΑΡΓΟΥ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (176, 'ΠΕΝΤΕΛΗΣ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (177, 'ΦΙΛΟΘΕΗΣ - ΨΥΧΙΚΟΥ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (178, 'ΧΑΛΑΝΔΡΙΟΥ / ΒΟΡΕΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (179, 'ΑΓΙΑΣ ΒΑΡΒΑΡΑΣ / ΔΥΤΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (180, 'ΑΓΙΩΝ ΑΝΑΡΓΥΡΩΝ - ΚΑΜΑΤΕΡΟΥ / ΔΥΤΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (181, 'ΑΙΓΑΛΕΩ / ΔΥΤΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (182, 'ΙΛΙΟΥ / ΔΥΤΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (183, 'ΠΕΡΙΣΤΕΡΙΟΥ / ΔΥΤΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (184, 'ΠΕΤΡΟΥΠΟΛΕΩΣ / ΔΥΤΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (185, 'ΧΑΙΔΑΡΙΟΥ / ΔΥΤΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (186, 'ΑΘΗΝΑΙΩΝ / ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (187, 'ΒΥΡΩΝΟΣ / ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (188, 'ΓΑΛΑΤΣΙΟΥ / ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (189, 'ΔΑΦΝΗΣ - ΥΜΗΤΤΟΥ / ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (190, 'ΖΩΓΡΑΦΟΥ / ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (191, 'ΗΛΙΟΥΠΟΛΕΩΣ / ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (192, 'ΚΑΙΣΑΡΙΑΝΗΣ / ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (193, 'ΝΕΑΣ ΦΙΛΑΔΕΛΦΕΙΑΣ - ΝΕΑΣ ΧΑΛΚΗΔΟΝΑΣ / ΚΕΝΤΡΙΚΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (194, 'ΑΓΙΟΥ ΔΗΜΗΤΡΙΟΥ / ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (195, 'ΑΛΙΜΟΥ / ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (196, 'ΓΛΥΦΑΔΑΣ / ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (197, 'ΕΛΛΗΝΙΚΟΥ - ΑΡΓΥΡΟΥΠΟΛΗΣ / ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (198, 'ΚΑΛΛΙΘΕΑΣ / ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (199, 'ΜΟΣΧΑΤΟΥ - ΤΑΥΡΟΥ / ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (200, 'ΝΕΑΣ ΣΜΥΡΝΗΣ / ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (201, 'ΠΑΛΑΙΟΥ ΦΑΛΗΡΟΥ / ΝΟΤΙΟΥ ΤΟΜΕΑ ΑΘΗΝΩΝ', 1, 1, 'Initialization'),
       (202, 'ΚΕΡΑΤΣΙΝΙΟΥ - ΔΡΑΠΕΤΣΩΝΑΣ / ΠΕΙΡΑΙΩΣ', 1, 1, 'Initialization'),
       (203, 'ΚΟΡΥΔΑΛΛΟΥ / ΠΕΙΡΑΙΩΣ', 1, 1, 'Initialization'),
       (204, 'ΝΙΚΑΙΑΣ - ΑΓΙΟΥ ΙΩΑΝΝΗ ΡΕΝΤΗ / ΠΕΙΡΑΙΩΣ', 1, 1, 'Initialization'),
       (205, 'ΠΕΙΡΑΙΩΣ / ΠΕΙΡΑΙΩΣ', 1, 1, 'Initialization'),
       (206, 'ΠΕΡΑΜΑΤΟΣ / ΠΕΙΡΑΙΩΣ', 1, 1, 'Initialization'),
       (207, 'ΑΓΚΙΣΤΡΙΟΥ / ΝΗΣΩΝ', 1, 1, 'Initialization'),
       (208, 'ΑΙΓΙΝΑΣ / ΝΗΣΩΝ', 1, 1, 'Initialization'),
       (209, 'ΚΥΘΗΡΩΝ / ΝΗΣΩΝ', 1, 1, 'Initialization'),
       (210, 'ΠΟΡΟΥ / ΝΗΣΩΝ', 1, 1, 'Initialization'),
       (211, 'ΣΑΛΑΜΙΝΑΣ / ΝΗΣΩΝ', 1, 1, 'Initialization'),
       (212, 'ΣΠΕΤΣΩΝ / ΝΗΣΩΝ', 1, 1, 'Initialization'),
       (213, 'ΤΡΟΙΖΗΝΙΑΣ-ΜΕΘΑΝΩΝ / ΝΗΣΩΝ', 1, 1, 'Initialization'),
       (214, 'ΥΔΡΑΣ / ΝΗΣΩΝ', 1, 1, 'Initialization'),
       (215, 'ΑΧΑΡΝΩΝ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (216, 'ΒΑΡΗΣ - ΒΟΥΛΑΣ - ΒΟΥΛΙΑΓΜΕΝΗΣ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (217, 'ΔΙΟΝΥΣΟΥ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (218, 'ΚΡΩΠΙΑΣ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (219, 'ΛΑΥΡΕΩΤΙΚΗΣ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (220, 'ΜΑΡΑΘΩΝΟΣ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (221, 'ΜΑΡΚΟΠΟΥΛΟΥ ΜΕΣΟΓΑΙΑΣ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (222, 'ΠΑΙΑΝΙΑΣ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (223, 'ΠΑΛΛΗΝΗΣ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (224, 'ΡΑΦΗΝΑΣ - ΠΙΚΕΡΜΙΟΥ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (225, 'ΣΑΡΩΝΙΚΟΥ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (226, 'ΣΠΑΤΩΝ - ΑΡΤΕΜΙΔΟΣ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (227, 'ΩΡΩΠΟΥ / ΑΝΑΤΟΛΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (228, 'ΑΣΠΡΟΠΥΡΓΟΥ / ΔΥΤΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (229, 'ΕΛΕΥΣΙΝΑΣ / ΔΥΤΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (230, 'ΜΑΝΔΡΑΣ - ΕΙΔΥΛΛΙΑΣ / ΔΥΤΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (231, 'ΜΕΓΑΡΕΩΝ / ΔΥΤΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (232, 'ΦΥΛΗΣ / ΔΥΤΙΚΗΣ ΑΤΤΙΚΗΣ', 1, 1, 'Initialization'),
       (233, 'ΑΡΓΟΥΣ-ΜΥΚΗΝΩΝ / ΑΡΓΟΛΙΔΑΣ', 1, 1, 'Initialization'),
       (234, 'ΕΠΙΔΑΥΡΟΥ / ΑΡΓΟΛΙΔΑΣ', 1, 1, 'Initialization'),
       (235, 'ΕΡΜΙΟΝΙΔΑΣ / ΑΡΓΟΛΙΔΑΣ', 1, 1, 'Initialization'),
       (236, 'ΝΑΥΠΛΙΕΩΝ / ΑΡΓΟΛΙΔΑΣ', 1, 1, 'Initialization'),
       (237, 'ΒΟΡΕΙΑΣ ΚΥΝΟΥΡΙΑΣ / ΑΡΚΑΔΙΑΣ', 1, 1, 'Initialization'),
       (238, 'ΓΟΡΤΥΝΙΑΣ / ΑΡΚΑΔΙΑΣ', 1, 1, 'Initialization'),
       (239, 'ΜΕΓΑΛΟΠΟΛΗΣ / ΑΡΚΑΔΙΑΣ', 1, 1, 'Initialization'),
       (240, 'ΝΟΤΙΑΣ ΚΥΝΟΥΡΙΑΣ / ΑΡΚΑΔΙΑΣ', 1, 1, 'Initialization'),
       (241, 'ΤΡΙΠΟΛΗΣ / ΑΡΚΑΔΙΑΣ', 1, 1, 'Initialization'),
       (242, 'ΒΕΛΟΥ-ΒΟΧΑΣ / ΚΟΡΙΝΘΙΑΣ', 1, 1, 'Initialization'),
       (243, 'ΚΟΡΙΝΘΙΩΝ / ΚΟΡΙΝΘΙΑΣ', 1, 1, 'Initialization'),
       (244, 'ΛΟΥΤΡΑΚΙΟΥ-ΠΕΡΑΧΩΡΑΣ-ΑΓΙΩΝ ΘΕΟΔΩΡΩΝ / ΚΟΡΙΝΘΙΑΣ', 1, 1, 'Initialization'),
       (245, 'ΝΕΜΕΑΣ / ΚΟΡΙΝΘΙΑΣ', 1, 1, 'Initialization'),
       (246, 'ΞΥΛΟΚΑΣΤΡΟΥ-ΕΥΡΩΣΤΙΝΗΣ / ΚΟΡΙΝΘΙΑΣ', 1, 1, 'Initialization'),
       (247, 'ΣΙΚΥΩΝΙΩΝ / ΚΟΡΙΝΘΙΑΣ', 1, 1, 'Initialization'),
       (248, 'ΑΝΑΤΟΛΙΚΗΣ ΜΑΝΗΣ / ΛΑΚΩΝΙΑΣ', 1, 1, 'Initialization'),
       (249, 'ΕΛΑΦΟΝΗΣΟΥ / ΛΑΚΩΝΙΑΣ', 1, 1, 'Initialization'),
       (250, 'ΕΥΡΩΤΑ / ΛΑΚΩΝΙΑΣ', 1, 1, 'Initialization'),
       (251, 'ΜΟΝΕΜΒΑΣΙΑΣ / ΛΑΚΩΝΙΑΣ', 1, 1, 'Initialization'),
       (252, 'ΣΠΑΡΤΗΣ / ΛΑΚΩΝΙΑΣ', 1, 1, 'Initialization'),
       (253, 'ΔΥΤΙΚΗΣ ΜΑΝΗΣ / ΜΕΣΣΗΝΙΑΣ', 1, 1, 'Initialization'),
       (254, 'ΚΑΛΑΜΑΤΑΣ / ΜΕΣΣΗΝΙΑΣ', 1, 1, 'Initialization'),
       (255, 'ΜΕΣΣΗΝΗΣ / ΜΕΣΣΗΝΙΑΣ', 1, 1, 'Initialization'),
       (256, 'ΟΙΧΑΛΙΑΣ / ΜΕΣΣΗΝΙΑΣ', 1, 1, 'Initialization'),
       (257, 'ΠΥΛΟΥ-ΝΕΣΤΟΡΟΣ / ΜΕΣΣΗΝΙΑΣ', 1, 1, 'Initialization'),
       (258, 'ΤΡΙΦΥΛΙΑΣ / ΜΕΣΣΗΝΙΑΣ', 1, 1, 'Initialization'),
       (259, 'ΙΚΑΡΙΑΣ / ΙΚΑΡΙΑΣ', 1, 1, 'Initialization'),
       (260, 'ΦΟΥΡΝΩΝ ΚΟΡΣΕΩΝ / ΙΚΑΡΙΑΣ', 1, 1, 'Initialization'),
       (261, 'ΜΥΤΙΛΗΝΗΣ / ΛΕΣΒΟΥ', 1, 1, 'Initialization'),
       (262, 'ΑΓΙΟΥ ΕΥΣΤΡΑΤΙΟΥ / ΛΗΜΝΟΥ', 1, 1, 'Initialization'),
       (263, 'ΛΗΜΝΟΥ / ΛΗΜΝΟΥ', 1, 1, 'Initialization'),
       (264, 'ΑΝΑΤΟΛΙΚΗΣ ΣΑΜΟΥ / ΣΑΜΟΥ', 1, 1, 'Initialization'),
       (265, 'ΟΙΝΟΥΣΣΩΝ / ΧΙΟΥ', 1, 1, 'Initialization'),
       (266, 'ΧΙΟΥ / ΧΙΟΥ', 1, 1, 'Initialization'),
       (267, 'ΗΡΩΙΚΗΣ ΝΗΣΟΥ ΨΑΡΩΝ / ΧΙΟΥ', 1, 1, 'Initialization'),
       (268, 'ΑΝΔΡΟΥ / ΑΝΔΡΟΥ', 1, 1, 'Initialization'),
       (269, 'ΑΝΑΦΗΣ / ΘΗΡΑΣ', 1, 1, 'Initialization'),
       (270, 'ΘΗΡΑΣ / ΘΗΡΑΣ', 1, 1, 'Initialization'),
       (271, 'ΙΗΤΩΝ / ΘΗΡΑΣ', 1, 1, 'Initialization'),
       (272, 'ΣΙΚΙΝΟΥ / ΘΗΡΑΣ', 1, 1, 'Initialization'),
       (273, 'ΦΟΛΕΓΑΝΔΡΟΥ / ΘΗΡΑΣ', 1, 1, 'Initialization'),
       (274, 'ΑΓΑΘΟΝΗΣΙΟΥ / ΚΑΛΥΜΝΟΥ', 1, 1, 'Initialization'),
       (275, 'ΑΣΤΥΠΑΛΑΙΑΣ / ΚΑΛΥΜΝΟΥ', 1, 1, 'Initialization'),
       (276, 'ΚΑΛΥΜΝΙΩΝ / ΚΑΛΥΜΝΟΥ', 1, 1, 'Initialization'),
       (277, 'ΛΕΙΨΩΝ / ΚΑΛΥΜΝΟΥ', 1, 1, 'Initialization'),
       (278, 'ΛΕΡΟΥ / ΚΑΛΥΜΝΟΥ', 1, 1, 'Initialization'),
       (279, 'ΠΑΤΜΟΥ / ΚΑΛΥΜΝΟΥ', 1, 1, 'Initialization'),
       (280, 'ΚΑΡΠΑΘΟΥ / ΚΑΡΠΑΘΟΥ', 1, 1, 'Initialization'),
       (281, 'ΗΡΩΙΚΗΣ ΝΗΣΟΥ ΚΑΣΟΥ / ΚΑΡΠΑΘΟΥ', 1, 1, 'Initialization'),
       (282, 'ΚΕΑΣ / ΚΕΑΣ-ΚΥΘΝΟΥ', 1, 1, 'Initialization'),
       (283, 'ΚΥΘΝΟΥ / ΚΕΑΣ-ΚΥΘΝΟΥ', 1, 1, 'Initialization'),
       (284, 'ΚΩ / ΚΩ', 1, 1, 'Initialization'),
       (285, 'ΝΙΣΥΡΟΥ / ΚΩ', 1, 1, 'Initialization'),
       (286, 'ΚΙΜΩΛΟΥ / ΜΗΛΟΥ', 1, 1, 'Initialization'),
       (287, 'ΜΗΛΟΥ / ΜΗΛΟΥ', 1, 1, 'Initialization'),
       (288, 'ΣΕΡΙΦΟΥ / ΜΗΛΟΥ', 1, 1, 'Initialization'),
       (289, 'ΣΙΦΝΟΥ / ΜΗΛΟΥ', 1, 1, 'Initialization'),
       (290, 'ΜΥΚΟΝΟΥ / ΜΥΚΟΝΟΥ', 1, 1, 'Initialization'),
       (291, 'ΑΜΟΡΓΟΥ / ΝΑΞΟΥ', 1, 1, 'Initialization'),
       (292, 'ΝΑΞΟΥ & ΜΙΚΡΩΝ ΚΥΚΛΑΔΩΝ / ΝΑΞΟΥ', 1, 1, 'Initialization'),
       (293, 'ΑΝΤΙΠΑΡΟΥ / ΠΑΡΟΥ', 1, 1, 'Initialization'),
       (294, 'ΠΑΡΟΥ / ΠΑΡΟΥ', 1, 1, 'Initialization'),
       (295, 'ΜΕΓΙΣΤΗΣ / ΡΟΔΟΥ', 1, 1, 'Initialization'),
       (296, 'ΡΟΔΟΥ / ΡΟΔΟΥ', 1, 1, 'Initialization'),
       (297, 'ΣΥΜΗΣ / ΡΟΔΟΥ', 1, 1, 'Initialization'),
       (298, 'ΤΗΛΟΥ / ΡΟΔΟΥ', 1, 1, 'Initialization'),
       (299, 'ΧΑΛΚΗΣ / ΡΟΔΟΥ', 1, 1, 'Initialization'),
       (300, 'ΣΥΡΟΥ-ΕΡΜΟΥΠΟΛΗΣ / ΣΥΡΟΥ', 1, 1, 'Initialization'),
       (301, 'ΤΗΝΟΥ / ΤΗΝΟΥ', 1, 1, 'Initialization'),
       (302, 'ΑΡΧΑΝΩΝ - ΑΣΤΕΡΟΥΣΙΩΝ / ΗΡΑΚΛΕΙΟΥ', 1, 1, 'Initialization'),
       (303, 'ΒΙΑΝΝΟΥ / ΗΡΑΚΛΕΙΟΥ', 1, 1, 'Initialization'),
       (304, 'ΓΟΡΤΥΝΑΣ / ΗΡΑΚΛΕΙΟΥ', 1, 1, 'Initialization'),
       (305, 'ΗΡΑΚΛΕΙΟΥ / ΗΡΑΚΛΕΙΟΥ', 1, 1, 'Initialization'),
       (306, 'ΜΑΛΕΒΙΖΙΟΥ / ΗΡΑΚΛΕΙΟΥ', 1, 1, 'Initialization'),
       (307, 'ΜΙΝΩΑ ΠΕΔΙΑΔΑΣ / ΗΡΑΚΛΕΙΟΥ', 1, 1, 'Initialization'),
       (308, 'ΦΑΙΣΤΟΥ / ΗΡΑΚΛΕΙΟΥ', 1, 1, 'Initialization'),
       (309, 'ΧΕΡΣΟΝΗΣΟΥ / ΗΡΑΚΛΕΙΟΥ', 1, 1, 'Initialization'),
       (310, 'ΑΓΙΟΥ ΝΙΚΟΛΑΟΥ / ΛΑΣΙΘΙΟΥ', 1, 1, 'Initialization'),
       (311, 'ΙΕΡΑΠΕΤΡΑΣ / ΛΑΣΙΘΙΟΥ', 1, 1, 'Initialization'),
       (312, 'ΟΡΟΠΕΔΙΟΥ ΛΑΣΙΘΙΟΥ / ΛΑΣΙΘΙΟΥ', 1, 1, 'Initialization'),
       (313, 'ΣΗΤΕΙΑΣ / ΛΑΣΙΘΙΟΥ', 1, 1, 'Initialization'),
       (314, 'ΑΓΙΟΥ ΒΑΣΙΛΕΙΟΥ / ΡΕΘΥΜΝΟΥ', 1, 1, 'Initialization'),
       (315, 'ΑΜΑΡΙΟΥ / ΡΕΘΥΜΝΟΥ', 1, 1, 'Initialization'),
       (316, 'ΑΝΩΓΕΙΩΝ / ΡΕΘΥΜΝΟΥ', 1, 1, 'Initialization'),
       (317, 'ΜΥΛΟΠΟΤΑΜΟΥ / ΡΕΘΥΜΝΟΥ', 1, 1, 'Initialization'),
       (318, 'ΡΕΘΥΜΝΗΣ / ΡΕΘΥΜΝΟΥ', 1, 1, 'Initialization'),
       (319, 'ΑΠΟΚΟΡΩΝΟΥ / ΧΑΝΙΩΝ', 1, 1, 'Initialization'),
       (320, 'ΓΑΥΔΟΥ / ΧΑΝΙΩΝ', 1, 1, 'Initialization'),
       (321, 'ΚΑΝΤΑΝΟΥ - ΣΕΛΙΝΟΥ / ΧΑΝΙΩΝ', 1, 1, 'Initialization'),
       (322, 'ΚΙΣΣΑΜΟΥ / ΧΑΝΙΩΝ', 1, 1, 'Initialization'),
       (323, 'ΠΛΑΤΑΝΙΑ / ΧΑΝΙΩΝ', 1, 1, 'Initialization'),
       (324, 'ΣΦΑΚΙΩΝ / ΧΑΝΙΩΝ', 1, 1, 'Initialization'),
       (325, 'ΧΑΝΙΩΝ / ΧΑΝΙΩΝ', 1, 1, 'Initialization'),
       (326, 'ΒΟΡΕΙΑΣ ΚΕΡΚΥΡΑΣ / ΚΕΡΚΥΡΑΣ', 1, 1, 'Initialization'),
       (327, 'ΝΟΤΙΑΣ ΚΕΡΚΥΡΑΣ / ΚΕΡΚΥΡΑΣ', 1, 1, 'Initialization'),
       (328, 'ΛΗΞΟΥΡΙΟΥ / ΚΕΦΑΛΛΗΝΙΑΣ', 1, 1, 'Initialization'),
       (329, 'ΣΑΜΗΣ / ΚΕΦΑΛΛΗΝΙΑΣ', 1, 1, 'Initialization'),
       (330, 'ΒΕΛΒΕΝΤΟΥ / ΚΟΖΑΝΗΣ', 1, 1, 'Initialization'),
       (331, 'ΔΥΤΙΚΗΣ ΛΕΣΒΟΥ / ΛΕΣΒΟΥ', 1, 1, 'Initialization'),
       (332, 'ΔΥΤΙΚΗΣ ΣΑΜΟΥ / ΣΑΜΟΥ', 1, 1, 'Initialization'),
       (333, 'ΑΓΙΟ ΟΡΟΣ (ΑΥΤΟΔΙΟΙΚΗΤΟ) / ΧΑΛΚΙΔΙΚΗΣ', 1, 1, 'Initialization'),
       (1, 'DOXATOU / DRAMAS', 2, 1, 'Initialization'),
       (2, 'DRAMAS / DRAMAS', 2, 1, 'Initialization'),
       (3, 'KATO NEVROKOPIOU / DRAMAS', 2, 1, 'Initialization'),
       (4, 'PARANESTIOU / DRAMAS', 2, 1, 'Initialization'),
       (5, 'PROSOTSANIS / DRAMAS', 2, 1, 'Initialization'),
       (6, 'ALEXANDROUPOLIS / EVROU', 2, 1, 'Initialization'),
       (7, 'DIDYMOTEICHOU / EVROU', 2, 1, 'Initialization'),
       (8, 'ORESTIADAS / EVROU', 2, 1, 'Initialization'),
       (9, 'SAMOTHRAKIS / EVROU', 2, 1, 'Initialization'),
       (10, 'SOUFLIOU / EVROU', 2, 1, 'Initialization'),
       (11, 'THASOU / THASOU', 2, 1, 'Initialization'),
       (12, 'KAVALAS / KAVALAS', 2, 1, 'Initialization'),
       (13, 'NESTOU / KAVALAS', 2, 1, 'Initialization'),
       (14, 'PANGAIOU / KAVALAS', 2, 1, 'Initialization'),
       (15, 'AVDIRON / XANTHIS', 2, 1, 'Initialization'),
       (16, 'MYKIS / XANTHIS', 2, 1, 'Initialization'),
       (17, 'XANTHIS / XANTHIS', 2, 1, 'Initialization'),
       (18, 'TOPEIROU / XANTHIS', 2, 1, 'Initialization'),
       (19, 'ARRIANON / RODOPIS', 2, 1, 'Initialization'),
       (20, 'IASMOU / RODOPIS', 2, 1, 'Initialization'),
       (21, 'KOMOTINIS / RODOPIS', 2, 1, 'Initialization'),
       (22, 'MARONEIAS-SAPON / RODOPIS', 2, 1, 'Initialization'),
       (23, 'ALEXANDREIAS / IMATHIAS', 2, 1, 'Initialization'),
       (24, 'VEROIAS / IMATHIAS', 2, 1, 'Initialization'),
       (25, 'IROIKIS POLEOS NAOUSAS/ IMATHIAS', 2, 1, 'Initialization'),
       (26, 'AMPELOKIPON-MENEMENIS / THESSALONIKIS', 2, 1, 'Initialization'),
       (27, 'VOLVIS / THESSALONIKIS', 2, 1, 'Initialization'),
       (28, 'DELTA / THESSALONIKIS', 2, 1, 'Initialization'),
       (29, 'THERMAIKOU / THESSALONIKIS', 2, 1, 'Initialization'),
       (30, 'THERMIS / THESSALONIKIS', 2, 1, 'Initialization'),
       (31, 'THESSALONIKIS / THESSALONIKIS', 2, 1, 'Initialization'),
       (32, 'KALAMARIAS / THESSALONIKIS', 2, 1, 'Initialization'),
       (33, 'KORDELIOU-EVOSMOU / THESSALONIKIS', 2, 1, 'Initialization'),
       (34, 'LAGKADA / THESSALONIKIS', 2, 1, 'Initialization'),
       (35, 'NEAPOLIS-SYKEON / THESSALONIKIS', 2, 1, 'Initialization'),
       (36, 'PAVLOU MELA / THESSALONIKIS', 2, 1, 'Initialization'),
       (37, 'PYLAIAS-CHORTIATI / THESSALONIKIS', 2, 1, 'Initialization'),
       (38, 'CHALKIDONOS / THESSALONIKIS', 2, 1, 'Initialization'),
       (39, 'ORAIOKASTROU / THESSALONIKIS', 2, 1, 'Initialization'),
       (40, 'KILKIS / KILKIS', 2, 1, 'Initialization'),
       (41, 'PAIONIAS / KILKIS', 2, 1, 'Initialization'),
       (42, 'ALMOPIAS / PELLAS', 2, 1, 'Initialization'),
       (43, 'EDESSAS / PELLAS', 2, 1, 'Initialization'),
       (44, 'PELLAS / PELLAS', 2, 1, 'Initialization'),
       (45, 'SKYDRAS / PELLAS', 2, 1, 'Initialization'),
       (46, 'DIOU-OLYMPOU / PIERIAS', 2, 1, 'Initialization'),
       (47, 'KATERINIS / PIERIAS', 2, 1, 'Initialization'),
       (48, 'PYDNAS-KOLINDROU / PIERIAS', 2, 1, 'Initialization'),
       (49, 'AMFIPOLIS / SERRON', 2, 1, 'Initialization'),
       (50, 'VISALTIAS / SERRON', 2, 1, 'Initialization'),
       (51, 'EMMANOUIL PAPPA / SERRON', 2, 1, 'Initialization'),
       (52, 'IRAKLEIAS / SERRON', 2, 1, 'Initialization'),
       (53, 'NEAS ZICHNIS / SERRON', 2, 1, 'Initialization'),
       (54, 'SERRON / SERRON', 2, 1, 'Initialization'),
       (55, 'SINTIKIS / SERRON', 2, 1, 'Initialization'),
       (56, 'ARISTOTELI / CHALKIDIKIS', 2, 1, 'Initialization'),
       (57, 'KASSANDRAS / CHALKIDIKIS', 2, 1, 'Initialization'),
       (58, 'NEAS PROPONTIDAS / CHALKIDIKIS', 2, 1, 'Initialization'),
       (59, 'POLYGYROU / CHALKIDIKIS', 2, 1, 'Initialization'),
       (60, 'SITHONIAS / CHALKIDIKIS', 2, 1, 'Initialization'),
       (61, 'GREVENON / GREVENON', 2, 1, 'Initialization'),
       (62, 'DESKATIS / GREVENON', 2, 1, 'Initialization'),
       (63, 'KASTORIAS / KASTORIAS', 2, 1, 'Initialization'),
       (64, 'NESTORIOU / KASTORIAS', 2, 1, 'Initialization'),
       (65, 'ARGOUS ORESTIKOU / KASTORIAS', 2, 1, 'Initialization'),
       (66, 'VOIOU / KOZANIS', 2, 1, 'Initialization'),
       (67, 'EORDAIAS / KOZANIS', 2, 1, 'Initialization'),
       (68, 'KOZANIS / KOZANIS', 2, 1, 'Initialization'),
       (69, 'SERVION / KOZANIS', 2, 1, 'Initialization'),
       (70, 'AMYNTAIOU / FLORINAS', 2, 1, 'Initialization'),
       (71, 'PRESPON / FLORINAS', 2, 1, 'Initialization'),
       (72, 'FLORINAS / FLORINAS', 2, 1, 'Initialization'),
       (73, 'ARTAION / ARTAS', 2, 1, 'Initialization'),
       (74, 'GEORGIOU KARAISKAKI / ARTAS', 2, 1, 'Initialization'),
       (75, 'KENTRIKON TZOUMERKON / ARTAS', 2, 1, 'Initialization'),
       (76, 'NIKOLAOU SKOUFA / ARTAS', 2, 1, 'Initialization'),
       (77, 'IGOUMENITSAS / THESPROTIAS', 2, 1, 'Initialization'),
       (78, 'SOULIOU / THESPROTIAS', 2, 1, 'Initialization'),
       (79, 'FILIATON / THESPROTIAS', 2, 1, 'Initialization'),
       (80, 'VOREION TZOUMERKON / IOANNINON', 2, 1, 'Initialization'),
       (81, 'DODONIS / IOANNINON', 2, 1, 'Initialization'),
       (82, 'ZAGORIOU / IOANNINON', 2, 1, 'Initialization'),
       (83, 'ZITSAS / IOANNINON', 2, 1, 'Initialization'),
       (84, 'IOANNITON / IOANNINON', 2, 1, 'Initialization'),
       (85, 'KONITSAS / IOANNINON', 2, 1, 'Initialization'),
       (86, 'METSOVOU / IOANNINON', 2, 1, 'Initialization'),
       (87, 'POGONIOU / IOANNINON', 2, 1, 'Initialization'),
       (88, 'ZIROU / PREVEZAS', 2, 1, 'Initialization'),
       (89, 'PARGAS / PREVEZAS', 2, 1, 'Initialization'),
       (90, 'PREVEZAS / PREVEZAS', 2, 1, 'Initialization'),
       (91, 'ARGITHEAS / KARDITSAS', 2, 1, 'Initialization'),
       (92, 'KARDITSAS / KARDITSAS', 2, 1, 'Initialization'),
       (93, 'LIMNIS PLASTIRA / KARDITSAS', 2, 1, 'Initialization'),
       (94, 'MOUZAKIOU / KARDITSAS', 2, 1, 'Initialization'),
       (95, 'PALAMA / KARDITSAS', 2, 1, 'Initialization'),
       (96, 'SOFADON / KARDITSAS', 2, 1, 'Initialization'),
       (97, 'AGIAS / LARISAS', 2, 1, 'Initialization'),
       (98, 'ELASSONAS / LARISAS', 2, 1, 'Initialization'),
       (99, 'KILELER / LARISAS', 2, 1, 'Initialization'),
       (100, 'LARISAION / LARISAS', 2, 1, 'Initialization'),
       (101, 'TEMPON / LARISAS', 2, 1, 'Initialization'),
       (102, 'TYRNAVOU / LARISAS', 2, 1, 'Initialization'),
       (103, 'FARSALON / LARISAS', 2, 1, 'Initialization'),
       (104, 'ALMYROU / MAGNISIAS', 2, 1, 'Initialization'),
       (105, 'VOLOU / MAGNISIAS', 2, 1, 'Initialization'),
       (106, 'ZAGORAS-MOURESIOU / MAGNISIAS', 2, 1, 'Initialization'),
       (107, 'NOTIOU PILIOU / MAGNISIAS', 2, 1, 'Initialization'),
       (108, 'RIGA FERAIOU / MAGNISIAS', 2, 1, 'Initialization'),
       (109, 'ALONNISOU / SPORADON', 2, 1, 'Initialization'),
       (110, 'SKIATHOU / SPORADON', 2, 1, 'Initialization'),
       (111, 'SKOPELOU / SPORADON', 2, 1, 'Initialization'),
       (112, 'METEORON / TRIKALON', 2, 1, 'Initialization'),
       (113, 'PYLIS / TRIKALON', 2, 1, 'Initialization'),
       (114, 'TRIKKAION / TRIKALON', 2, 1, 'Initialization'),
       (115, 'FARKADONAS / TRIKALON', 2, 1, 'Initialization'),
       (116, 'ZAKYNTHOU / ZAKYNTHOU', 2, 1, 'Initialization'),
       (117, 'ITHAKIS / ITHAKIS', 2, 1, 'Initialization'),
       (118, 'KENTRIKIS KERKYRAS KAI DIAPONTION NISON / KERKYRAS', 2, 1, 'Initialization'),
       (119, 'PAXON / KERKYRAS', 2, 1, 'Initialization'),
       (120, 'ARGOSTOLIOU / KEFALLINIAS', 2, 1, 'Initialization'),
       (121, 'LEFKADAS / LEFKADAS', 2, 1, 'Initialization'),
       (122, 'MEGANISIOU / LEFKADAS', 2, 1, 'Initialization'),
       (123, 'AGRINIOU / AITOLOAKARNANIAS', 2, 1, 'Initialization'),
       (124, 'AKTIOU-VONITSAS / AITOLOAKARNANIAS', 2, 1, 'Initialization'),
       (125, 'AMFILOCHIAS / AITOLOAKARNANIAS', 2, 1, 'Initialization'),
       (126, 'THERMOU / AITOLOAKARNANIAS', 2, 1, 'Initialization'),
       (127, 'IERAS POLIS MESOLONGIOU / AITOLOAKARNANIAS', 2, 1, 'Initialization'),
       (128, 'NAFPAKTIAS / AITOLOAKARNANIAS', 2, 1, 'Initialization'),
       (129, 'XIROMEROU / AITOLOAKARNANIAS', 2, 1, 'Initialization'),
       (130, 'AIGIALEIAS / ACHAIAS', 2, 1, 'Initialization'),
       (131, 'DYTIKIS ACHAIAS / ACHAIAS', 2, 1, 'Initialization'),
       (132, 'ERYMANTHOU / ACHAIAS', 2, 1, 'Initialization'),
       (133, 'KALAVRYTON / ACHAIAS', 2, 1, 'Initialization'),
       (134, 'PATREON / ACHAIAS', 2, 1, 'Initialization'),
       (135, 'ANDRAVIDAS-KYLLINIS / ILEIAS', 2, 1, 'Initialization'),
       (136, 'ANDRITSAINAS-KRESTENON / ILEIAS', 2, 1, 'Initialization'),
       (137, 'ARCHAIAS OLYMPIAS / ILEIAS', 2, 1, 'Initialization'),
       (138, 'ZACHAROS / ILEIAS', 2, 1, 'Initialization'),
       (139, 'ILIDAS / ILEIAS', 2, 1, 'Initialization'),
       (140, 'PINEIOU / ILEIAS', 2, 1, 'Initialization'),
       (141, 'PYRGOU / ILEIAS', 2, 1, 'Initialization'),
       (142, 'ALIARTOU-THESPIEON / VOIOTIAS', 2, 1, 'Initialization'),
       (143, 'DISTOMOU - ARACHOVAS - ANTIKYRAS / VOIOTIAS', 2, 1, 'Initialization'),
       (144, 'THIVAION / VOIOTIAS', 2, 1, 'Initialization'),
       (145, 'LEVADEON / VOIOTIAS', 2, 1, 'Initialization'),
       (146, 'ORCHOMENOU / VOIOTIAS', 2, 1, 'Initialization'),
       (147, 'TANAGRAS / VOIOTIAS', 2, 1, 'Initialization'),
       (148, 'DIRFYON-MESSAPION / EVVOIAS', 2, 1, 'Initialization'),
       (149, 'ERETRIAS / EVVOIAS', 2, 1, 'Initialization'),
       (150, 'ISTIAIAS-AIDIPSOU / EVVOIAS', 2, 1, 'Initialization'),
       (151, 'KARYSTOU / EVVOIAS', 2, 1, 'Initialization'),
       (152, 'KYMIS-ALIVERIOU / EVVOIAS', 2, 1, 'Initialization'),
       (153, 'MANTOUDIOU-LIMNIS-AGIAS ANNAS / EVVOIAS', 2, 1, 'Initialization'),
       (154, 'SKYROU / EVVOIAS', 2, 1, 'Initialization'),
       (155, 'CHALKIDEON / EVVOIAS', 2, 1, 'Initialization'),
       (156, 'AGRAFON / EVRYTANIAS', 2, 1, 'Initialization'),
       (157, 'KARPENISIOU / EVRYTANIAS', 2, 1, 'Initialization'),
       (158, 'AMFIKLEIAS - ELATEIAS / FTHIOTIDAS', 2, 1, 'Initialization'),
       (159, 'DOMOKOU / FTHIOTIDAS', 2, 1, 'Initialization'),
       (160, 'LAMIEON / FTHIOTIDAS', 2, 1, 'Initialization'),
       (161, 'LOKRON / FTHIOTIDAS', 2, 1, 'Initialization'),
       (162, 'MAKRAKOMIS / FTHIOTIDAS', 2, 1, 'Initialization'),
       (163, 'KAMENON VOURLON / FTHIOTIDAS', 2, 1, 'Initialization'),
       (164, 'STYLIDAS / FTHIOTIDAS', 2, 1, 'Initialization'),
       (165, 'DELFON / FOKIDAS', 2, 1, 'Initialization'),
       (166, 'DORIDOS / FOKIDAS', 2, 1, 'Initialization'),
       (167, 'AGIAS PARASKEVIS / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (168, 'AMAROUSIOU / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (169, 'VRILISSION / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (170, 'IRAKLEIOU / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (171, 'KIFISIAS / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (172, 'LYKOVRYSIS - PEFKIS / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (173, 'METAMORFOSEOS / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (174, 'NEAS IONIAS / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (175, 'PAPAGOU - CHOLARGOU / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (176, 'PENTELIS / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (177, 'FILOTHEIS - PSYCHIKOU / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (178, 'CHALANDRIOU / VOREIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (179, 'AGIAS VARVARAS / DYTIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (180, 'AGION ANARGYRON - KAMATEROU / DYTIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (181, 'AIGALEO / DYTIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (182, 'ILIOU / DYTIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (183, 'PERISTERIOU / DYTIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (184, 'PETROUPOLEOS / DYTIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (185, 'CHAIDARIOU / DYTIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (186, 'ATHINAION / KENTRIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (187, 'VYRONOS / KENTRIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (188, 'GALATSIOU / KENTRIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (189, 'DAFNIS - YMITTOU / KENTRIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (190, 'ZOGRAFOU / KENTRIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (191, 'ILIOUPOLEOS / KENTRIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (192, 'KAISARIANIS / KENTRIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (193, 'NEAS FILADELFEIAS - NEAS CHALKIDONAS / KENTRIKOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (194, 'AGIOU DIMITRIOU / NOTIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (195, 'ALIMOU / NOTIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (196, 'GLYFADAS / NOTIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (197, 'ELLINIKOU - ARGYROUPOLIS / NOTIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (198, 'KALLITHEAS / NOTIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (199, 'MOSCHATOU - TAVROU / NOTIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (200, 'NEAS SMYRNIS / NOTIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (201, 'PALAIOU FALIROU / NOTIOU TOMEA ATHINON', 2, 1, 'Initialization'),
       (202, 'KERATSINIOU - DRAPETSONAS / PEIRAIOS', 2, 1, 'Initialization'),
       (203, 'KORYDALLOU / PEIRAIOS', 2, 1, 'Initialization'),
       (204, 'NIKAIAS - AGIOU IOANNI RENTI / PEIRAIOS', 2, 1, 'Initialization'),
       (205, 'PEIRAIOS / PEIRAIOS', 2, 1, 'Initialization'),
       (206, 'PERAMATOS / PEIRAIOS', 2, 1, 'Initialization'),
       (207, 'AGKISTRIOU / NISON', 2, 1, 'Initialization'),
       (208, 'AIGINAS / NISON', 2, 1, 'Initialization'),
       (209, 'KYTHIRON / NISON', 2, 1, 'Initialization'),
       (210, 'POROU / NISON', 2, 1, 'Initialization'),
       (211, 'SALAMINAS / NISON', 2, 1, 'Initialization'),
       (212, 'SPETSON / NISON', 2, 1, 'Initialization'),
       (213, 'TROIZINIAS-METHANON / NISON', 2, 1, 'Initialization'),
       (214, 'YDRAS / NISON', 2, 1, 'Initialization'),
       (215, 'ACHARNON / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (216, 'VARIS - VOULAS - VOULIAGMENIS / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (217, 'DIONYSOU / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (218, 'KROPIAS / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (219, 'LAVREOTIKIS / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (220, 'MARATHONOS / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (221, 'MARKOPOULOU MESOGAIAS / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (222, 'PAIANIAS / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (223, 'PALLINIS / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (224, 'RAFINAS - PIKERMIOU / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (225, 'SARONIKOU / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (226, 'SPATON - ARTEMIDOS / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (227, 'OROPOU / ANATOLIKIS ATTIKIS', 2, 1, 'Initialization'),
       (228, 'ASPROPYRGOU / DYTIKIS ATTIKIS', 2, 1, 'Initialization'),
       (229, 'ELEFSINAS / DYTIKIS ATTIKIS', 2, 1, 'Initialization'),
       (230, 'MANDRAS - EIDYLLIAS / DYTIKIS ATTIKIS', 2, 1, 'Initialization'),
       (231, 'MEGAREON / DYTIKIS ATTIKIS', 2, 1, 'Initialization'),
       (232, 'FYLIS / DYTIKIS ATTIKIS', 2, 1, 'Initialization'),
       (233, 'ARGOUS-MYKINON / ARGOLIDAS', 2, 1, 'Initialization'),
       (234, 'EPIDAVROU / ARGOLIDAS', 2, 1, 'Initialization'),
       (235, 'ERMIONIDAS / ARGOLIDAS', 2, 1, 'Initialization'),
       (236, 'NAFPLIEON / ARGOLIDAS', 2, 1, 'Initialization'),
       (237, 'VOREIAS KYNOURIAS / ARKADIAS', 2, 1, 'Initialization'),
       (238, 'GORTYNIAS / ARKADIAS', 2, 1, 'Initialization'),
       (239, 'MEGALOPOLIS / ARKADIAS', 2, 1, 'Initialization'),
       (240, 'NOTIAS KYNOURIAS / ARKADIAS', 2, 1, 'Initialization'),
       (241, 'TRIPOLIS / ARKADIAS', 2, 1, 'Initialization'),
       (242, 'VELOU-VOCHAS / KORINTHIAS', 2, 1, 'Initialization'),
       (243, 'KORINTHION / KORINTHIAS', 2, 1, 'Initialization'),
       (244, 'LOUTRAKIOU-PERACHORAS-AGION THEODORON / KORINTHIAS', 2, 1, 'Initialization'),
       (245, 'NEMEAS / KORINTHIAS', 2, 1, 'Initialization'),
       (246, 'XYLOKASTROU-EVROSTINIS / KORINTHIAS', 2, 1, 'Initialization'),
       (247, 'SIKYONION / KORINTHIAS', 2, 1, 'Initialization'),
       (248, 'ANATOLIKIS MANIS / LAKONIAS', 2, 1, 'Initialization'),
       (249, 'ELAFONISOU / LAKONIAS', 2, 1, 'Initialization'),
       (250, 'EVROTA / LAKONIAS', 2, 1, 'Initialization'),
       (251, 'MONEMVASIAS / LAKONIAS', 2, 1, 'Initialization'),
       (252, 'SPARTIS / LAKONIAS', 2, 1, 'Initialization'),
       (253, 'DYTIKIS MANIS / MESSINIAS', 2, 1, 'Initialization'),
       (254, 'KALAMATAS / MESSINIAS', 2, 1, 'Initialization'),
       (255, 'MESSINIS / MESSINIAS', 2, 1, 'Initialization'),
       (256, 'OICHALIAS / MESSINIAS', 2, 1, 'Initialization'),
       (257, 'PYLOU-NESTOROS / MESSINIAS', 2, 1, 'Initialization'),
       (258, 'TRIFYLIAS / MESSINIAS', 2, 1, 'Initialization'),
       (259, 'IKARIAS / IKARIAS', 2, 1, 'Initialization'),
       (260, 'FOURNON KORSEON / IKARIAS', 2, 1, 'Initialization'),
       (261, 'MYTILINIS / LESVOU', 2, 1, 'Initialization'),
       (262, 'AGIOU EFSTRATIOU / LIMNOU', 2, 1, 'Initialization'),
       (263, 'LIMNOU / LIMNOU', 2, 1, 'Initialization'),
       (264, 'ANATOLIKIS SAMOU / SAMOU', 2, 1, 'Initialization'),
       (265, 'OINOUSSON / CHIOU', 2, 1, 'Initialization'),
       (266, 'CHIOU / CHIOU', 2, 1, 'Initialization'),
       (267, 'IROIKIS NISOU PSARON / CHIOU', 2, 1, 'Initialization'),
       (268, 'ANDROU / ANDROU', 2, 1, 'Initialization'),
       (269, 'ANAFIS / THIRAS', 2, 1, 'Initialization'),
       (270, 'THIRAS / THIRAS', 2, 1, 'Initialization'),
       (271, 'IITON / THIRAS', 2, 1, 'Initialization'),
       (272, 'SIKINOU / THIRAS', 2, 1, 'Initialization'),
       (273, 'FOLEGANDROU / THIRAS', 2, 1, 'Initialization'),
       (274, 'AGATHONISIOU / KALYMNOU', 2, 1, 'Initialization'),
       (275, 'ASTYPALAIAS / KALYMNOU', 2, 1, 'Initialization'),
       (276, 'KALYMNION / KALYMNOU', 2, 1, 'Initialization'),
       (277, 'LEIPSON / KALYMNOU', 2, 1, 'Initialization'),
       (278, 'LEROU / KALYMNOU', 2, 1, 'Initialization'),
       (279, 'PATMOU / KALYMNOU', 2, 1, 'Initialization'),
       (280, 'KARPATHOU / KARPATHOU', 2, 1, 'Initialization'),
       (281, 'IROIKIS NISOU KASOU / KARPATHOU', 2, 1, 'Initialization'),
       (282, 'KEAS / KEAS-KYTHNOU', 2, 1, 'Initialization'),
       (283, 'KYTHNOU / KEAS-KYTHNOU', 2, 1, 'Initialization'),
       (284, 'KO / KO', 2, 1, 'Initialization'),
       (285, 'NISYROU / KO', 2, 1, 'Initialization'),
       (286, 'KIMOLOU / MILOU', 2, 1, 'Initialization'),
       (287, 'MILOU / MILOU', 2, 1, 'Initialization'),
       (288, 'SERIFOU / MILOU', 2, 1, 'Initialization'),
       (289, 'SIFNOU / MILOU', 2, 1, 'Initialization'),
       (290, 'MYKONOU / MYKONOU', 2, 1, 'Initialization'),
       (291, 'AMORGOU / NAXOU', 2, 1, 'Initialization'),
       (292, 'NAXOU & MIKRON KYKLADON / NAXOU', 2, 1, 'Initialization'),
       (293, 'ANTIPAROU / PAROU', 2, 1, 'Initialization'),
       (294, 'PAROU / PAROU', 2, 1, 'Initialization'),
       (295, 'MEGISTIS / RODOU', 2, 1, 'Initialization'),
       (296, 'RODOU / RODOU', 2, 1, 'Initialization'),
       (297, 'SYMIS / RODOU', 2, 1, 'Initialization'),
       (298, 'TILOU / RODOU', 2, 1, 'Initialization'),
       (299, 'CHALKIS / RODOU', 2, 1, 'Initialization'),
       (300, 'SYROU-ERMOUPOLIS / SYROU', 2, 1, 'Initialization'),
       (301, 'TINOU / TINOU', 2, 1, 'Initialization'),
       (302, 'ARCHANON - ASTEROUSION / IRAKLEIOU', 2, 1, 'Initialization'),
       (303, 'VIANNOU / IRAKLEIOU', 2, 1, 'Initialization'),
       (304, 'GORTYNAS / IRAKLEIOU', 2, 1, 'Initialization'),
       (305, 'IRAKLEIOU / IRAKLEIOU', 2, 1, 'Initialization'),
       (306, 'MALEVIZIOU / IRAKLEIOU', 2, 1, 'Initialization'),
       (307, 'MINOA PEDIADAS / IRAKLEIOU', 2, 1, 'Initialization'),
       (308, 'FAISTOU / IRAKLEIOU', 2, 1, 'Initialization'),
       (309, 'CHERSONISOU / IRAKLEIOU', 2, 1, 'Initialization'),
       (310, 'AGIOU NIKOLAOU / LASITHIOU', 2, 1, 'Initialization'),
       (311, 'IERAPETRAS / LASITHIOU', 2, 1, 'Initialization'),
       (312, 'OROPEDIOU LASITHIOU / LASITHIOU', 2, 1, 'Initialization'),
       (313, 'SITEIAS / LASITHIOU', 2, 1, 'Initialization'),
       (314, 'AGIOU VASILEIOU / RETHYMNOU', 2, 1, 'Initialization'),
       (315, 'AMARIOU / RETHYMNOU', 2, 1, 'Initialization'),
       (316, 'ANOGEION / RETHYMNOU', 2, 1, 'Initialization'),
       (317, 'MYLOPOTAMOU / RETHYMNOU', 2, 1, 'Initialization'),
       (318, 'RETHYMNIS / RETHYMNOU', 2, 1, 'Initialization'),
       (319, 'APOKORONOU / CHANION', 2, 1, 'Initialization'),
       (320, 'GAVDOU / CHANION', 2, 1, 'Initialization'),
       (321, 'KANTANOU - SELINOU / CHANION', 2, 1, 'Initialization'),
       (322, 'KISSAMOU / CHANION', 2, 1, 'Initialization'),
       (323, 'PLATANIA / CHANION', 2, 1, 'Initialization'),
       (324, 'SFAKION / CHANION', 2, 1, 'Initialization'),
       (325, 'CHANION / CHANION', 2, 1, 'Initialization'),
       (326, 'VOREIAS KERKYRAS / KERKYRAS', 2, 1, 'Initialization'),
       (327, 'NOTIAS KERKYRAS / KERKYRAS', 2, 1, 'Initialization'),
       (328, 'LIXOURIOU / KEFALLINIAS', 2, 1, 'Initialization'),
       (329, 'SAMIS / KEFALLINIAS', 2, 1, 'Initialization'),
       (330, 'VELVENTOU / KOZANIS', 2, 1, 'Initialization'),
       (331, 'DYTIKIS LESVOU / LESVOU', 2, 1, 'Initialization'),
       (332, 'DYTIKIS SAMOU / SAMOU', 2, 1, 'Initialization'),
       (333, 'MOUNT ATHOS (SELF-GOVERNANCE) / CHALKIDIKIS', 2, 1, 'Initialization');

INSERT INTO company (name, city, street, country_id, prefecture_id, municipality_id, street_number, region_id,
                     postal_code, afm, legal_type_id, date_incorporated, gemi_number, company_status_id,
                     last_user_id, change_reason, date_created, last_updated)
VALUES ('Παπαδόπουλος Εμπορική ΑΕ', 'Αθήνα', 'Λεωφόρος Συγγρού', 154, 5, 186, '127', 9,
        '11745', '100000003', 2, '2015-03-15', '045123678000', 3, 1, 'Initialization', now(), now()),
       ('Νικολαΐδης & Συνεργάτες ΙΚΕ', 'Θεσσαλονίκη', 'Τσιμισκή', 154, 19, 31, '85', 2,
        '54623', '100002008', 20, '2018-06-20', '078945612000', 3, 2, 'Initialization', now(), now()),
       ('Γεωργίου Τεχνική ΕΠΕ', 'Πάτρα', 'Κορίνθου', 154, 6, 134, '245', 7,
        '26441', '100064000', 9, '2012-09-10', '032165498000', 3, 3, 'Initialization', now(), now()),
       ('Δημητρίου Logistics ΑΕ', 'Ηράκλειο', 'Λεωφόρος Κνωσού', 154, 17, 305, '52', 13,
        '71307', '100045008', 2, '2010-11-25', '087654321000', 3, 4, 'Initialization', now(), now()),
       ('Κωνσταντίνου Αγροτική ΟΕ', 'Λάρισα', 'Παπαναστασίου', 154, 31, 100, '18', 5,
        '41222', '100054005', 3, '2016-04-12', '065478912000', 3, 5, 'Initialization', now(), now()),
       ('Αντωνίου Τεχνολογίες ΑΕ', 'Αθήνα', 'Πανεπιστημίου', 154, 5, 186, '64', 9,
        '10679', '100038005', 2, '2019-02-28', '012348765000', 3, 1, 'Initialization', now(), now()),
       ('Μιχαηλίδης Ναυτιλιακή ΙΚΕ', 'Πειραιάς', 'Ακτή Μιαούλη', 154, 5, 205, '92', 9,
        '18538', '100030007', 20, '2014-07-08', '045612378000', 3, 2, 'Initialization', now(), now()),
       ('Χριστοδούλου Οικοδομική ΕΠΕ', 'Ιωάννινα', 'Δωδώνης', 154, 20, 84, '33', 4,
        '45221', '100037008', 9, '2011-12-15', '078912345000', 3, 3, 'Initialization', now(), now()),
       ('Σταυρίδης Τρόφιμα ΑΕ', 'Καβάλα', 'Ελευθερίας', 154, 21, 12, '156', 1,
        '65403', '100043003', 2, '2013-05-22', '032145698000', 3, 4, 'Initialization', now(), now()),
       ('Βασιλείου Φαρμακευτική ΙΚΕ', 'Ρόδος', '28ης Οκτωβρίου', 154, 10, 296, '74', 12,
        '85100', '100053008', 20, '2017-08-30', '096325874000', 3, 5, 'Initialization', now(), now()),
       ('Ιωάννου Συμβουλευτική ΑΕ', 'Αθήνα', 'Σταδίου', 154, 5, 186, '42', 9,
        '10564', '100031004', 2, '2020-01-14', '015935748000', 3, 1, 'Initialization', now(), now()),
       ('Ανδρέου Ενέργεια ΕΠΕ', 'Βόλος', 'Ιάσονος', 154, 35, 105, '201', 5,
        '38333', '100063002', 9, '2009-10-05', '074185296000', 3, 2, 'Initialization', now(), now()),
       ('Πετρίδης Μεταφορές ΙΚΕ', 'Κοζάνη', 'Μεταμορφώσεως', 154, 27, 68, '13', 3,
        '50100', '100042006', 20, '2015-11-18', '085296374000', 3, 3, 'Initialization', now(), now()),
       ('Λαζάρου Ξενοδοχειακή ΑΕ', 'Χανιά', 'Κυδωνίας', 154, 50, 325, '88', 13,
        '73135', '100046005', 2, '2008-03-27', '036925814000', 3, 4, 'Initialization', now(), now()),
       ('Ευαγγέλου Πληροφορική ΙΚΕ', 'Λαμία', 'Αθηνών', 154, 46, 160, '67', 8,
        '35100', '100036000', 20, '2021-06-09', '025814736000', 3, 5, 'Initialization', now(), now());

INSERT INTO person (name, surname, afm, city, street, country_id, prefecture_id, municipality_id, street_number,
                    region_id, postal_code, birth_date, birth_place, identity_number, phone_number,
                    last_user_id, change_reason, date_created, last_updated)
VALUES ('Γιώργος', 'Παπαδόπουλος', '100065007', 'Αθήνα', 'Πατησίων', 154, 5, 186, '45', 9, '10434', '1985-03-12',
        'Αθήνα', 'ΑΕ123456', '2101234567', 1, 'Initialization', now(), now()),
       ('Μαρία', 'Νικολάου', '100034006', 'Θεσσαλονίκη', 'Εγνατία', 154, 19, 31, '78', 2, '54630', '1990-07-22',
        'Θεσσαλονίκη', 'ΑΚ234567', '2310123456', 2, 'Initialization', now(), now()),
       ('Νίκος', 'Γεωργίου', '100041009', 'Πάτρα', 'Ρήγα Φεραίου', 154, 6, 134, '123', 7, '26221', '1978-11-05',
        'Πάτρα', 'ΑΒ345678', '2610234567', 3, 'Initialization', now(), now()),
       ('Ελένη', 'Δημητρίου', '100000027', 'Ηράκλειο', 'Καλοκαιρινού', 154, 17, 305, '89', 13, '71202', '1992-05-18',
        'Ηράκλειο', 'ΑΗ456789', '2810345678', 4, 'Initialization', now(), now()),
       ('Κώστας', 'Ιωάννου', '100049007', 'Λάρισα', 'Κύπρου', 154, 31, 100, '34', 5, '41222', '1988-09-30', 'Λάρισα',
        'ΑΙ567891', '2410456789', 5, 'Initialization', now(), now()),
       ('Σοφία', 'Αντωνίου', '100052000', 'Αθήνα', 'Ακαδημίας', 154, 5, 186, '56', 9, '10672', '1995-02-14', 'Πειραιάς',
        'ΑΜ678912', '2102345678', 1, 'Initialization', now(), now()),
       ('Δημήτρης', 'Μιχαηλίδης', '100001024', 'Βόλος', 'Αργοναυτών', 154, 35, 105, '91', 5, '38221', '1982-12-08',
        'Βόλος', 'ΑΝ789123', '2421234567', 2, 'Initialization', now(), now()),
       ('Κατερίνα', 'Χριστοδούλου', '100058004', 'Ιωάννινα', 'Ζωσιμαία', 154, 20, 84, '67', 4, '45444', '1991-06-25',
        'Ιωάννινα', 'ΑΟ891234', '2651345678', 3, 'Initialization', now(), now()),
       ('Αντώνης', 'Σταυρίδης', '100062005', 'Καβάλα', 'Βενιζέλου', 154, 21, 12, '112', 1, '65302', '1986-04-17',
        'Καβάλα', 'ΑΠ912345', '2510456789', 4, 'Initialization', now(), now()),
       ('Αικατερίνη', 'Βασιλείου', '100029008', 'Ρόδος', 'Σόλωνος', 154, 10, 296, '45', 12, '85100', '1993-08-03',
        'Ρόδος', 'ΑΡ123987', '2241234567', 5, 'Initialization', now(), now()),
       ('Παναγιώτης', 'Κωνσταντίνου', '100035003', 'Πειραιάς', 'Φιλίππου', 154, 5, 205, '78', 9, '18531', '1980-10-20',
        'Αθήνα', 'ΑΣ234876', '2104567891', 1, 'Initialization', now(), now()),
       ('Αγγελική', 'Πετρίδης', '345765432', 'Κοζάνη', 'Νίκης', 154, 27, 68, '23', 3, '50100', '1994-01-15', 'Κοζάνη',
        'ΑΤ345765', '2461345678', 2, 'Initialization', now(), now()),
       ('Θανάσης', 'Λαζάρου', '100044000', 'Χανιά', 'Χαλιδών', 154, 50, 325, '67', 13, '73100', '1987-07-09', 'Χανιά',
        'ΑΥ456654', '2821456789', 3, 'Initialization', now(), now()),
       ('Ευαγγελία', 'Ανδρέου', '100047002', 'Λαμία', 'Ρούμελης', 154, 46, 160, '134', 8, '35100', '1996-03-28',
        'Λαμία', 'ΑΦ567543', '2231234567', 4, 'Initialization', now(), now()),
       ('Βασίλης', 'Οικονόμου', '100050006', 'Αθήνα', 'Ερμού', 154, 5, 186, '89', 9, '10563', '1984-11-12', 'Αθήνα',
        'ΑΧ678432', '2103456789', 5, 'Initialization', now(), now()),
       ('Χριστίνα', 'Μακρής', '100055002', 'Θεσσαλονίκη', 'Μητροπόλεως', 154, 19, 31, '56', 2, '54624', '1989-05-07',
        'Θεσσαλονίκη', 'ΑΨ789321', '2310234567', 1, 'Initialization', now(), now()),
       ('Γιάννης', 'Σπανός', '100057007', 'Τρίπολη', 'Γεωργίου Β', 154, 3, 241, '34', 10, '22100', '1981-09-23',
        'Τρίπολη', 'ΑΩ891210', '2710345678', 2, 'Initialization', now(), now()),
       ('Δέσποινα', 'Κυριάκου', '100060000', 'Σέρρες', 'Εμπορίου', 154, 44, 54, '78', 2, '62125', '1992-12-30',
        'Σέρρες', 'ΒΑ912109', '2321456789', 3, 'Initialization', now(), now()),
       ('Στέλιος', 'Αθανασίου', '100027003', 'Κέρκυρα', 'Καποδιστρίου', 154, 24, 118, '45', 6, '49100', '1983-06-15',
        'Κέρκυρα', 'ΒΒ123234', '2661234567', 4, 'Initialization', now(), now()),
       ('Φωτεινή', 'Μάρκου', '100032001', 'Ρέθυμνο', 'Αρκαδίου', 154, 41, 318, '92', 13, '74100', '1997-02-21',
        'Ρέθυμνο', 'ΒΓ234345', '2831345678', 5, 'Initialization', now(), now()),
       ('Αλέξανδρος', 'Παπαϊωάννου', '100039002', 'Χαλκίδα', 'Βενιζέλου', 154, 12, 155, '67', 8, '34100', '1979-08-18',
        'Χαλκίδα', 'ΒΔ345456', '2221456789', 1, 'Initialization', now(), now()),
       ('Αναστασία', 'Τζανετάκης', '456567891', 'Αλεξανδρούπολη', 'Λεωφόρος Δημοκρατίας', 154, 11, 6, '123', 1, '68100',
        '1991-04-05', 'Αλεξανδρούπολη', 'ΒΕ456567', '2551234567', 2, 'Initialization', now(), now()),
       ('Χρήστος', 'Καραγιάννης', '100048000', 'Άρτα', 'Σκουφά', 154, 4, 73, '34', 4, '47100', '1985-10-28', 'Άρτα',
        'ΒΖ567678', '2681345678', 3, 'Initialization', now(), now()),
       ('Βασιλική', 'Σιδερόπουλος', '100051003', 'Καλαμάτα', 'Αριστομένους', 154, 36, 254, '78', 10, '24100',
        '1993-07-11', 'Καλαμάτα', 'ΒΗ678789', '2721456789', 4, 'Initialization', now(), now()),
       ('Σπύρος', 'Φίλιππος', '100056000', 'Κομοτηνή', 'Ορφέως', 154, 42, 21, '56', 1, '69100', '1988-01-24',
        'Κομοτηνή', 'ΒΘ789891', '2531234567', 5, 'Initialization', now(), now()),
       ('Ιωάννα', 'Βλάχος', '100059001', 'Καρδίτσα', 'Πλαστήρα', 154, 22, 92, '89', 5, '43100', '1990-11-19',
        'Καρδίτσα', 'ΒΙ891912', '2441345678', 1, 'Initialization', now(), now()),
       ('Μανώλης', 'Γρηγορίου', '100061008', 'Ξάνθη', 'Αντικά', 154, 37, 17, '45', 1, '67100', '1986-05-02', 'Ξάνθη',
        'ΒΚ912123', '2541456789', 2, 'Initialization', now(), now()),
       ('Ελισάβετ', 'Παπακώστα', '100028000', 'Ναύπλιο', 'Σταϊκοπούλου', 154, 2, 236, '67', 10, '21100', '1994-09-16',
        'Ναύπλιο', 'ΒΛ123345', '2752234567', 3, 'Initialization', now(), now()),
       ('Λεωνίδας', 'Τσιτσιπάς', '100033009', 'Πύργος', 'Πατρέως', 154, 15, 141, '123', 7, '27100', '1982-03-08',
        'Πύργος', 'ΒΜ234456', '2621345678', 4, 'Initialization', now(), now()),
       ('Μαριάνθη', 'Ζαχαρίας', '100040001', 'Κως', 'Ιπποκράτους', 154, 10, 284, '78', 12, '85300', '1995-12-25', 'Κως',
        'ΒΝ345567', '2242456789', 5, 'Initialization', now(), now());

INSERT INTO legal_entity (gemi_number, business_name, phone_number, afm, city, street, country_id, prefecture_id,
                          municipality_id, street_number, region_id, postal_code, last_user_id, change_reason)
VALUES ('010001234000', 'ΑΛΦΑ ΕΜΠΟΡΙΚΗ ΑΕ', '2101234567', '100001000', 'Αθήνα', 'Πανεπιστημίου', 154, 5, 186, '45', 9,
        '10679', 1, 'Initialization'),
       ('010002345000', 'ΒΗΤΑ ΤΕΧΝΟΛΟΓΙΕΣ ΙΚΕ', '2310567890', '100026006', 'Θεσσαλονίκη', 'Τσιμισκή', 154, 19, 31,
        '120', 2,
        '54623', 1, 'Initialization'),
       ('010003456000', 'ΓΑΜΜΑ LOGISTICS ΕΠΕ', '2610345678', '100025009', 'Πάτρα', 'Κορίνθου', 154, 6, 134, '78', 7,
        '26441',
        1, 'Initialization'),
       ('010004567000', 'ΔΕΛΤΑ ΚΑΤΑΣΚΕΥΕΣ ΑΕ', '2810456789', '100024001', 'Ηράκλειο', 'Λεωφόρος Κνωσού', 154, 17, 305,
        '156',
        13, '71307', 1, 'Initialization'),
       ('010005678000', 'ΕΨΙΛΟΝ ΣΥΜΒΟΥΛΟΙ ΙΚΕ', '2410234567', '100023004', 'Λάρισα', 'Παπαναστασίου', 154, 31, 100,
        '34', 5,
        '41222', 1, 'Initialization'),
       ('010006789000', 'ΖΗΤΑ ΤΡΟΦΙΜΑ ΟΕ', '2510345678', '100022007', 'Βόλος', 'Ιάσονος', 154, 35, 105, '67', 5,
        '38333', 1,
        'Initialization'),
       ('010007890000', 'ΗΤΑ ΦΑΡΜΑΚΕΥΤΙΚΗ ΑΕ', '2620456789', '100021000', 'Ιωάννινα', 'Δωδώνης', 154, 20, 84, '89', 4,
        '45221', 1, 'Initialization'),
       ('010008901000', 'ΘΗΤΑ ΕΝΕΡΓΕΙΑ ΙΚΕ', '2510567890', '100020002', 'Καβάλα', 'Ελευθερίας', 154, 21, 12, '23', 1,
        '65403',
        1, 'Initialization'),
       ('010009012000', 'ΙΩΤΑ ΠΛΗΡΟΦΟΡΙΚΗ ΕΠΕ', '2241345678', '100019003', 'Ρόδος', '28ης Οκτωβρίου', 154, 10, 296,
        '145',
        12,
        '85100', 1, 'Initialization'),
       ('010010123000', 'ΚΑΠΠΑ ΜΕΤΑΦΟΡΕΣ ΑΕ', '2461234567', '100018006', 'Κοζάνη', 'Μεταμορφώσεως', 154, 27, 68, '56',
        3,
        '50100', 1, 'Initialization'),
       ('010011234000', 'ΛΑΜΔΑ ΞΕΝΟΔΟΧΕΙΑ ΙΚΕ', '2821345678', '100017009', 'Χανιά', 'Κυδωνίας', 154, 50, 325, '92', 13,
        '73135', 1, 'Initialization'),
       ('010012345000', 'ΜΥ ΕΚΔΟΤΙΚΗ ΟΕ', '2231456789', '100016001', 'Αλεξανδρούπολη', 'Λεωφόρος Δημοκρατίας', 154, 11,
        6,
        '34', 1, '68100', 1, 'Initialization'),
       ('010013456000', 'ΝΥ ΝΑΥΤΙΛΙΑΚΗ ΑΕ', '2101456789', '100015004', 'Πειραιάς', 'Ακτή Μιαούλη', 154, 5, 205, '178',
        9,
        '18538', 1, 'Initialization'),
       ('010014567000', 'ΞΙ ΔΟΜΙΚΑ ΥΛΙΚΑ ΙΚΕ', '2681345678', '100014007', 'Άρτα', 'Σκουφά', 154, 4, 73, '45', 4,
        '47100', 1,
        'Initialization'),
       ('010015678000', 'ΟΜΙΚΡΟΝ ΑΣΦΑΛΕΙΕΣ ΕΠΕ', '2721456789', '100013000', 'Καλαμάτα', 'Αριστομένους', 154, 36, 254,
        '112',
        10, '24100', 1, 'Initialization'),
       ('010016789000', 'ΠΙ ΤΟΥΡΙΣΤΙΚΗ ΑΕ', '2531234567', '100012002', 'Κομοτηνή', 'Ορφέως', 154, 42, 21, '67', 1,
        '69100',
        1,
        'Initialization'),
       ('010017890000', 'ΡΟ ΓΕΩΡΓΙΚΑ ΙΚΕ', '2441345678', '100011005', 'Καρδίτσα', 'Πλαστήρα', 154, 22, 92, '89', 5,
        '43100',
        1, 'Initialization'),
       ('010018901000', 'ΣΙΓΜΑ ΤΗΛΕΠΙΚΟΙΝΩΝΙΕΣ ΟΕ', '2541456789', '100010008', 'Ξάνθη', 'Αντικά', 154, 37, 17, '123', 1,
        '67100', 1, 'Initialization'),
       ('010019012000', 'ΤΑΥ ΧΗΜΙΚΑ ΑΕ', '2752234567', '081098765', 'Ναύπλιο', 'Σταϊκοπούλου', 154, 2, 236, '45', 10,
        '21100',
        1, 'Initialization'),
       ('010020123000', 'ΥΨΙΛΟΝ ΟΠΤΙΚΑ ΙΚΕ', '2621345678', '100009009', 'Πύργος', 'Πατρέως', 154, 15, 141, '78', 7,
        '27100',
        1, 'Initialization'),
       ('010021234000', 'ΦΙ ΗΛΕΚΤΡΟΝΙΚΑ ΕΠΕ', '2242456789', '100008001', 'Κως', 'Ιπποκράτους', 154, 10, 284, '56', 12,
        '85300', 1, 'Initialization'),
       ('010022345000', 'ΧΙ ΜΗΧΑΝΟΛΟΓΙΚΗ ΑΕ', '2221456789', '100007004', 'Χαλκίδα', 'Βενιζέλου', 154, 12, 155, '134', 8,
        '34100', 1, 'Initialization'),
       ('010023456000', 'ΨΙ ΕΠΙΠΛΑ ΙΚΕ', '2421234567', '100006007', 'Τρίκαλα', 'Ασκληπιού', 154, 47, 113, '89', 5,
        '42100',
        1,
        'Initialization'),
       ('010024567000', 'ΩΜΕΓΑ ΚΛΩΣΤΟΫΦΑΝΤΟΥΡΓΙΑ ΟΕ', '2321456789', '100005000', 'Βέροια', 'Μητροπόλεως', 154, 16, 25,
        '67',
        2, '59100', 1, 'Initialization'),
       ('010025678000', 'ΑΚΡΟΠΟΛΙΣ ΕΠΕΝΔΥΣΕΙΣ ΑΕ', '2101567890', '100004002', 'Αθήνα', 'Σταδίου', 154, 5, 186, '234', 9,
        '10564', 1, 'Initialization'),
       ('010026789000', 'ΟΛΥΜΠΟΣ ΑΘΛΗΤΙΚΑ ΙΚΕ', '2310678901', '074321098', 'Θεσσαλονίκη', 'Εγνατία', 154, 19, 31, '156',
        2,
        '54630', 1, 'Initialization'),
       ('010027890000', 'ΠΑΡΘΕΝΩΝΑΣ ΜΑΡΜΑΡΑ ΕΠΕ', '2610456789', '100003005', 'Πάτρα', 'Μαιζώνος', 154, 6, 134, '201', 7,
        '26335', 1, 'Initialization'),
       ('010028901000', 'ΘΑΛΑΣΣΑ ΑΛΙΕΥΤΙΚΗ ΑΕ', '2810567890', '100002010', 'Ηράκλειο', '1821', 154, 17, 305, '78', 13,
        '71202', 1, 'Initialization'),
       ('010029012000', 'ΒΟΥΝΟ ΞΥΛΕΙΑ ΙΚΕ', '2410345678', '100001012', 'Λάρισα', 'Κύπρου', 154, 31, 100, '123', 5,
        '41335',
        1,
        'Initialization'),
       ('010030123000', 'ΗΛΙΟΣ ΦΩΤΟΒΟΛΤΑΪΚΑ ΟΕ', '2510456789', '100000015', 'Βόλος', 'Αργοναυτών', 154, 35, 105, '89',
        5,
        '38221', 1, 'Initialization');

INSERT INTO member (active, date_from, date_to, percentage_of_ownership, person_id, legal_entity_id, company_id,
                    representative_of_member, represented_individual, represented_together, member_relation_id,
                    last_user_id, change_reason, date_created, last_updated)
VALUES (true, '2015-03-15', '2099-12-31', '45.00', 1, NULL, 1, NULL, false, false, 6, 1, 'Initialization', now(),
        now()),
       (true, '2015-03-15', '2099-12-31', '35.00', 2, NULL, 1, NULL, false, false, 10, 1, 'Initialization', now(),
        now()),
       (true, '2015-03-15', '2099-12-31', '20.00', NULL, 1, 1, 3, false, false, 10, 1, 'Initialization', now(), now()),
       (true, '2018-06-20', '2099-12-31', '100.00', 4, NULL, 2, NULL, false, false, 6, 2, 'Initialization', now(),
        now()),
       (true, '2012-09-10', '2099-12-31', '40.00', 5, NULL, 3, NULL, false, false, 10, 3, 'Initialization', now(),
        now()),
       (true, '2012-09-10', '2099-12-31', '35.00', NULL, 2, 3, 6, false, false, 10, 3, 'Initialization', now(), now()),
       (true, '2012-09-10', '2099-12-31', '25.00', NULL, 3, 3, 7, false, false, 10, 3, 'Initialization', now(), now()),
       (true, '2010-11-25', '2099-12-31', '100.00', NULL, 4, 4, 8, false, false, 6, 4, 'Initialization', now(), now()),
       (true, '2016-04-12', '2099-12-31', '40.00', 9, NULL, 5, NULL, false, false, 4, 5, 'Initialization', now(),
        now()),
       (true, '2016-04-12', '2099-12-31', '35.00', 10, NULL, 5, NULL, false, false, 4, 5, 'Initialization', now(),
        now()),
       (true, '2016-04-12', '2099-12-31', '25.00', 11, NULL, 5, NULL, false, false, 4, 5, 'Initialization', now(),
        now()),
       (true, '2019-02-28', '2099-12-31', '100.00', 12, NULL, 6, NULL, false, false, 6, 1, 'Initialization', now(),
        now()),
       (true, '2014-07-08', '2099-12-31', '50.00', 13, NULL, 7, NULL, false, false, 10, 2, 'Initialization', now(),
        now()),
       (true, '2014-07-08', '2099-12-31', '30.00', 14, NULL, 7, NULL, false, false, 10, 2, 'Initialization', now(),
        now()),
       (true, '2014-07-08', '2099-12-31', '20.00', NULL, 5, 7, 15, false, false, 10, 2, 'Initialization', now(), now()),
       (true, '2011-12-15', '2099-12-31', '100.00', NULL, 6, 8, 16, false, false, 7, 3, 'Initialization', now(), now()),
       (true, '2013-05-22', '2099-12-31', '45.00', 17, NULL, 9, NULL, false, false, 10, 4, 'Initialization', now(),
        now()),
       (true, '2013-05-22', '2099-12-31', '30.00', NULL, 7, 9, 18, false, false, 10, 4, 'Initialization', now(), now()),
       (true, '2013-05-22', '2099-12-31', '25.00', NULL, 8, 9, 19, false, false, 10, 4, 'Initialization', now(), now()),
       (true, '2017-08-30', '2099-12-31', '100.00', 20, NULL, 10, NULL, false, false, 6, 5, 'Initialization', now(),
        now()),
       (true, '2020-01-14', '2099-12-31', '40.00', 21, NULL, 11, NULL, false, false, 10, 1, 'Initialization', now(),
        now()),
       (true, '2020-01-14', '2099-12-31', '35.00', 22, NULL, 11, NULL, false, false, 10, 1, 'Initialization', now(),
        now()),
       (true, '2020-01-14', '2099-12-31', '25.00', 23, NULL, 11, NULL, false, false, 10, 1, 'Initialization', now(),
        now()),
       (true, '2009-10-05', '2099-12-31', '100.00', NULL, 9, 12, 24, false, false, 7, 2, 'Initialization', now(),
        now()),
       (true, '2015-11-18', '2099-12-31', '45.00', 25, NULL, 13, NULL, false, false, 10, 3, 'Initialization', now(),
        now()),
       (true, '2015-11-18', '2099-12-31', '30.00', 26, NULL, 13, NULL, false, false, 10, 3, 'Initialization', now(),
        now()),
       (true, '2015-11-18', '2099-12-31', '25.00', NULL, 10, 13, 27, false, false, 10, 3, 'Initialization', now(),
        now()),
       (true, '2008-03-27', '2099-12-31', '100.00', 28, NULL, 14, NULL, false, false, 6, 4, 'Initialization', now(),
        now()),
       (true, '2021-06-09', '2099-12-31', '40.00', 29, NULL, 15, NULL, false, false, 10, 5, 'Initialization', now(),
        now()),
       (true, '2021-06-09', '2099-12-31', '35.00', NULL, 11, 15, 30, false, false, 10, 5, 'Initialization', now(),
        now()),
       (true, '2021-06-09', '2099-12-31', '25.00', NULL, 12, 15, 1, false, false, 10, 5, 'Initialization', now(),
        now());

INSERT INTO stock_types (last_user_id, change_reason, date_created, last_updated)
VALUES (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now());

INSERT INTO stock_typesI18n (stock_type_id, language_id, description, last_user_id, change_reason, date_created,
                             last_updated)
VALUES (1, 1, 'Ονομαστικές, Κοινές', 1, 'Initialization', now(), now()),
       (2, 1, 'Ονομαστικές, Προνομιούχες, με Δικαίωμα Ψήφου', 1, 'Initialization', now(), now()),
       (3, 1, 'Ονομαστικές, Προνομιούχες, χωρίς Δικαίωμα Ψήφου', 1, 'Initialization', now(), now()),
       (4, 1, 'Κεφαλαιικές', 1, 'Initialization', now(), now()),
       (5, 1, 'Εξωκεφαλαιικές', 1, 'Initialization', now(), now()),
       (6, 1, 'Εγγυητικές', 1, 'Initialization', now(), now()),
       (1, 2, 'Nominal, Ordinary', 1, 'Initialization', now(), now()),
       (2, 2, 'Nominal, Preferred, Voting', 1, 'Initialization', now(), now()),
       (3, 2, 'Nominal, Preferred, non-Voting', 1, 'Initialization', now(), now()),
       (4, 2, 'Capital', 1, 'Initialization', now(), now()),
       (5, 2, 'Non-Capital', 1, 'Initialization', now(), now()),
       (6, 2, 'Guarantee', 1, 'Initialization', now(), now());
INSERT INTO currency (last_user_id, change_reason, date_created, last_updated)
VALUES (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now()),
       (1, 'Initialization', now(), now());

INSERT INTO currencyI18n (currency_id, description, language_id, last_user_id, change_reason, date_created,
                          last_updated)
VALUES (1, 'Euro', 1, 1, 'Initialization', now(), now()),
       (2, 'United States Dollar', 1, 1, 'Initialization', now(), now()),
       (3, 'Great Britain Pounds', 1, 1, 'Initialization', now(), now()),
       (4, 'Canadian Dollar', 1, 1, 'Initialization', now(), now()),
       (5, 'Australian Dollar', 1, 1, 'Initialization', now(), now()),
       (6, 'Turkish Lira', 1, 1, 'Initialization', now(), now()),
       (7, 'Albanian Lek', 1, 1, 'Initialization', now(), now()),
       (8, 'Bulgarian Lev', 1, 1, 'Initialization', now(), now()),
       (9, 'FYROM Denar', 1, 1, 'Initialization', now(), now()),
       (10, 'Russian Rouble', 1, 1, 'Initialization', now(), now()),
       (11, 'Romanian New Leu', 1, 1, 'Initialization', now(), now()),
       (12, 'Ελληνικές Δραχμές', 1, 1, 'Initialization', now(), now()),
       (13, 'Swiss Franc', 1, 1, 'Initialization', now(), now()),
       (14, 'Danish Krone', 1, 1, 'Initialization', now(), now()),
       (15, 'Cayman Islands dollar', 1, 1, 'Initialization', now(), now()),
       (16, 'Norwegian Krone', 1, 1, 'Initialization', now(), now()),
       (17, 'Serbian Dinar', 1, 1, 'Initialization', now(), now()),
       (18, 'Philippine Peso', 1, 1, 'Initialization', now(), now()),
       (1, 'Euro', 2, 1, 'Initialization', now(), now()),
       (2, 'United States Dollar', 2, 1, 'Initialization', now(), now()),
       (3, 'Great Britain Pounds', 2, 1, 'Initialization', now(), now()),
       (4, 'Canadian Dollar', 2, 1, 'Initialization', now(), now()),
       (5, 'Australian Dollar', 2, 1, 'Initialization', now(), now()),
       (6, 'Turkish Lira', 2, 1, 'Initialization', now(), now()),
       (7, 'Albanian Lek', 2, 1, 'Initialization', now(), now()),
       (8, 'Bulgarian Lev', 2, 1, 'Initialization', now(), now()),
       (9, 'FYROM Denarius', 2, 1, 'Initialization', now(), now()),
       (10, 'Russian Rouble', 2, 1, 'Initialization', now(), now()),
       (11, 'Romanian New Leu', 2, 1, 'Initialization', now(), now()),
       (12, 'Greek drachmas', 2, 1, 'Initialization', now(), now()),
       (13, 'Swiss Franc', 2, 1, 'Initialization', now(), now()),
       (14, 'Danish Krone', 2, 1, 'Initialization', now(), now()),
       (15, 'Cayman Islands dollar', 2, 1, 'Initialization', now(), now()),
       (16, 'Norwegian Krone', 2, 1, 'Initialization', now(), now()),
       (17, 'Serbian Dinar', 2, 1, 'Initialization', now(), now()),
       (18, 'Philippine Peso', 2, 1, 'Initialization', now(), now());

-- Insert company_capital rows (one per company)
-- total_amount must equal SUM(amount * nominal_price) of the matching company_stocks rows
INSERT INTO company_capital (company_id, total_amount, currency_id, last_user_id, change_reason, date_created,
                             last_updated)
VALUES (1, 1000000.00, 1, 1, 'Initialization', now(), now()),  -- Παπαδόπουλος Εμπορική ΑΕ
       (2, 50000.00, 1, 2, 'Initialization', now(), now()),    -- Νικολαΐδης & Συνεργάτες ΙΚΕ
       (3, 18000.00, 1, 3, 'Initialization', now(), now()),    -- Γεωργίου Τεχνική ΕΠΕ
       (4, 2500000.00, 1, 4, 'Initialization', now(), now()),  -- Δημητρίου Logistics ΑΕ
       (5, 30000.00, 1, 5, 'Initialization', now(), now()),    -- Κωνσταντίνου Αγροτική ΟΕ
       (6, 5000000.00, 1, 1, 'Initialization', now(), now()),  -- Αντωνίου Τεχνολογίες ΑΕ
       (7, 75000.00, 1, 2, 'Initialization', now(), now()),    -- Μιχαηλίδης Ναυτιλιακή ΙΚΕ
       (8, 24000.00, 1, 3, 'Initialization', now(), now()),    -- Χριστοδούλου Οικοδομική ΕΠΕ
       (9, 1500000.00, 1, 4, 'Initialization', now(), now()),  -- Σταυρίδης Τρόφιμα ΑΕ
       (10, 100000.00, 1, 5, 'Initialization', now(), now()),  -- Βασιλείου Φαρμακευτική ΙΚΕ
       (11, 3000000.00, 1, 1, 'Initialization', now(), now()), -- Ιωάννου Συμβουλευτική ΑΕ
       (12, 60000.00, 1, 2, 'Initialization', now(), now()),   -- Ανδρέου Ενέργεια ΕΠΕ
       (13, 25000.00, 1, 3, 'Initialization', now(), now()),   -- Πετρίδης Μεταφορές ΙΚΕ
       (14, 4000000.00, 1, 4, 'Initialization', now(), now()), -- Λαζάρου Ξενοδοχειακή ΑΕ
       (15, 150000.00, 1, 5, 'Initialization', now(), now());
-- Ευαγγέλου Πληροφορική ΙΚΕ

-- Insert company_stocks rows
-- SUM(amount * nominal_price) per company_id must equal the company_capital.total_amount of that company
INSERT INTO company_stocks (company_id, stock_type_id, amount, nominal_price, last_user_id, change_reason, date_created,
                            last_updated)
VALUES
-- Company 1: ΑΕ | total 1,000,000 = 90,000×10.00 + 10,000×10.00
(1, 1, 90000, 10.00, 1, 'Initialization', now(), now()),   -- Ονομαστικές Κοινές
(1, 2, 10000, 10.00, 1, 'Initialization', now(), now()),   -- Ονομαστικές Προνομιούχες με Δικαίωμα Ψήφου

-- Company 2: ΙΚΕ | total 50,000 = 50,000×1.00
(2, 4, 50000, 1.00, 2, 'Initialization', now(), now()),    -- Κεφαλαιικές

-- Company 3: ΕΠΕ | total 18,000 = 600×30.00
(3, 4, 600, 30.00, 3, 'Initialization', now(), now()),     -- Κεφαλαιικές

-- Company 4: ΑΕ | total 2,500,000 = 200,000×10.00 + 50,000×10.00
(4, 1, 200000, 10.00, 4, 'Initialization', now(), now()),  -- Ονομαστικές Κοινές
(4, 2, 50000, 10.00, 4, 'Initialization', now(), now()),   -- Ονομαστικές Προνομιούχες με Δικαίωμα Ψήφου

-- Company 5: ΟΕ | total 30,000 = 300×100.00
(5, 4, 300, 100.00, 5, 'Initialization', now(), now()),    -- Κεφαλαιικές

-- Company 6: ΑΕ | total 5,000,000 = 450,000×10.00 + 50,000×10.00
(6, 1, 450000, 10.00, 1, 'Initialization', now(), now()),  -- Ονομαστικές Κοινές
(6, 2, 50000, 10.00, 1, 'Initialization', now(), now()),   -- Ονομαστικές Προνομιούχες με Δικαίωμα Ψήφου

-- Company 7: ΙΚΕ | total 75,000 = 75,000×1.00
(7, 4, 75000, 1.00, 2, 'Initialization', now(), now()),    -- Κεφαλαιικές

-- Company 8: ΕΠΕ | total 24,000 = 800×30.00
(8, 4, 800, 30.00, 3, 'Initialization', now(), now()),     -- Κεφαλαιικές

-- Company 9: ΑΕ | total 1,500,000 = 120,000×10.00 + 30,000×10.00
(9, 1, 120000, 10.00, 4, 'Initialization', now(), now()),  -- Ονομαστικές Κοινές
(9, 3, 30000, 10.00, 4, 'Initialization', now(), now()),   -- Ονομαστικές Προνομιούχες χωρίς Δικαίωμα Ψήφου

-- Company 10: ΙΚΕ | total 100,000 = 100,000×1.00
(10, 4, 100000, 1.00, 5, 'Initialization', now(), now()),  -- Κεφαλαιικές

-- Company 11: ΑΕ | total 3,000,000 = 270,000×10.00 + 30,000×10.00
(11, 1, 270000, 10.00, 1, 'Initialization', now(), now()), -- Ονομαστικές Κοινές
(11, 2, 30000, 10.00, 1, 'Initialization', now(), now()),  -- Ονομαστικές Προνομιούχες με Δικαίωμα Ψήφου

-- Company 12: ΕΠΕ | total 60,000 = 2,000×30.00
(12, 4, 2000, 30.00, 2, 'Initialization', now(), now()),   -- Κεφαλαιικές

-- Company 13: ΙΚΕ | total 25,000 = 25,000×1.00
(13, 4, 25000, 1.00, 3, 'Initialization', now(), now()),   -- Κεφαλαιικές

-- Company 14: ΑΕ | total 4,000,000 = 350,000×10.00 + 50,000×10.00
(14, 1, 350000, 10.00, 4, 'Initialization', now(), now()), -- Ονομαστικές Κοινές
(14, 2, 50000, 10.00, 4, 'Initialization', now(), now()),  -- Ονομαστικές Προνομιούχες με Δικαίωμα Ψήφου

-- Company 15: ΙΚΕ | total 150,000 = 150,000×1.00
(15, 4, 150000, 1.00, 5, 'Initialization', now(), now()); -- Κεφαλαιικές