-- =========================================================
-- STRATHMORE UNIVERSITY - DATABASE SYSTEMS
-- Project: E-Commerce Order Management System (Group Project)
-- Standards: DDL Constraints, DML, Indexes, Views, Aggregations
-- =========================================================

-- STEP 1: SCHEMA CREATION & CLEANUP
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

DROP VIEW IF EXISTS Public_Order_Summary_View;
DROP TABLE IF EXISTS ORDER_ITEM;
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS PRODUCT;
DROP TABLE IF EXISTS CUSTOMER;

-- STEP 2: DDL TABLE DEFINITIONS WITH CONSTRAINTS (Module 5)
CREATE TABLE CUSTOMER (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone_Number VARCHAR(20) NOT NULL,
    -- Domain constraint on sex/gender matching Module 5 standards
    Sex CHAR(1) CHECK (Sex IN ('M', 'F'))
);

CREATE TABLE PRODUCT (
    Product_ID INT AUTO_INCREMENT PRIMARY KEY,
    Product_Name VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    Stock_Quantity INT NOT NULL DEFAULT 0 CHECK (Stock_Quantity >= 0)
);

CREATE TABLE ORDERS (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Order_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (Total_Amount >= 0),
    Status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (Status IN ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    CONSTRAINT FK_Orders_Customer 
        FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(Customer_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE ORDER_ITEM (
    Order_Item_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Subtotal DECIMAL(10, 2) NOT NULL CHECK (Subtotal >= 0),
    CONSTRAINT FK_OrderItem_Order 
        FOREIGN KEY (Order_ID) REFERENCES ORDERS(Order_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_OrderItem_Product 
        FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- STEP 3: PERFORMANCE INDEXING (Lab 4 / Module 4)
CREATE INDEX idx_customer_email ON CUSTOMER(Email);
CREATE INDEX idx_orders_customer ON ORDERS(Customer_ID);

-- STEP 4: DATA POPULATION / DML INSERTS (Module 6 / Lab 5 & 6)
INSERT INTO CUSTOMER (First_Name, Last_Name, Email, Phone_Number, Sex) VALUES
('Alice', 'Wanjiku', 'alice.w@example.com', '+254700112233', 'F'),
('Brian', 'Ochieng', 'brian.o@example.com', '+254711223344', 'M'),
('Catherine', 'Moraa', 'catherine.m@example.com', '+254722334455', 'F');

INSERT INTO PRODUCT (Product_Name, Category, UnitPrice, Stock_Quantity) VALUES
('Laptop Dell XPS', 'Electronics', 120000.00, 15),
('Wireless Mouse', 'Accessories', 2500.00, 50),
('USB-C Cable', 'Accessories', 1000.00, 100),
('Mechanical Keyboard', 'Electronics', 8500.00, 20);

INSERT INTO ORDERS (Customer_ID, Order_Date, Total_Amount, Status) VALUES
(1, '2026-03-17 10:00:00', 122500.00, 'PROCESSING'),
(2, '2026-03-17 11:30:00', 2500.00, 'DELIVERED'),
(1, '2026-03-18 14:15:00', 8500.00, 'PENDING');

INSERT INTO ORDER_ITEM (Order_ID, Product_ID, Quantity, Subtotal) VALUES
(1, 1, 1, 120000.00),
(1, 2, 1, 2500.00),
(2, 2, 1, 2500.00),
(3, 4, 1, 8500.00);

-- STEP 5: SECURE DATA ABSTRACTION / VIEW (Lab 4)
-- Masks exact customer contact details for security
CREATE VIEW Public_Order_Summary_View AS
SELECT 
    o.Order_ID,
    CONCAT(c.First_Name, ' ', c.Last_Name) AS Customer_Name,
    o.Order_Date,
    o.Status,
    o.Total_Amount
FROM ORDERS o
JOIN CUSTOMER c ON o.Customer_ID = c.Customer_ID;

-- STEP 6: DATA INTERROGATION & AGGREGATIONS (Module 7)
-- Query A: Multi-Table JOIN Verification
SELECT 
    o.Order_ID,
    CONCAT(c.First_Name, ' ', c.Last_Name) AS Customer_Name,
    p.Product_Name,
    oi.Quantity,
    oi.Subtotal,
    o.Status
FROM ORDERS o
JOIN CUSTOMER c ON o.Customer_ID = c.Customer_ID
JOIN ORDER_ITEM oi ON o.Order_ID = oi.Order_ID
JOIN PRODUCT p ON oi.Product_ID = p.Product_ID;

-- Query B: Summary Statistics (GROUP BY & HAVING)
SELECT 
    c.Customer_ID,
    CONCAT(c.First_Name, ' ', c.Last_Name) AS Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders,
    SUM(o.Total_Amount) AS Lifetime_Spend
FROM CUSTOMER c
JOIN ORDERS o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, Customer_Name
HAVING COUNT(o.Order_ID) >= 1
ORDER BY Lifetime_Spend DESC;
