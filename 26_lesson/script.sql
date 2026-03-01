CREATE TABLE test_products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO test_products (name, price, category) VALUES
    ('Laptop', 999.99, 'Electronics'),
    ('Mouse', 25.50, 'Electronics'),
    ('Desk', 350.00, 'Furniture'),
    ('Chair', 175.00, 'Furniture'),
    ('Monitor', 299.99, 'Electronics');
