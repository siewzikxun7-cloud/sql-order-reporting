-- Fictional orders from two systems, March 2026.
PRAGMA foreign_keys = ON;
BEGIN;

CREATE TABLE products (
    product_id TEXT PRIMARY KEY NOT NULL,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL
);

-- Each source has one row per completed or returned single-product order.
CREATE TABLE online_orders (
    order_id INTEGER PRIMARY KEY,
    order_date TEXT NOT NULL,
    ship_region TEXT NOT NULL CHECK (ship_region IN ('North', 'South', 'West')),
    product_id TEXT NOT NULL REFERENCES products(product_id),
    order_status TEXT NOT NULL CHECK (order_status IN ('delivered', 'returned'))
);

CREATE TABLE store_orders (
    receipt_id INTEGER PRIMARY KEY,
    sale_date TEXT NOT NULL,
    store_region TEXT NOT NULL CHECK (store_region IN ('North', 'South', 'West')),
    sku TEXT NOT NULL REFERENCES products(product_id),
    receipt_status TEXT NOT NULL CHECK (receipt_status IN ('completed', 'refunded'))
);

INSERT INTO products VALUES
    ('P01', 'Desk lamp', 'Home'),
    ('P02', 'Storage tote', 'Home'),
    ('P03', 'Travel mug', 'Accessories'),
    ('P04', 'Canvas pouch', 'Accessories');

INSERT INTO online_orders VALUES
    (1001, '2026-03-01', 'North', 'P01', 'delivered'),
    (1002, '2026-03-02', 'North', 'P02', 'returned'),
    (1003, '2026-03-04', 'North', 'P03', 'delivered'),
    (1004, '2026-03-05', 'North', 'P01', 'delivered'),
    (1005, '2026-03-07', 'South', 'P04', 'returned'),
    (1006, '2026-03-08', 'South', 'P02', 'delivered'),
    (1007, '2026-03-10', 'South', 'P03', 'returned'),
    (1008, '2026-03-12', 'West',  'P01', 'delivered'),
    (1009, '2026-03-13', 'West',  'P04', 'delivered');

INSERT INTO store_orders VALUES
    (1001, '2026-03-02', 'North', 'P03', 'refunded'),
    (1002, '2026-03-03', 'North', 'P01', 'completed'),
    (1003, '2026-03-06', 'North', 'P02', 'completed'),
    (1004, '2026-03-08', 'South', 'P02', 'completed'),
    (1005, '2026-03-09', 'South', 'P04', 'completed'),
    (1006, '2026-03-11', 'West',  'P01', 'refunded'),
    (1007, '2026-03-12', 'West',  'P03', 'completed');

COMMIT;
