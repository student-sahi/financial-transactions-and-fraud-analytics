create database Financial_Fraud;
use financial_fraud;

-- --------------- MERCHANT ANALYSIS ----------------
-- 1) Which merchant category generates the highest total revenue and transaction count?
Select m.merchant_category, 
	   Round(sum(t.transaction_amount),2) As Transaction_Amount,
       count(t.transaction_id) As Total_Count
		from merchant m join transactions t 
        On m.merchant_id = t.merchant_id
        Where t.transaction_status = 'Successful'
        Group by m.merchant_category;
        
-- 2) Which top 10 merchants (by name) have the highest total transaction value?
Select m.merchant_name,m.merchant_category,
	   Round(sum(t.transaction_Amount),2) As Total_Amount
       from merchant m join transactions t
       On m.merchant_id = t.merchant_id
       Where t.transaction_status = 'Successful'
       group by m.merchant_name,m.merchant_category
       order by Total_Amount desc
       limit 15;
       
-- 3) What is the fraud rate by Merchant_risk_level.
SELECT 
    merchant_risk_level,
    COUNT(*) AS Total_Transactions,
    SUM(fraud_flag) AS Fraud_Count,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 2) AS Fraud_Rate_Pct
FROM transactions
GROUP BY merchant_risk_level
ORDER BY Fraud_Rate_Pct DESC;
       
-- ----------- Transaction Behavior ----------------
-- 4) Which transaction channel (POS/Mobile App/Web) and device type is most used, and what's the average ticket size for each?
select transaction_channel,
       count(transaction_id) As Total_Count,
       Round(sum(Transaction_amount),2) As Total_Amount,
       Round(Avg(Transaction_Amount),2) As Avg_Transaction_Amount
       from transactions 
       Where transaction_status ='Successful'
       group by transaction_channel;
       
-- 5) What is the success vs failure/declined rate of transactions?
 SELECT 
    transaction_status,
    COUNT(*) AS Total_Transactions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions), 2) AS Percentage
FROM transactions
GROUP BY transaction_status
ORDER BY Total_Transactions DESC;

-- 6) What % of transactions are international, and how does their average amount compare to domestic ones?
SELECT 
    CASE WHEN is_international = 1 THEN 'International' ELSE 'Domestic' END AS Transaction_Type,
    COUNT(*) AS Total_Transactions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions WHERE transaction_status = 'Successful'), 2) AS Percentage,
    ROUND(AVG(transaction_amount), 2) AS Avg_Amount
FROM transactions
WHERE transaction_status = 'Successful'
GROUP BY is_international
ORDER BY Transaction_Type;

-- -----------Card Insights--------------
-- 7) How many active vs inactive/blocked cards exist by Card_Type and Card_Network?
Select card_type,
	   card_network,
       sum(case when card_status = 'Active' then 1 else 0 end) As Active,
	   sum(case when card_status = 'Expired' then 1 else 0 end) As Expired,
	   sum(case when card_status = 'Blocked' then 1 else 0 end) As Blocked,
       sum(case when card_status = 'Lost' then 1 else 0 end) As Lost
       from cards
       group by card_network,card_type;
       
-- 8) What is the average credit limit by Card_Type, and which customers are closest to exceeding it?
SELECT 
    c.customer_id,
    c.card_id,
    c.card_type,
    c.credit_limit,
    ROUND(SUM(t.transaction_amount), 2) AS Monthly_Spent,
    ROUND(SUM(t.transaction_amount) * 100.0 / c.credit_limit, 2) AS Pct_Utilized
FROM cards c
JOIN transactions t 
    ON c.card_id = t.card_id
WHERE t.transaction_status = 'Successful'
  AND t.transaction_date >= (SELECT MAX(transaction_date) FROM transactions) - INTERVAL 30 DAY
GROUP BY c.customer_id, c.card_id, c.card_type, c.credit_limit
ORDER BY Pct_Utilized DESC
LIMIT 20;

-- 9) What is the fraud rate for each card mode (Physical vs Virtual), and which mode has a higher proportion of fraudulent transactions?"
SELECT 
    c.card_mode,
    COUNT(t.transaction_id) AS Total_Transactions,
    SUM(t.fraud_flag) AS Fraudulent_Transactions,
    ROUND(SUM(t.fraud_flag) * 100.0 / COUNT(t.transaction_id), 2) AS Fraud_Rate_Pct
FROM cards c
JOIN transactions t 
    ON c.card_id = t.card_id
GROUP BY c.card_mode
ORDER BY Fraud_Rate_Pct DESC;

-- 10) Which card network (Visa/Mastercard/RuPay/Amex) has the highest total transaction volume?
select c.card_network,
		count(t.transaction_id) as Total_Transactions,
        round(sum(t.transaction_amount),2) as Total_Amount
        from cards c join transactions t 
        on c.card_id = t.card_id
        where t.transaction_status = 'Successful'
        group by c.card_network
        order by total_amount desc;
        
-- ----------------- CUSTOMER INSIGHTS -------------------

-- 11) What is the distribution of customers by segment ?
select customer_segment, count(*) as total_customers,
round(count(*) *100 / (select count(*) from customers ),2) as percentage
from customers 
group by customer_segment
order by percentage desc;

-- 12) Which state has the highest average annual income among customers?
Select state,
	   Round(avg(Annual_Income),2) As Avg_Income,
       count(*) As Total_Customers
       from customers 
       group by state
       order by Avg_Income desc
       limit 10;
       
-- 13) Who are the top 10 customers by total transaction spend
Select c.customer_id,
	   c.customer_name,
       count(T.transaction_ID) As Total_Transactions,
       Round(sum(t.transaction_amount),2) As Total_Amount
       from customers c join transactions t 
       on c.customer_id = t.customer_id
       Where t.transaction_status = 'Successful'
       group by c.customer_id,c.customer_name
       order by total_amount desc
       Limit 15;
       
-- ---------------- FRAUD Analysis ------------------------
-- 14) What is the fraud rate (Fraud_Flag=1) by Merchant_Category.
SELECT 
    merchant_category,
    COUNT(*) AS Total_Transactions,
    SUM(fraud_flag) AS Fraud_Count,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 2) AS Fraud_Rate_Pct
FROM transactions
GROUP BY merchant_category
ORDER BY Fraud_Rate_Pct DESC;

-- 15) What are the most common Fraud_Reason values?
SELECT 
    fraud_reason,
    COUNT(*) AS Total_Cases,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions WHERE fraud_flag = 1), 2) AS Pct_Of_Fraud
FROM transactions
WHERE fraud_flag = 1
GROUP BY fraud_reason
ORDER BY Total_Cases DESC;

-- 16) which customer cities have the highest fraud concentration?
SELECT 
    customer_city,
    COUNT(*) AS Total_Transactions,
    SUM(fraud_flag) AS Fraud_Count,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 2) AS Fraud_Rate_Pct
FROM transactions
GROUP BY customer_city
HAVING COUNT(*) >= 30
ORDER BY Fraud_Rate_Pct DESC
LIMIT 10;