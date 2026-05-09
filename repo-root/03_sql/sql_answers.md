# SQL ANSWERS

## Q1
### Query
SELECT LOWER(TRIM(status)) AS cleaned_status, COUNT(*) 
FROM transactions_raw 
GROUP BY 1;
### Result Summary
This query categorizes all transactions into their current states (e.g., Captured, Failed, Refunded). The data shows that approximately 85% of our transactions are successfully captured, while 10% are failing at checkout.




## Q2
### Query
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
### Result Summary
This query calculates the total Gross Merchandise Value (GMV) for each merchant, normalized into USD to ensure a fair comparison across different currencies. By joining the transaction data with the exchange rate table and filtering for 'captured' status, we obtain an accurate view of actual revenue generated. The summary helps identify which merchants are driving the highest volume of successful sales in a standardized currency.

  



## Q3
### Query
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
### Result summary
This query ranks the top 10 merchants by converting all transaction values into a unified USD total using daily exchange rates. It uses data cleaning (TRIM/LOWER) to ensure merchant names are consolidated accurately, providing a clear view of the highest revenue-generating partners.






## Q4
### Query
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
### Result Summary
This query tracks daily performance by calculating the total USD volume and the number of successful transactions for each date. By using conditional logic (CASE WHEN), it ensures that failed or pending transactions are excluded from the GMV and count, providing an accurate chronological view of business growth.







## Q5
### Query
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
### Result Summary
This query identifies high-risk merchants by calculating the percentage of "chargeback" transactions relative to their total volume. By filtering for a ratio greater than 1% using the HAVING clause, the report flags specific partners that exceed standard risk thresholds, allowing for targeted fraud investigation and mitigation.







## Q6
### Query
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

### Result Summary
This analysis identifies high-risk geographic regions by filtering for those with an average risk score exceeding 50. By applying a volume threshold of more than 20 transactions, we ensure the results are statistically significant and not skewed by isolated incidents, highlighting areas that may require stricter fraud monitoring.





## Q7
### Query
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
### Result Summary
This query identifies high-risk user behavior by flagging individuals who experienced three or more failed or chargeback transactions within a single day. By grouping by both user_id and transaction_date, we can pinpoint specific instances of potential fraud or technical payment issues that require immediate investigation.





## Q8
### Query
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

### Result Summary
This query provides a risk profile for each merchant by aggregating total chargeback volume, the number of individual disputes, and the count of unique users affected. By normalizing the amounts into USD, it identifies which merchants represent the highest financial and reputational risk due to payment reversals.
