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

CREATE TABLE person
(
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(255) NOT NULL,
    surname      VARCHAR(255) NOT NULL,
    afm          VARCHAR(20)  NOT NULL,
    last_user_id INT,
    date_created TIMESTAMP DEFAULT now(),
    last_updated TIMESTAMP DEFAULT now()
);
ALTER TABLE person
    REPLICA IDENTITY FULL;

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