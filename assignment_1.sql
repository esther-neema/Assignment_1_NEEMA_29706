-- ============================================================
-- SUNRISE SUPERMARKET - ASSIGNMENT ONE
-- Student: NEEMA Esther
-- Student ID: 29706
-- Group: I
-- DBMS: PostgreSQL
-- ============================================================

-- ============================================================
-- 1. CREATE TABLES
-- ============================================================

CREATE TABLE customers (
  customer_id NUMBER PRIMARY KEY,
  customer_name VARCHAR2(100),
  email VARCHAR2(100),
  city VARCHAR2(50)
);

CREATE TABLE products (
  product_id NUMBER PRIMARY KEY,
  product_name VARCHAR2(100),
  category VARCHAR2(50),
  price NUMBER(10,2)
);

CREATE TABLE orders (
  order_id NUMBER PRIMARY KEY,
  customer_id NUMBER REFERENCES customers(customer_id),
  order_date DATE
);

CREATE TABLE order_items (
  order_item_id NUMBER PRIMARY KEY,
  order_id NUMBER REFERENCES orders(order_id),
  product_id NUMBER REFERENCES products(product_id),
  quantity NUMBER
);

-- ============================================================
-- 2. INSERT CUSTOMERS
-- ============================================================
INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(1, 'Alice Mukamana', 'alice@gmail.com', 'Kigali'),
(2, 'John Habimana', 'john@gmail.com', 'Kigali'),
(3, 'Grace Uwase', 'grace@gmail.com', 'Huye'),
(4, 'David Niyonzima', 'david@gmail.com', 'Musanze'),
(5, 'Eric Tuyisenge', 'eric@gmail.com', 'Rubavu');


-- ============================================================
-- 3. INSERT PRODUCTS
-- ============================================================
INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Milk', 'Dairy', 1200.00),
(2, 'Bread', 'Bakery', 1000.00),
(3, 'Rice', 'Grains', 2500.00),
(4, 'Sugar', 'Grains', 1800.00),
(5, 'Cooking Oil', 'Grains', 4500.00),
(6, 'Orange Juice', 'Beverages', 2000.00),
(7, 'Soap', 'Personal Care', 1500.00),
(8, 'Toothpaste', 'Personal Care', 2500.00);

-- ============================================================
-- 4. INSERT ORDERS
-- ============================================================
INSERT INTO orders (order_id, customer_id, order_date) VALUES
(101, 1, '2026-09-01'),
(102, 2, '2026-09-02'),
(103, 3, '2026-09-03'),
(104, 1, '2026-09-05'),
(105, 4, '2026-09-06'),
(106, 5, '2026-09-07'),
(107, 2, '2026-09-08'),
(108, 3, '2026-09-10'),
(109, 1, '2026-09-11'),
(110, 4, '2026-09-12'),
(111, 5, '2026-09-13'),
(112, 2, '2026-09-14'),
(113, 3, '2026-09-15'),
(114, 1, '2026-09-16'),
(115, 5, '2026-09-17');

-- ============================================================
-- 5. INSERT ORDER ITEMS
-- 30 order items: 2 items for each of 15 orders
-- ============================================================
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES
(1, 101, 1, 2),
(2, 101, 2, 1),

(3, 102, 3, 2),
(4, 102, 4, 1),

(5, 103, 5, 1),
(6, 103, 6, 2),

(7, 104, 1, 3),
(8, 104, 7, 2),

(9, 105, 2, 2),
(10, 105, 8, 1),

(11, 106, 3, 3),
(12, 106, 5, 1),

(13, 107, 6, 2),
(14, 107, 7, 3),

(15, 108, 4, 2),
(16, 108, 8, 2),

(17, 109, 1, 2),
(18, 109, 5, 2),

(19, 110, 2, 3),
(20, 110, 6, 1),

(21, 111, 3, 2),
(22, 111, 7, 2),

(23, 112, 4, 3),
(24, 113, 5, 2),
(25, 114, 8, 2);

-- ============================================================
-- QUESTION 1
-- List every order with the customer's name, city, and date.
-- INNER JOIN: orders + customers
-- ============================================================
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id;

-- ============================================================
-- QUESTION 2
-- List every order item with product information.
-- JOIN: order_items + products
-- ============================================================
SELECT
    oi.order_item_id,
    p.product_name,
    p.category,
    p.price,
    oi.quantity
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id;

-- ============================================================
-- QUESTION 3
-- Show all customers, including customers with no orders.
-- LEFT JOIN: customers + orders
-- ============================================================
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;


-- ============================================================
-- QUESTION 4
-- Find customers whose total spending is above average.
-- CTE: customer_totals
-- ============================================================
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spend
    FROM customers c
    INNER JOIN orders o
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spend
FROM customer_totals
WHERE total_spend > (
    SELECT AVG(total_spend)
    FROM customer_totals
)
ORDER BY total_spend DESC;

-- ============================================================
-- QUESTION 5
-- Rank customers by total amount spent.
-- Window function: RANK()
-- ============================================================
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * p.price) AS total_spend
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_spend,
    RANK() OVER (ORDER BY total_spend DESC) AS spending_rank
FROM customer_totals;


-- ============================================================
-- QUESTION 6
-- Number each customer's orders according to order date.
-- Window function: ROW_NUMBER()
-- ============================================================
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    ROW_NUMBER() OVER (
        PARTITION BY o.customer_id
        ORDER BY o.order_date
    ) AS order_number
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY c.customer_name, o.order_date;

-- ============================================================
-- QUESTION 7
-- Show a running total of supermarket revenue.
-- Window function: SUM() OVER()
-- ============================================================
SELECT
    o.order_date,
    SUM(oi.quantity * p.price) AS daily_revenue,
    SUM(SUM(oi.quantity * p.price)) OVER (
        ORDER BY o.order_date
    ) AS running_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- ============================================================
-- QUESTION 8
-- Calculate the number of days between consecutive orders
-- for each customer.
-- Window function: LAG()
-- ============================================================
SELECT
    customer_name,
    order_id,
    order_date,
    previous_order_date,
    order_date - previous_order_date AS days_between_orders
FROM (
    SELECT
        c.customer_name,
        o.order_id,
        o.order_date,
        LAG(o.order_date) OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date
        ) AS previous_order_date
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
) t
WHERE previous_order_date IS NOT NULL
ORDER BY customer_name, order_date;