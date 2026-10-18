-- check if the table was loaded properly

SELECT COUNT(*) AS total_rows
FROM supply_chain;

SELECT *
FROM supply_chain
LIMIT 10;


-- overall numbers

SELECT
    COUNT(DISTINCT "Order Id") AS total_orders,
    COUNT(DISTINCT "Customer Id") AS total_customers,
    COUNT(*) AS total_order_items,
    ROUND(SUM("Sales")::numeric, 2) AS total_sales,
    ROUND(SUM("profit")::numeric, 2) AS total_profit,
    ROUND(SUM("discount_amount")::numeric, 2) AS total_discount,
    ROUND((SUM("profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin,
    ROUND((SUM("Sales") / COUNT(DISTINCT "Order Id"))::numeric, 2) AS average_order_value
FROM supply_chain;


-- market wise sales and profit

SELECT
    "Market",
    COUNT(DISTINCT "Order Id") AS total_orders,
    ROUND((SUM("Sales") / 1000000)::numeric, 2) AS total_sales_m,
    ROUND((SUM("profit") / 1000000)::numeric, 2) AS total_profit_m,
    ROUND((SUM("profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin,
    ROUND((SUM("Sales") / COUNT(DISTINCT "Order Id"))::numeric, 2) AS average_order_value
FROM supply_chain
GROUP BY "Market"
ORDER BY total_sales_m DESC;


-- department wise performance

SELECT
    "Department Name",
    ROUND((SUM("Sales") / 1000000)::numeric, 2) AS total_sales_m,
    ROUND((SUM("profit") / 1000000)::numeric, 2) AS total_profit_m,
    ROUND((SUM("profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin,
    COUNT(*) AS order_items
FROM supply_chain
GROUP BY "Department Name"
ORDER BY total_sales_m DESC;


-- checking shipping modes

SELECT
    "Shipping Mode",
    COUNT(*) AS order_items,
    ROUND((SUM("Sales") / 1000000)::numeric, 2) AS total_sales_m,
    ROUND((SUM("profit") / 1000000)::numeric, 2) AS total_profit_m,
    ROUND(AVG("delivery_days")::numeric, 2) AS avg_delivery_days,
    ROUND(
        (SUM(CASE WHEN "is_late" = TRUE THEN 1 ELSE 0 END)::numeric
        / COUNT(*) * 100),
        2
    ) AS late_delivery_rate
FROM supply_chain
GROUP BY "Shipping Mode"
ORDER BY total_sales_m DESC;


-- customer segment

SELECT
    "Customer Segment",
    COUNT(DISTINCT "Customer Id") AS customers,
    COUNT(DISTINCT "Order Id") AS orders,
    ROUND((SUM("Sales") / 1000000)::numeric, 2) AS total_sales_m,
    ROUND((SUM("profit") / 1000000)::numeric, 2) AS total_profit_m,
    ROUND((SUM("profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin
FROM supply_chain
GROUP BY "Customer Segment"
ORDER BY total_sales_m DESC;


-- delivery status

SELECT
    "Delivery Status",
    COUNT(*) AS order_items,
    ROUND(
        (COUNT(*)::numeric /
        (SELECT COUNT(*) FROM supply_chain) * 100),
        2
    ) AS percentage
FROM supply_chain
GROUP BY "Delivery Status"
ORDER BY order_items DESC;


-- order status

SELECT
    "Order Status",
    COUNT(*) AS order_items,
    ROUND(
        (COUNT(*)::numeric /
        (SELECT COUNT(*) FROM supply_chain) * 100),
        2
    ) AS percentage
FROM supply_chain
GROUP BY "Order Status"
ORDER BY order_items DESC;


-- monthly trend

SELECT
    "order_year_month",
    ROUND((SUM("Sales") / 1000000)::numeric, 2) AS total_sales_m,
    ROUND((SUM("profit") / 1000000)::numeric, 2) AS total_profit_m,
    ROUND((SUM("profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin
FROM supply_chain
GROUP BY "order_year_month"
ORDER BY "order_year_month";


-- top products by sales

SELECT
    "Product Name",
    ROUND(SUM("Sales")::numeric, 2) AS total_sales,
    ROUND(SUM("profit")::numeric, 2) AS total_profit,
    COUNT(*) AS order_items
FROM supply_chain
GROUP BY "Product Name"
ORDER BY total_sales DESC
LIMIT 10;


-- top products by profit

SELECT
    "Product Name",
    ROUND(SUM("Sales")::numeric, 2) AS total_sales,
    ROUND(SUM("profit")::numeric, 2) AS total_profit,
    ROUND((SUM("profit") / SUM("Sales") * 100)::numeric, 2) AS profit_margin
FROM supply_chain
GROUP BY "Product Name"
ORDER BY total_profit DESC
LIMIT 10;


-- products making a loss

SELECT
    "Product Name",
    ROUND(SUM("Sales")::numeric, 2) AS total_sales,
    ROUND(SUM("profit")::numeric, 2) AS total_profit,
    COUNT(*) AS order_items
FROM supply_chain
GROUP BY "Product Name"
HAVING SUM("profit") < 0
ORDER BY total_profit ASC
LIMIT 10;


-- checking market and shipping together

SELECT
    "Market",
    "Shipping Mode",
    COUNT(*) AS order_items,
    ROUND((SUM("Sales") / 1000000)::numeric, 2) AS total_sales_m,
    ROUND((SUM("profit") / 1000000)::numeric, 2) AS total_profit_m,
    ROUND(AVG("delivery_days")::numeric, 2) AS avg_delivery_days,
    ROUND(
        (SUM(CASE WHEN "is_late" = TRUE THEN 1 ELSE 0 END)::numeric
        / COUNT(*) * 100),
        2
    ) AS late_delivery_rate
FROM supply_chain
GROUP BY "Market", "Shipping Mode"
ORDER BY "Market", total_sales_m DESC;


-- products above average profit

WITH product_profit AS (
    SELECT
        "Product Name",
        SUM("profit") AS total_profit
    FROM supply_chain
    GROUP BY "Product Name"
)
SELECT
    "Product Name",
    ROUND(total_profit::numeric, 2) AS total_profit
FROM product_profit
WHERE total_profit > (
    SELECT AVG(total_profit)
    FROM product_profit
)
ORDER BY total_profit DESC;


-- top products in each department

WITH ranked_products AS (
    SELECT
        "Department Name",
        "Product Name",
        SUM("Sales") AS total_sales,
        SUM("profit") AS total_profit,
        RANK() OVER (
            PARTITION BY "Department Name"
            ORDER BY SUM("profit") DESC
        ) AS product_rank
    FROM supply_chain
    GROUP BY
        "Department Name",
        "Product Name"
)
SELECT
    "Department Name",
    "Product Name",
    ROUND(total_sales::numeric, 2) AS total_sales,
    ROUND(total_profit::numeric, 2) AS total_profit,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY
    "Department Name",
    product_rank;


-- month on month sales growth

WITH monthly_sales AS (
    SELECT
        "order_year_month",
        SUM("Sales") AS total_sales
    FROM supply_chain
    GROUP BY "order_year_month"
),
sales_with_previous AS (
    SELECT
        "order_year_month",
        total_sales,
        LAG(total_sales) OVER (
            ORDER BY "order_year_month"
        ) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    "order_year_month",
    ROUND((total_sales / 1000000)::numeric, 2) AS sales_m,
    ROUND((previous_month_sales / 1000000)::numeric, 2) AS previous_sales_m,
    ROUND(
        (
            (total_sales - previous_month_sales)
            / previous_month_sales * 100
        )::numeric,
        2
    ) AS mom_growth_percent
FROM sales_with_previous
ORDER BY "order_year_month";


-- running total of sales

SELECT
    "order_year_month",
    ROUND(
        (SUM(SUM("Sales")) OVER (
            ORDER BY "order_year_month"
        ) / 1000000)::numeric,
        2
    ) AS cumulative_sales_m
FROM supply_chain
GROUP BY "order_year_month"
ORDER BY "order_year_month";


-- how much each market contributes to total sales

SELECT
    "Market",
    ROUND((SUM("Sales") / 1000000)::numeric, 2) AS sales_m,
    ROUND(
        (
            SUM("Sales")
            / SUM(SUM("Sales")) OVER ()
            * 100
        )::numeric,
        2
    ) AS sales_share_percent
FROM supply_chain
GROUP BY "Market"
ORDER BY sales_share_percent DESC;


-- ranking markets by profit

WITH market_profit AS (
    SELECT
        "Market",
        SUM("profit") AS total_profit
    FROM supply_chain
    GROUP BY "Market"
)
SELECT
    "Market",
    ROUND((total_profit / 1000000)::numeric, 2) AS profit_m,
    RANK() OVER (
        ORDER BY total_profit DESC
    ) AS profit_rank
FROM market_profit
ORDER BY profit_rank;


-- loss rate by market

SELECT
    "Market",
    COUNT(*) AS order_items,
    SUM(CASE WHEN "is_loss" = TRUE THEN 1 ELSE 0 END) AS loss_items,
    ROUND(
        (
            SUM(CASE WHEN "is_loss" = TRUE THEN 1 ELSE 0 END)::numeric
            / COUNT(*) * 100
        ),
        2
    ) AS loss_rate_percent,
    ROUND((SUM("profit") / 1000000)::numeric, 2) AS total_profit_m
FROM supply_chain
GROUP BY "Market"
ORDER BY loss_rate_percent DESC;