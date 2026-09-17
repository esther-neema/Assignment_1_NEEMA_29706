# SUNRISE SUPERMARKET
## Student information

STUDENT NAME: NEEMA Esther
STUDENT ID: 29706
GROUP: I
DBMS used: postgresSQL

## 1. Project Description

This project is a relational database system for Sunrise Supermarket.
The database is designed to store and manage information about customers, products, orders, and order items.
For this assignment, I created the four required tables and added realistic sample data. I then used SQL joins, a CTE, and window functions to answer the eight questions.
The main goal was to understand customer orders, calculate how much customers spend, and see how the supermarket's revenue changes over time.

##2. Database Structure

The database was created and managed using PostgreSQL SQL Shell (psql).
## Database Tables

The database contains four main tables:

### 1. Customers

Stores information about supermarket customers.

Columns:

- customer_id
- customer_name
- email
- city

### 2. Products

Stores information about products sold by the supermarket.

Columns:

- product_id
- product_name
- category
- price

### 3. Orders

Stores information about customer orders.

Columns:

- order_id
- customer_id
- order_date

### 4. Order Items

Stores information about the products included in each order.

Columns:

- order_item_id
- order_id
- product_id
- quantity

## Business Scenario

Sunrise Supermarket needs a database to manage its customers, products, and sales orders.

The database allows the supermarket to:

- Store customer information
- Store product information
- Record customer orders
- Record products purchased in each order
- Calculate customer spending
- Analyze sales revenue
- Analyze customer purchasing behavior

  ## JOIN Queries

### Question1. List Every Order with Customer Name, City, and Order Date

This query uses an INNER JOIN to combine each order with the customer who placed it.


```sql
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id;
```

The query was executed successfully and displayed the expected results.

![Query 1 Result](query1.png)

###Question2. List Every Order Item with Product Name, Category, Price, and Quantity

This query uses an INNER JOIN to combine the `order_items` and `products` tables.

```sql
SELECT
    oi.order_item_id,
    p.product_name,
    p.category,
    p.price,
    oi.quantity
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id;
```

### Question3. List All Customers and Their Orders

This query uses a LEFT JOIN to combine the `customers` and `orders` tables.The LEFT JOIN keeps all customers in the result, even if a customer has no order. If a customer has no order, the order information will appear as NULL.

```sql
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
```

### Question4. Calculate Customer Total Spend and Find Customers Above Average

This query uses a Common Table Expression (CTE) to calculate the total amount spent by each customer. It then finds customers whose total spending is above the average spending.

```sql
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
```

## Window Functions

### 1. Rank Customers by Total Amount Spent

This query ranks customers according to their total spending, with the highest spender receiving rank 1.

```sql
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
```

### 2. Number Each Customer's Orders

This query numbers each customer's orders in the order they were placed.

```sql
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
```

### 3. Show Running Total of Revenue Over Time

This query calculates the revenue for each day and the running total of revenue over time.

```sql
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
```

### 4. Show Days Between Current and Previous Order

This query shows the number of days between a customer's current order and their previous order.

```sql
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
```

## Business Interpretations

The queries provide useful information for Sunrise Supermarket.

- Customer spending helps the supermarket understand purchasing patterns.
- Customer ranking shows the amount spent by each customer.
- Order numbering shows the sequence of purchases made by each customer.
- Running revenue shows how sales accumulate over time.
- The days-between-orders analysis shows how frequently customers return to make purchases.

  ## Challenges and How I Resolved Them

### Challenge 1: Creating Relationships Between Tables

**Solution:**  
Primary keys and foreign keys were used to connect the database tables.

### Challenge 2: Calculating Customer Spending

**Solution:**  
The quantity of each product was multiplied by its price and then summed for each customer.

### Challenge 3: Using Window Functions

**Solution:**  
PostgreSQL window functions such as `RANK()`, `ROW_NUMBER()`, and `LAG()` were used to analyze customer and order information.

## How to Run the Project

1. Install PostgreSQL.
2. Open PostgreSQL SQL Shell (psql).
3. Create the database:

```sql
CREATE DATABASE sunrise_supermarket;

