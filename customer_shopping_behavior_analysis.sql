CREATE DATABASE customer_shopping_analysis;

USE customer_shopping_analysis;

SELECT DATABASE();

-- Create table

CREATE TABLE customer_shopping (
    customer_id INT,
    age INT,
    gender VARCHAR(20),
    item_purchased VARCHAR(100),
    category VARCHAR(50),
    purchase_amount DECIMAL(10,2),
    location VARCHAR(100),
    size VARCHAR(10),
    color VARCHAR(50),
    season VARCHAR(20),
    review_rating DECIMAL(3,2),
    subscription_status VARCHAR(20),
    shipping_type VARCHAR(50),
    discount_applied VARCHAR(10),
    previous_purchases INT,
    payment_method VARCHAR(50),
    frequency_of_purchases VARCHAR(50),
    age_group VARCHAR(30),
    purchase_frequency_days INT
);

USE customer_shopping_analysis;

SELECT COUNT(*) AS total_records
FROM customer_shopping_behavior_cleaned;

-- overall business performance
SELECT
    COUNT(*) AS total_purchases,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(purchase_amount) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount,
    ROUND(AVG(review_rating), 2) AS average_review_rating
FROM customer_shopping_behavior_cleaned;

-- Product Category Performance
-- Which product categories generate the highest revenue and have the highest average purchase value?

SELECT
    category,
    COUNT(*) AS total_purchases,
    SUM(purchase_amount) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount
FROM customer_shopping_behavior_cleaned
GROUP BY category
ORDER BY total_revenue DESC;

-- Customer Loyalty & Revenue

-- How does customer loyalty relate to spending and revenue?

SELECT
    CASE
        WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment,
    
    COUNT(*) AS total_purchases,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount,
    SUM(purchase_amount) AS total_revenue

FROM customer_shopping_behavior_cleaned

GROUP BY customer_segment

ORDER BY total_revenue DESC;

-- Subscription & Customer Spending

-- Do subscribed customers spend more than non-subscribed customers?

SELECT
    subscription_status,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) AS total_purchases,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount,
    SUM(purchase_amount) AS total_revenue
FROM customer_shopping_behavior_cleaned
GROUP BY subscription_status
ORDER BY average_purchase_amount DESC;

-- Discount Impact on Customer Spending

-- Do customers who receive discounts have a different average purchase amount than customers who don't?

SELECT
    discount_applied,
    COUNT(*) AS total_purchases,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount,
    SUM(purchase_amount) AS total_revenue
FROM customer_shopping_behavior_cleaned
GROUP BY discount_applied
ORDER BY average_purchase_amount DESC;

-- Product Performance
-- Which products generate the highest revenue?

SELECT
    item_purchased,
    COUNT(*) AS total_purchases,
    SUM(purchase_amount) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount
FROM customer_shopping_behavior_cleaned
GROUP BY item_purchased
ORDER BY total_revenue DESC
LIMIT 10;

-- Age Group & Revenue Analysis

-- Which age groups contribute the most revenue?

SELECT
    age_group,
    COUNT(*) AS total_purchases,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(purchase_amount) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount
FROM customer_shopping_behavior_cleaned
GROUP BY age_group
ORDER BY total_revenue DESC;

-- Payment Method Preferences
-- Which payment methods are most preferred by customers, and how much revenue does each method generate?

SELECT
    payment_method,
    COUNT(*) AS total_purchases,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(purchase_amount) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount
FROM customer_shopping_behavior_cleaned
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Seasonal & Category Performance
-- Which product categories perform best across different seasons?

SELECT
    season,
    category,
    COUNT(*) AS total_purchases,
    SUM(purchase_amount) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS average_purchase_amount
FROM customer_shopping_behavior_cleaned
GROUP BY season, category
ORDER BY season, total_revenue DESC;

-- Top Products Within Each Category
-- Which products generate the highest revenue within each product category?
WITH product_revenue AS (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS total_purchases,
        SUM(purchase_amount) AS total_revenue,
        ROUND(AVG(purchase_amount), 2) AS average_purchase_amount
    FROM customer_shopping_behavior_cleaned
    GROUP BY category, item_purchased
),
ranked_products AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM product_revenue
)
SELECT
    category,
    item_purchased,
    total_purchases,
    total_revenue,
    average_purchase_amount,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY category, product_rank;
