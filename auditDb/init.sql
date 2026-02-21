CREATE TABLE user_api_account
(
    id           BIGSERIAL PRIMARY KEY,
    api_key      VARCHAR(255) NOT NULL,
    access       JSONB        NOT NULL,
    date_created TIMESTAMP    NOT NULL DEFAULT now(),
    last_updated TIMESTAMP    NOT NULL DEFAULT now()
);

ALTER TABLE user_api_account
    REPLICA IDENTITY FULL;

CREATE OR REPLACE FUNCTION update_last_updated_column()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_api_account_last_updated
    BEFORE UPDATE
    ON user_api_account
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

INSERT INTO user_api_account (api_key, access, last_updated, date_created)
VALUES ('sample_api_key_123', '{
  "company": true,
  "person": true
}', now(), now());

CREATE TABLE company_audit
(
    id                 BIGSERIAL,             -- Auto increment ID
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

-- Convert to hypertable for time-series efficiency
SELECT create_hypertable('company_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_company_audit_changed_at
    ON company_audit (changed_at DESC);

CREATE INDEX idx_company_audit_change_id
    ON company_audit (change_id);

CREATE TABLE person_audit
(
    id                 BIGSERIAL,             -- Auto increment ID
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

-- Convert to hypertable for time-series efficiency
SELECT create_hypertable('person_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_person_audit_changed_at
    ON person_audit (changed_at DESC);

CREATE INDEX idx_person_audit_change_id
    ON person_audit (change_id);

CREATE TABLE legal_entity_audit
(
    id                 BIGSERIAL,             -- Auto increment ID
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

-- Convert to hypertable for time-series efficiency
SELECT create_hypertable('legal_entity_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_legal_entity_audit_changed_at
    ON legal_entity_audit (changed_at DESC);

CREATE INDEX idx_legal_entity_audit_change_id
    ON legal_entity_audit (change_id);

CREATE TABLE member_audit
(
    id                 BIGSERIAL,             -- Auto increment ID
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

-- Convert to hypertable for time-series efficiency
SELECT create_hypertable('member_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_member_audit_changed_at
    ON member_audit (changed_at DESC);

CREATE INDEX idx_member_audit_change_id
    ON member_audit (change_id);

CREATE TABLE roles_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('roles_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_roles_audit_changed_at
    ON roles_audit (changed_at DESC);

CREATE INDEX idx_roles_audit_change_id
    ON roles_audit (change_id);

CREATE TABLE user_account_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('user_account_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_user_account_audit_changed_at
    ON user_account_audit (changed_at DESC);

CREATE INDEX idx_user_account_audit_change_id
    ON user_account_audit (change_id);

CREATE TABLE languages_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('languages_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_languages_audit_changed_at
    ON languages_audit (changed_at DESC);

CREATE INDEX idx_languages_audit_change_id
    ON languages_audit (change_id);

CREATE TABLE countries_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('countries_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_countries_audit_changed_at
    ON countries_audit (changed_at DESC);

CREATE INDEX idx_countries_audit_change_id
    ON countries_audit (change_id);

CREATE TABLE regions_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('regions_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_regions_audit_changed_at
    ON regions_audit (changed_at DESC);

CREATE INDEX idx_regions_audit_change_id
    ON regions_audit (change_id);

CREATE TABLE prefectures_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('prefectures_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_prefectures_audit_changed_at
    ON prefectures_audit (changed_at DESC);

CREATE INDEX idx_prefectures_audit_change_id
    ON prefectures_audit (change_id);

CREATE TABLE municipalities_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('municipalities_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_municipalities_audit_changed_at
    ON municipalities_audit (changed_at DESC);

CREATE INDEX idx_municipalities_audit_change_id
    ON municipalities_audit (change_id);

CREATE TABLE company_statuses_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('company_statuses_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_company_statuses_audit_changed_at
    ON company_statuses_audit (changed_at DESC);

CREATE INDEX idx_company_statuses_audit_change_id
    ON company_statuses_audit (change_id);

CREATE TABLE legal_types_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('legal_types_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_legal_types_audit_changed_at
    ON legal_types_audit (changed_at DESC);

CREATE INDEX idx_legal_types_audit_change_id
    ON legal_types_audit (change_id);

CREATE TABLE member_relations_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('member_relations_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_member_relations_audit_changed_at
    ON member_relations_audit (changed_at DESC);

CREATE INDEX idx_member_relations_audit_change_id
    ON member_relations_audit (change_id);

CREATE TABLE countriesi18n_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('countriesi18n_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_countriesi18n_audit_changed_at
    ON countriesi18n_audit (changed_at DESC);

CREATE INDEX idx_countriesi18n_audit_change_id
    ON countriesi18n_audit (change_id);

CREATE TABLE regionsi18n_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('regionsi18n_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_regionsi18n_audit_changed_at
    ON regionsi18n_audit (changed_at DESC);

CREATE INDEX idx_regionsi18n_audit_change_id
    ON regionsi18n_audit (change_id);

CREATE TABLE prefecturesi18n_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('prefecturesi18n_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_prefecturesi18n_audit_changed_at
    ON prefecturesi18n_audit (changed_at DESC);

CREATE INDEX idx_prefecturesi18n_audit_change_id
    ON prefecturesi18n_audit (change_id);

CREATE TABLE municipalitiesi18n_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('municipalitiesi18n_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_municipalitiesi18n_audit_changed_at
    ON municipalitiesi18n_audit (changed_at DESC);

CREATE INDEX idx_municipalitiesi18n_audit_change_id
    ON municipalitiesi18n_audit (change_id);

CREATE TABLE company_statusesi18n_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('company_statusesi18n_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_company_statusesi18n_audit_changed_at
    ON company_statusesi18n_audit (changed_at DESC);

CREATE INDEX idx_company_statusesi18n_audit_change_id
    ON company_statusesi18n_audit (change_id);

CREATE TABLE legal_typesi18n_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('legal_typesi18n_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_legal_typesi18n_audit_changed_at
    ON legal_typesi18n_audit (changed_at DESC);

CREATE INDEX idx_legal_typesi18n_audit_change_id
    ON legal_typesi18n_audit (change_id);

CREATE TABLE member_relationsi18n_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('member_relationsi18n_audit', 'changed_at', partitioning_column => 'change_id',
                         number_partitions => 4);

CREATE INDEX idx_member_relationsi18n_audit_changed_at
    ON member_relationsi18n_audit (changed_at DESC);

CREATE INDEX idx_member_relationsi18n_audit_change_id
    ON member_relationsi18n_audit (change_id);

CREATE TABLE stock_types_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('stock_types_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_stock_types_audit_changed_at
    ON stock_types_audit (changed_at DESC);

CREATE INDEX idx_stock_types_audit_change_id
    ON stock_types_audit (change_id);

CREATE TABLE stock_typesi18n_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('stock_typesi18n_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_stock_typesi18n_audit_changed_at
    ON stock_typesi18n_audit (changed_at DESC);

CREATE INDEX idx_stock_typesi18n_audit_change_id
    ON stock_typesi18n_audit (change_id);

CREATE TABLE currency_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('currency_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_currency_audit_changed_at
    ON currency_audit (changed_at DESC);

CREATE INDEX idx_currency_audit_change_id
    ON currency_audit (change_id);

CREATE TABLE currencyi18n_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('currencyi18n_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_currencyi18n_audit_changed_at
    ON currencyi18n_audit (changed_at DESC);

CREATE INDEX idx_currencyi18n_audit_change_id
    ON currencyi18n_audit (change_id);

CREATE TABLE company_stocks_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('company_stocks_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_company_stocks_audit_changed_at
    ON company_stocks_audit (changed_at DESC);

CREATE INDEX idx_company_stocks_audit_change_id
    ON company_stocks_audit (change_id);

CREATE TABLE company_capital_audit
(
    id                 BIGSERIAL,
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10)  NOT NULL,
    changed_at         TIMESTAMPTZ  NOT NULL,
    changed_by_user_id BIGINT       NOT NULL,
    parent_id          BIGINT       NOT NULL,
    change_id          BIGINT       NOT NULL,
    business_change_id BIGINT       NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

SELECT create_hypertable('company_capital_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_company_capital_audit_changed_at
    ON company_capital_audit (changed_at DESC);

CREATE INDEX idx_company_capital_audit_change_id
    ON company_capital_audit (change_id);
