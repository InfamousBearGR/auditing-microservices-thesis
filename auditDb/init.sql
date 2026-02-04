CREATE TABLE company_audit (
    id SERIAL, -- Auto increment ID
    changes JSONB NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL
);

-- Convert to hypertable for time-series efficiency
SELECT create_hypertable('company_audit', 'changed_at');
