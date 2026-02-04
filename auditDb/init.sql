CREATE TABLE company_audit (
    id SERIAL, -- Auto increment ID
    before JSONB,
    after JSONB,
    operation_type VARCHAR(10) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    changed_at TIMESTAMPTZ NOT NULL,
    changed_by_user_id INT NOT NULL,
    parent_id INT NOT NULL
);

-- Convert to hypertable for time-series efficiency
SELECT create_hypertable('company_audit', 'changed_at');
