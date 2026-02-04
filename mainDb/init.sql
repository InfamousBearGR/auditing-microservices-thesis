CREATE TABLE company (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    test VARCHAR(255) NOT NULL
);
ALTER TABLE company REPLICA IDENTITY FULL;
-- Insert dummy data
INSERT INTO company (name, test) VALUES ('Acme Corp', 'test1'), ('Globex', 'test2');
