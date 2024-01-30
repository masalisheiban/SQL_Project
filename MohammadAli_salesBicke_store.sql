
USE BikeStores;

-- 1 Stores by Sales Revenue foe 3 years:
    SELECT s.store_id, s.store_name, 
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_sales
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN stores s ON o.store_id = s.store_id
GROUP BY s.store_id, s.store_name
ORDER BY store_id;

-- number of itemes:

SELECT COUNT(*) AS total_product_count
FROM products;

#############

SELECT store_id, store_name, state
FROM stores;
----------

   -- 2 Sales by Product Category for 3 years:
    SELECT c.category_name,
ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS category_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY category_sales DESC;
------------------------

-- 3. Highdemand product sales sales:
SELECT p.product_id, p.product_name, SUM(oi.quantity) as total_quantity_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;
----------------
SELECT 
    p.product_id, 
    p.product_name, 
    c.category_name,
    SUM(oi.quantity) AS total_quantity_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_income
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN  orders o ON oi.order_id = o.order_id
WHERE  o.order_id
GROUP BY  p.product_id, p.product_name, c.category_name
ORDER BY  total_quantity_sold DESC
LIMIT 10;

-- 4. monthly income sales for 3 years:
SELECT
    YEAR(ot.order_date) AS order_year,
    MONTH(ot.order_date) AS order_month,
    ROUND(SUM(ot.total_amount),2) AS total_sales
FROM (
    SELECT
        o.order_id,
        o.order_date,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_amount
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.order_date
) AS ot
GROUP BY  order_year, order_month
ORDER BY order_year, order_month;
----------------
-- 4. Sales quarter fro 3 years:
SELECT YEAR(order_date) AS order_year, 
       QUARTER(order_date) AS order_quarter, 
       SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY order_year, order_quarter
ORDER BY order_year, order_quarter;

-------------
-- 5.The incomes from each type of product:
SELECT 
    s.store_id, 
    p.product_id, 
    p.product_name, 
    SUM(oi.quantity) AS total_quantity_sold,
    st.quantity AS current_inventory,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_amount_paid
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN stocks st ON p.product_id = st.product_id AND o.store_id = st.store_id
JOIN stores s ON o.store_id = s.store_id
WHERE o.order_id
GROUP BY s.store_id, p.product_id
ORDER BY s.store_id, total_quantity_sold DESC;
--------------
 -- 6.Sales evaluate per months with N of order during 3 years:
SELECT 
    YEAR(o.order_date) AS order_year, 
    MONTH(o.order_date) AS order_month, 
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_sales,
    ROUND(COUNT(*),2) AS total_orders
FROM orders o
JOIN  order_items oi ON o.order_id = oi.order_id
GROUP BY order_year, order_month
ORDER BY  order_year, order_month;
-------------------------------

 # Customer lolaity:
-- 7.from these quiry I try to under stand the geographic disterbutions of custome for each store:
    
SELECT c.city, c.state, s.store_name, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN stores s ON o.store_id = s.store_id
GROUP BY c.city, c.state, s.store_name
ORDER BY order_count DESC
LIMIT 10;
-- 8. I nacome from each state:
SELECT 
    c.state, 
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS sales_income, 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.state;
-------------------------
-- 9. Quantity of customers for each store:
SELECT 
    s.store_id, 
    s.store_name, 
    COUNT(DISTINCT o.customer_id) AS customer_count
FROM stores s
LEFT JOIN  orders o ON s.store_id = o.store_id
GROUP BY  s.store_id, s.store_name
ORDER BY customer_count ASC;    
    
  
  -- 10. Customer Purchase history:
  
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name, 
    COUNT(o.order_id) AS total_orders, 
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS total_amount_paid,
    SUM(oi.quantity) AS total_purchased_items
FROM customers c
LEFT JOIN  orders o ON c.customer_id = o.customer_id
LEFT JOIN  order_items oi ON o.order_id = oi.order_id
WHERE  o.order_id
GROUP BY c.customer_id, full_name
ORDER BY  total_amount_paid DESC;
-----------------
-- 11.Top 10 Customers:
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, '  ', c.last_name) AS full_name, 
    COUNT(o.order_id) AS total_orders, 
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS total_amount_paid,
    SUM(oi.quantity) AS total_purchased_items
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_id
GROUP BY c.customer_id, full_name
ORDER BY total_amount_paid DESC
LIMIT 10;
---------
-- 12. history order customer id_94 that top one of customers.
SELECT o.order_id, o.order_date,oi.product_id, p.product_name, oi.quantity, oi.list_price, oi.discount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.customer_id = 94;
---------------
-- 13 cheked the highst price like 40 and 205.
SELECT o.order_id, o.order_date, oi.product_id, p.product_name, oi.quantity, oi.list_price, oi.discount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE oi.product_id IN (205, 40);
----------
-- 14. cheked for if thy are availble in stock:
SELECT s.store_id, s.product_id, p.product_name, s.quantity
FROM stocks s
JOIN products p ON s.product_id = p.product_id
WHERE s.product_id IN (205, 40);

----------
-- 14. Bottom 10 customers:
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, '  ', c.last_name) AS full_name, 
    COUNT(o.order_id) AS total_orders, 
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS total_amount_paid,
    SUM(oi.quantity) AS total_purchased_items
FROM customers c
LEFT JOIN  orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_id
GROUP BY c.customer_id, full_name
ORDER BY total_amount_paid ASC
LIMIT 10;
--------------------------------

   -- 15.shipping satus; 
SELECT 
    order_id, 
    required_date, 
    shipped_date, 
   
    CASE 
        WHEN DATEDIFF(shipped_date, required_date) <= 1 THEN 'Express'
        WHEN DATEDIFF(shipped_date, required_date) = 2 THEN 'Cargo'
        ELSE 'Delayed'
    END AS status
FROM orders
WHERE order_id
ORDER BY status DESC;
------------------

-- 16. performance of employees for each store:
SELECT 
    s.store_id, 
    CONCAT(st.first_name, ' ', st.last_name) AS staff_name, 
    COUNT(o.order_id) AS total_orders_processed,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)),2) AS total_income
FROM orders o
JOIN staffs st ON o.staff_id = st.staff_id
JOIN stores s ON o.store_id = s.store_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_id  
GROUP BY s.store_id, st.staff_id
ORDER BY s.store_id, total_orders_processed DESC;

#########
-- 17. Mangement stock between inventory and sales
SELECT 
    p.product_id, 
    p.product_name, 
    SUM(s.quantity) AS total_current_availability,
    SUM(CASE WHEN s.store_id = 1 THEN s.quantity ELSE 0 END) AS quantity_in_store_1,
    SUM(CASE WHEN s.store_id = 2 THEN s.quantity ELSE 0 END) AS quantity_in_store_2,
    SUM(CASE WHEN s.store_id = 3 THEN s.quantity ELSE 0 END) AS quantity_in_store_3
FROM  products p
JOIN  stocks s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name;
----------------
-- 18 Order List price:
select * From order_items
order by discount, list_price;

-----------
-- 19- llist of all product sales with avg of discount for all product
WITH ProductSales AS (
    SELECT 
        oi.product_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales,
        AVG(oi.discount) AS avg_discount
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_id
    GROUP BY oi.product_id
)
SELECT 
    ps.product_id,
    ps.total_sales,
    ps.avg_discount
FROM 
    ProductSales ps;

-----------------------

-- 20. The sales classification with product group related 
SELECT 
    p.product_id, 
    p.product_name, 
    SUM(oi.quantity) AS total_quantity, 
    SUM(oi.quantity * p.list_price * (1 - oi.discount)) AS total_sales,
    CASE 
        WHEN SUM(oi.quantity * p.list_price * (1 - oi.discount)) >= 10000 THEN 'High sales income'
        WHEN SUM(oi.quantity * p.list_price * (1 - oi.discount)) >= 5000 THEN 'Moderate sales income'
        ELSE 'Low sales income'
    END AS sales_group
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN  orders o ON oi.order_id = o.order_id
WHERE  o.order_id
GROUP BY  p.product_id, p.product_name
ORDER BY total_sales DESC;
--------------------
-- 21. AVG price for each categeory:
SELECT c.category_name, ROUND(AVG(p.list_price),2) AS average_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name;