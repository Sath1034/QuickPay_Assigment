--Q1

SELECT LOWER(TRIM(status)) AS cleaned_status, COUNT(*) 
FROM transactions_raw 
GROUP BY 1;


--Q2

SELECT 
    m.merchant_name, 
    SUM(t.raw_amount * er.usd_rate) AS total_captured_gmv_usd
FROM transactions_raw t
JOIN merchant_master m 
    ON TRIM(LOWER(t.merchant_name)) = TRIM(LOWER(m.merchant_name))
JOIN exchange_rates er 
    ON t.currency = er.currency 
    AND t.transaction_date = er.rate_date
WHERE LOWER(TRIM(t.status)) = 'captured'
GROUP BY 1
ORDER BY total_captured_gmv_usd DESC;




--Q3

SELECT 
    m.merchant_name, 
    SUM(t.raw_amount * er.usd_rate) AS total_captured_gmv_usd
FROM transactions_raw t
-- Join with Merchant Master to get clean names
JOIN merchant_master m 
    ON TRIM(LOWER(t.merchant_name)) = TRIM(LOWER(m.merchant_name))
-- Join with Exchange Rates on both Currency and Date
JOIN exchange_rates er 
    ON t.currency = er.currency 
    AND t.transaction_date = er.rate_date
-- Filter for only 'captured' (successful) transactions
WHERE LOWER(TRIM(t.status)) = 'captured'
GROUP BY m.merchant_name
ORDER BY total_captured_gmv_usd DESC
LIMIT 10;





--Q4

SELECT 
    t.transaction_date,
    -- Summing only 'captured' amounts converted to USD
    SUM(CASE WHEN LOWER(TRIM(t.status)) = 'captured' THEN t.raw_amount * er.usd_rate ELSE 0 END) AS daily_gmv_usd,
    -- Counting only the successful 'captured' transactions
    COUNT(CASE WHEN LOWER(TRIM(t.status)) = 'captured' THEN 1 END) AS successful_transaction_count
FROM transactions_raw t
JOIN exchange_rates er 
    ON t.currency = er.currency 
    AND t.transaction_date = er.rate_date
GROUP BY t.transaction_date
ORDER BY t.transaction_date ASC;




--Q5

SELECT 
        m.merchant_name,
        COUNT(CASE WHEN LOWER(TRIM(t.status)) = 'chargeback' THEN 1 END) AS chargeback_count,
        COUNT(t.transaction_id) AS total_transactions,
        -- Ratio Calculation: (Chargebacks / Total) * 100
        (COUNT(CASE WHEN LOWER(TRIM(t.status)) = 'chargeback' THEN 1 END) * 100.0 / COUNT(t.transaction_id)) AS chargeback_ratio
    FROM transactions_raw t
    JOIN merchant_master m 
        ON TRIM(LOWER(t.merchant_name)) = TRIM(LOWER(m.merchant_name))
    GROUP BY m.merchant_name
    -- Filter for merchants exceeding the 1% threshold
    HAVING chargeback_ratio > 1
    ORDER BY chargeback_ratio DESC;




--Q6

SELECT 
    m.default_region, 
    AVG(t.risk_score) AS average_risk_score, 
    COUNT(t.transaction_id) AS total_transactions
FROM transactions_raw t
JOIN merchant_master m 
    ON TRIM(LOWER(t.merchant_name)) = TRIM(LOWER(m.merchant_name))
GROUP BY m.default_region
-- Filter aggregated results based on the task requirements
HAVING average_risk_score > 50 
   AND total_transactions > 20;





--Q7
SELECT 
        user_id, 
        transaction_date, 
        COUNT(*) AS problem_transaction_count
    FROM transactions_raw
    -- Filter for only failed or chargeback statuses
    WHERE LOWER(TRIM(status)) IN ('failed', 'failed e05 timeout', 'chargeback')
    -- Group by user and date to find same-day occurrences
    GROUP BY user_id, transaction_date
    -- Filter for the specific '3 or more' threshold
    HAVING problem_transaction_count >= 3;




--Q8
SELECT 
        m.merchant_name, 
        COUNT(t.transaction_id) AS chargeback_count, 
        COUNT(DISTINCT t.user_id) AS unique_affected_users,
        SUM(t.raw_amount * er.usd_rate) AS total_chargeback_amount_usd
    FROM transactions_raw t
    -- Join with Merchant Master for standardized naming
    JOIN merchant_master m 
        ON TRIM(LOWER(t.merchant_name)) = TRIM(LOWER(m.merchant_name))
    -- Join with Exchange Rates to normalize financial values
    JOIN exchange_rates er 
        ON t.currency = er.currency 
        AND t.transaction_date = er.rate_date
    -- Filter specifically for chargeback status
    WHERE LOWER(TRIM(t.status)) = 'chargeback'
    GROUP BY m.merchant_name
    ORDER BY total_chargeback_amount_usd DESC;

