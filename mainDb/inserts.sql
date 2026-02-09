INSERT INTO company (name, last_user_id, date_created, last_updated)
VALUES ('Acme Corp', 1, now(), now()),
       ('Globex Inc', 2, now(), now()),
       ('Soylent Corp', 3, now(), now()),
       ('Initech', 4, now(), now()),
       ('Umbrella Corp', 5, now(), now());

INSERT INTO person (name, surname, afm, last_user_id, date_created, last_updated)
VALUES ('John', 'Doe', '123456789', 1, now(), now()),
       ('Jane', 'Smith', '987654321', 2, now(), now()),
       ('Alice', 'Johnson', '456789123', 3, now(), now()),
       ('Bob', 'Brown', '789123456', 4, now(), now()),
       ('Charlie', 'Davis', '321654987', 5, now(), now());