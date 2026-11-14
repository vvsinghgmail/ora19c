-- WRITABLE | TRAINING_APP only. Reversible SQL exercises.
SHOW USER
SHOW CON_NAME
SELECT customer_id,city FROM customers ORDER BY customer_id;
SAVEPOINT before_demo;
UPDATE customers SET city='Jaipur' WHERE customer_id=101;
SELECT customer_id,city FROM customers WHERE customer_id=101;
ROLLBACK TO before_demo;
SELECT customer_id,city FROM customers WHERE customer_id=101;
-- Intended PK/FK violation (uncomment one line at a time; error expected):
-- INSERT INTO orders(order_id,customer_id,amount) VALUES (9901,999999,100);
-- INSERT INTO customers(customer_id,customer_name) VALUES (101,'Duplicate');
ROLLBACK;
-- TWO-SESSION DEMO (trainer supervised):
-- Session A: UPDATE customers SET city='Agra' WHERE customer_id=102; [do not commit]
-- Session B: SELECT city FROM customers WHERE customer_id=102; [old committed value]
-- Session B: UPDATE customers SET city='Surat' WHERE customer_id=102; [waits for row lock]
-- Session A: ROLLBACK; Session B: ROLLBACK;
