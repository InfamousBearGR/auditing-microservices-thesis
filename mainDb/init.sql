CREATE TABLE company
(
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(255) NOT NULL,
    last_user_id INT,
    date_created TIMESTAMP DEFAULT now(),
    last_updated TIMESTAMP DEFAULT now()
);
ALTER TABLE company
    REPLICA IDENTITY FULL;
-- Insert dummy data
INSERT INTO company (name, last_user_id, date_created, last_updated)
VALUES ('Acme Corp', 1, now(), now()),
       ('Globex Inc', 2, now(), now()),
       ('Soylent Corp', 3, now(), now()),
       ('Initech', 4, now(), now()),
       ('Umbrella Corp', 5, now(), now());

CREATE OR REPLACE FUNCTION update_last_updated_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_company_last_updated
BEFORE UPDATE ON company
FOR EACH ROW
EXECUTE PROCEDURE update_last_updated_column();

CREATE OR REPLACE FUNCTION set_creation_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_created = now();
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER insert_company_timestamps
BEFORE INSERT ON company
FOR EACH ROW
EXECUTE PROCEDURE set_creation_timestamps();
