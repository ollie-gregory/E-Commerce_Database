-- Query Examples

-- Query 1: Retrieves all customers and any orders they have placed.
SELECT
    c.cst_name AS "Customer Name",
    c.cst_email AS "Customer Email",
    o.o_number AS "Order Number",
    o.o_date AS "Order date",
    o.o_total AS "Order total",
    GROUP_CONCAT(p.p_name || ' (Qty: ' || op.p_o_quantity || ')') AS "Products Ordered"
FROM CUSTOMER AS c
LEFT OUTER JOIN ORDERS AS o ON c.cst_email = o.cst_email
LEFT OUTER JOIN ORDER_PRODUCT AS op ON o.o_number = op.o_number
LEFT OUTER JOIN PRODUCT AS p ON op.p_number = p.p_number
GROUP BY c.cst_email, o.o_number
ORDER BY c.cst_name, o.o_date DESC

-- Query 2: Retrieves customers who have items in their baskets, their birthdays and if they have any gift card balances.
SELECT
	c.cst_name AS "Customer Name",
	c.cst_email AS "Customer Email",
	c.cst_birth_date AS "Birthday",
	gc.current_balance AS "Gift Card Current Balance",
	GROUP_CONCAT(p.p_name || ' (Qty: ' || bp.bsk_quantity || ')') AS "Basket Items"
FROM BASKET AS b
JOIN BASKET_PRODUCT AS bp ON bp.basket_id = b.basket_id
JOIN PRODUCT AS p ON bp.p_number = p.p_number
JOIN CUSTOMER AS c ON b.cst_email = c.cst_email
LEFT OUTER JOIN PAYMENT_METHOD AS pm ON c.cst_email = pm.cst_email AND pm.payment_method = 'GIFT_CARD'
LEFT OUTER JOIN GIFT_CARD AS gc ON pm.payment_method_id = gc.card_id
GROUP BY b.basket_id;

-- Query 3: Retrieves the top 2 selling products in each category.
SELECT 
    p_category AS "Product Category",
    p_name AS "Product Name",
    total_sold AS "Quantity Sold",
    total_revenue AS "Total Revenue"
FROM 
    (SELECT 
		p.p_category,
		p.p_name,
		SUM(op.p_o_quantity) AS total_sold,
		SUM(op.p_o_subtotal) AS total_revenue,
		ROW_NUMBER() OVER (PARTITION BY p.p_category ORDER BY SUM(op.p_o_quantity) DESC) AS sales_rank
	FROM PRODUCT AS p
	JOIN ORDER_PRODUCT AS op ON p.p_number = op.p_number
	GROUP BY p.p_category, p.p_name)
WHERE 
    sales_rank <= 2
ORDER BY 
    p_category, total_sold DESC;

-- Query 4: Monthly sales growth (net of any returns)
WITH MonthlySales AS (
    SELECT 
        strftime('%Y', o.o_date) AS year,
        strftime('%m', o.o_date) AS month,
        SUM(o.o_grand_total - IFNULL(r.rt_refund_total, 0)) AS total_sales
    FROM ORDERS AS o
    LEFT JOIN ORDER_RETURNS AS r ON o.o_number = r.o_number AND r.rt_status = 'Completed'
    GROUP BY year, month
    ORDER BY year, month
),
SalesGrowth AS (
    SELECT 
        year,
        month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY year, month) AS previous_month_sales
    FROM MonthlySales
)
SELECT 
    year AS "Year",
    month AS "Month",
    total_sales AS "Total Sales",
    CONCAT(ROUND(((total_sales - previous_month_sales) * 100.0) / previous_month_sales, 2) || '%') AS "Sales Growth"
FROM SalesGrowth;

--- Trigger to prevent customers reviewing products they have not purchased
CREATE TRIGGER REVIEW_VIOLATION
BEFORE INSERT ON REVIEW
FOR EACH ROW
WHEN NOT EXISTS (
    SELECT 1
    FROM ORDERS AS o
    JOIN ORDER_PRODUCT AS op ON o.o_number = op.o_number
    WHERE o.cst_email = NEW.cst_email
    AND op.p_number = NEW.p_number
)
BEGIN
    SELECT RAISE(FAIL, 'Review violation: Customer has not ordered this product.');
END;