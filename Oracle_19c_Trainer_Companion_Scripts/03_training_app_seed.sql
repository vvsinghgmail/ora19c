-- WRITABLE | TRAINING_APP only | disposable ORCLPDB1. Run ONCE.
SHOW USER
SHOW CON_NAME
SET ECHO ON
CREATE TABLE customers (
  customer_id NUMBER CONSTRAINT pk_training_customers PRIMARY KEY,
  customer_name VARCHAR2(80) NOT NULL,
  city VARCHAR2(60),
  email VARCHAR2(120) UNIQUE
);
CREATE TABLE orders (
  order_id NUMBER CONSTRAINT pk_training_orders PRIMARY KEY,
  customer_id NUMBER NOT NULL,
  amount NUMBER(10,2) CONSTRAINT chk_training_amount CHECK(amount>0),
  created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT fk_training_orders_customer FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);
INSERT INTO customers VALUES (101,'Asha','Bengaluru','asha@example.test');
INSERT INTO customers VALUES (102,'Ravi','Chennai','ravi@example.test');
INSERT INTO customers VALUES (103,'Sara','Delhi','sara@example.test');
INSERT INTO orders (order_id,customer_id,amount) VALUES (2001,101,250);
INSERT INTO orders (order_id,customer_id,amount) VALUES (2002,101,750);
INSERT INTO orders (order_id,customer_id,amount) VALUES (2003,102,500);
COMMIT;
SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM orders ORDER BY order_id;
-- To practice IDENTITY columns separately, first verify CREATE SEQUENCE privilege;
-- Oracle 19c may return ORA-01031 otherwise.
