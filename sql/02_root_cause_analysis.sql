-- market late delivery rate

SELECT
    "Market",
    COUNT(*) AS total_items,
    SUM(
        CASE
            WHEN "Delivery Status" = 'Late delivery'
            THEN 1 ELSE 0
        END
    ) AS late_items,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Delivery Status" = 'Late delivery'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_rate
FROM supply_chain
GROUP BY "Market"
ORDER BY late_rate DESC;


-- shipping mode late delivery rate

SELECT
    "Shipping Mode",
    COUNT(*) AS total_items,
    SUM(
        CASE
            WHEN "Delivery Status" = 'Late delivery'
            THEN 1 ELSE 0
        END
    ) AS late_items,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Delivery Status" = 'Late delivery'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_rate
FROM supply_chain
GROUP BY "Shipping Mode"
ORDER BY late_rate DESC;


-- market and shipping mode together

SELECT
    "Market",
    "Shipping Mode",
    COUNT(*) AS total_items,
    SUM(
        CASE
            WHEN "Delivery Status" = 'Late delivery'
            THEN 1 ELSE 0
        END
    ) AS late_items,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Delivery Status" = 'Late delivery'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_rate
FROM supply_chain
GROUP BY
    "Market",
    "Shipping Mode"
ORDER BY
    "Market",
    late_rate DESC;


-- department late delivery rate

SELECT
    "Department Name",
    COUNT(*) AS total_items,
    SUM(
        CASE
            WHEN "Delivery Status" = 'Late delivery'
            THEN 1 ELSE 0
        END
    ) AS late_items,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN "Delivery Status" = 'Late delivery'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_rate
FROM supply_chain
GROUP BY "Department Name"
ORDER BY late_rate DESC;


-- market loss rate

SELECT
    "Market",
    COUNT(*) AS total_items,
    SUM(
        CASE
            WHEN profit < 0
            THEN 1 ELSE 0
        END
    ) AS loss_items,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN profit < 0
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS loss_rate,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM supply_chain
GROUP BY "Market"
ORDER BY loss_rate DESC;


-- products with higher loss rates

SELECT
    "Product Name",
    COUNT(*) AS total_items,
    SUM(
        CASE
            WHEN profit < 0
            THEN 1 ELSE 0
        END
    ) AS loss_items,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN profit < 0
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS loss_rate,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM supply_chain
GROUP BY "Product Name"
HAVING COUNT(*) >= 50
ORDER BY total_profit ASC
LIMIT 15;


-- discount level and profit

SELECT
    CASE
        WHEN "Order Item Discount Rate" < 0.10 THEN '0-10%'
        WHEN "Order Item Discount Rate" < 0.20 THEN '10-20%'
        WHEN "Order Item Discount Rate" < 0.30 THEN '20-30%'
        WHEN "Order Item Discount Rate" < 0.40 THEN '30-40%'
        ELSE '40%+'
    END AS discount_band,
    COUNT(*) AS total_items,
    ROUND(AVG(profit)::numeric, 2) AS avg_profit,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN profit < 0
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS loss_rate
FROM supply_chain
GROUP BY discount_band
ORDER BY discount_band;


-- shipping mode and profitability

SELECT
    "Shipping Mode",
    COUNT(*) AS total_items,
    ROUND(AVG(profit)::numeric, 2) AS avg_profit,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN profit < 0
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS loss_rate
FROM supply_chain
GROUP BY "Shipping Mode"
ORDER BY avg_profit ASC;