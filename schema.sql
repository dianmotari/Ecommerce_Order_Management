-- =========================================================
-- Project: E-Commerce Order Management System
-- Description: Group Database Implementation
-- Entities:
-- CUSTOMER, ORDERS, ORDER_ITEM, PRODUCT, RECEIPT
-- =========================================================

-- 1. DATABASE CREATION
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;


-- =========================================================
-- 2. TABLE CREATION
-- =========================================================

-- ---------------------------------------------------------
-- Parent Table 1: CUSTOMER
-- ---------------------------------------------------------
CREATE TABLE CUSTOMER (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone_Number VARCHAR(20) NOT NULL
);


-- ---------------------------------------------------------
-- Parent Table 2: PRODUCT
-- ---------------------------------------------------------
CREATE TABLE PRODUCT (
    Product_ID INT AUTO_INCREMENT PRIMARY KEY,
    Product_Name VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Unit_Price DECIMAL(10, 2) NOT NULL
        CHECK (Unit_Price >= 0),
    Stock_Quantity INT NOT NULL DEFAULT 0
        CHECK (Stock_Quantity >= 0)
);


-- ---------------------------------------------------------
-- Child Table 1: ORDERS
-- ---------------------------------------------------------
CREATE TABLE ORDERS (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,

    Customer_ID INT NOT NULL,

    Order_Date DATETIME NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    Total_Amount DECIMAL(10, 2) NOT NULL
        DEFAULT 0.00,

    Status VARCHAR(20) NOT NULL
        DEFAULT 'PENDING'
        CHECK (
            Status IN
            ('PENDING',
             'PROCESSING',
             'SHIPPED',
             'DELIVERED',
             'CANCELLED')
        ),

    CONSTRAINT FK_Orders_Customer
        FOREIGN KEY (Customer_ID)
        REFERENCES CUSTOMER(Customer_ID)
        ON DELETE RESTRICT
);


-- ---------------------------------------------------------
-- Child/Bridge Table 2: ORDER_ITEM
-- ---------------------------------------------------------
CREATE TABLE ORDER_ITEM (
    Order_Item_ID INT AUTO_INCREMENT PRIMARY KEY,

    Order_ID INT NOT NULL,

    Product_ID INT NOT NULL,

    Quantity INT NOT NULL
        CHECK (Quantity > 0),

    Subtotal DECIMAL(10, 2) NOT NULL,

    CONSTRAINT FK_OrderItem_Order
        FOREIGN KEY (Order_ID)
        REFERENCES ORDERS(Order_ID)
        ON DELETE CASCADE,

    CONSTRAINT FK_OrderItem_Product
        FOREIGN KEY (Product_ID)
        REFERENCES PRODUCT(Product_ID)
        ON DELETE RESTRICT
);


-- ---------------------------------------------------------
-- Child Table 3: RECEIPT
-- ---------------------------------------------------------
CREATE TABLE RECEIPT (
    Receipt_ID INT AUTO_INCREMENT PRIMARY KEY,

    Order_ID INT NOT NULL UNIQUE,

    Receipt_Number VARCHAR(50) NOT NULL UNIQUE,

    Receipt_Date DATETIME NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    Amount_Paid DECIMAL(10, 2) NOT NULL
        CHECK (Amount_Paid >= 0),

    Payment_Method VARCHAR(30) NOT NULL,

    Payment_Status VARCHAR(20) NOT NULL
        DEFAULT 'PAID'
        CHECK (
            Payment_Status IN
            ('PAID',
             'PENDING',
             'REFUNDED')
        ),

    CONSTRAINT FK_Receipt_Order
        FOREIGN KEY (Order_ID)
        REFERENCES ORDERS(Order_ID)
        ON DELETE RESTRICT
);


-- =========================================================
-- 3. INDEX
-- =========================================================

CREATE INDEX idx_customer_email
ON CUSTOMER(Email);


-- =========================================================
-- 4. VIEW
-- =========================================================

CREATE VIEW Order_Summary_View AS
SELECT
    o.Order_ID,

    CONCAT(c.First_Name, ' ', c.Last_Name)
        AS Customer_Name,

    o.Order_Date,

    o.Status,

    o.Total_Amount

FROM ORDERS o

JOIN CUSTOMER c
    ON o.Customer_ID = c.Customer_ID;


-- =========================================================
-- 5. INSERT CUSTOMER DATA
-- =========================================================

INSERT INTO CUSTOMER
(First_Name, Last_Name, Email, Phone_Number)
VALUES
('Alice', 'Wanjiku',
 'alice.w@example.com',
 '+254700112233'),

('Brian', 'Ochieng',
 'brian.o@example.com',
 '+254711223344');


-- =========================================================
-- 6. INSERT PRODUCT DATA
-- =========================================================

INSERT INTO PRODUCT
(Product_Name, Category, Unit_Price, Stock_Quantity)
VALUES
('Laptop Dell XPS',
 'Electronics',
 120000.00,
 15),

('Wireless Mouse',
 'Accessories',
 2500.00,
 50),

('USB-C Cable',
 'Accessories',
 1000.00,
 100);


-- =========================================================
-- 7. INSERT ORDER DATA
-- =========================================================

INSERT INTO ORDERS
(Customer_ID, Order_Date, Total_Amount, Status)
VALUES
(1,
 '2026-03-17 10:00:00',
 122500.00,
 'PROCESSING'),

(2,
 '2026-03-17 11:30:00',
 2500.00,
 'DELIVERED');


-- =========================================================
-- 8. INSERT ORDER ITEMS
-- =========================================================

INSERT INTO ORDER_ITEM
(Order_ID, Product_ID, Quantity, Subtotal)
VALUES
(1, 1, 1, 120000.00),

(1, 2, 1, 2500.00),

(2, 2, 1, 2500.00);


-- =========================================================
-- 9. INSERT RECEIPTS
-- =========================================================

INSERT INTO RECEIPT
(
    Order_ID,
    Receipt_Number,
    Receipt_Date,
    Amount_Paid,
    Payment_Method,
    Payment_Status
)
VALUES
(
    1,
    'RCP-2026-0001',
    '2026-03-17 10:15:00',
    122500.00,
    'M-PESA',
    'PAID'
),

(
    2,
    'RCP-2026-0002',
    '2026-03-17 11:45:00',
    2500.00,
    'CASH',
    'PAID'
);


-- =========================================================
-- 10. VERIFICATION QUERY
-- Orders + Customers + Products + Receipts
-- =========================================================

SELECT
    o.Order_ID,

    CONCAT(
        c.First_Name,
        ' ',
        c.Last_Name
    ) AS Customer_Name,

    p.Product_Name,

    oi.Quantity,

    oi.Subtotal,

    o.Status AS Order_Status,

    r.Receipt_Number,

    r.Amount_Paid,

    r.Payment_Method,

    r.Payment_Status

FROM ORDERS o

JOIN CUSTOMER c
    ON o.Customer_ID = c.Customer_ID

JOIN ORDER_ITEM oi
    ON o.Order_ID = oi.Order_ID

JOIN PRODUCT p
    ON oi.Product_ID = p.Product_ID

LEFT JOIN RECEIPT r
    ON o.Order_ID = r.Order_ID;