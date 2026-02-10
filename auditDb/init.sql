CREATE TABLE user_account
(
    id           SERIAL PRIMARY KEY,
    api_key      VARCHAR(255) NOT NULL,
    access       JSONB        NOT NULL,
    date_created TIMESTAMP    NOT NULL DEFAULT now(),
    last_updated TIMESTAMP    NOT NULL DEFAULT now()
);

ALTER TABLE user_account
    REPLICA IDENTITY FULL;

CREATE OR REPLACE FUNCTION update_last_updated_column()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_account_last_updated
    BEFORE UPDATE
    ON user_account
    FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

INSERT INTO user_account (api_key, access, last_updated, date_created)
VALUES ('sample_api_key_123', '{
  "company": true,
  "person": true
}', now(), now());

CREATE TABLE company_audit
(
    id                 SERIAL,               -- Auto increment ID
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    changed_at         TIMESTAMPTZ NOT NULL,
    changed_by_user_id INT         NOT NULL,
    parent_id          INT         NOT NULL,
    change_id          BIGINT      NOT NULL,
    business_change_id BIGINT      NOT NULL,
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
    id                 SERIAL,               -- Auto increment ID
    before             JSONB,
    after              JSONB,
    operation_type     VARCHAR(10) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    changed_at         TIMESTAMPTZ NOT NULL,
    changed_by_user_id INT         NOT NULL,
    parent_id          INT         NOT NULL,
    change_id          BIGINT      NOT NULL,
    business_change_id BIGINT      NOT NULL,
    change_reason      VARCHAR(255) NOT NULL
);

-- Convert to hypertable for time-series efficiency
SELECT create_hypertable('person_audit', 'changed_at', partitioning_column => 'change_id', number_partitions => 4);

CREATE INDEX idx_person_audit_changed_at
    ON person_audit (changed_at DESC);

CREATE INDEX idx_person_audit_change_id
    ON person_audit (change_id);
