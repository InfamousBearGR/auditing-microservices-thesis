CREATE TABLE company
(
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    last_user_id  INT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now()
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
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    surname       VARCHAR(255) NOT NULL,
    afm           VARCHAR(20)  NOT NULL,
    last_user_id  INT,
    change_reason VARCHAR(255) NOT NULL,
    date_created  TIMESTAMP DEFAULT now(),
    last_updated  TIMESTAMP DEFAULT now()
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

INSERT INTO company (name, last_user_id, change_reason, date_created, last_updated)
VALUES ('Acme Corp', 1, 'Initialization', now(), now()),
       ('Globex Inc', 2, 'Initialization', now(), now()),
       ('Soylent Corp', 3, 'Initialization', now(), now()),
       ('Initech', 4, 'Initialization', now(), now()),
       ('Umbrella Corp', 5, 'Initialization', now(), now());

INSERT INTO person (name, surname, afm, last_user_id, change_reason, date_created, last_updated)
VALUES ('John', 'Doe', '123456789', 1, 'Initialization', now(), now()),
       ('Jane', 'Smith', '987654321', 2, 'Initialization', now(), now()),
       ('Alice', 'Johnson', '456789123', 3, 'Initialization', now(), now()),
       ('Bob', 'Brown', '789123456', 4, 'Initialization', now(), now()),
       ('Charlie', 'Davis', '321654987', 5, 'Initialization', now(), now());