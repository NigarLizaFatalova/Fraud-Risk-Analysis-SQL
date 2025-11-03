/* ===========================================================
   FRAUD RISK ANALYSIS - MAIN SQL QUERIES
=========================================================== */

/* 1️⃣ Customer Segmentation & Risk Analysis */
WITH customer_segments AS (
    SELECT m.customer_id,
           CASE 
               WHEN MONTHS_BETWEEN(SYSDATE, m.registration_date) < 12 THEN 'New'
               WHEN MONTHS_BETWEEN(SYSDATE, m.registration_date) BETWEEN 12 AND 36 THEN 'Mid-term'
               ELSE 'Loyal'
           END AS customer_segment,
           k.card_id,
           CASE 
               WHEN k.credit_limit < 2000 THEN 'Standard'
               WHEN k.credit_limit BETWEEN 2000 AND 7500 THEN 'Gold'
               ELSE 'Platinum'
           END AS card_segment
    FROM Musteriler m
    JOIN Kartlar k ON m.customer_id = k.customer_id
)
SELECT cs.customer_segment,
       cs.card_segment,
       COUNT(*) AS total_tx,
       SUM(CASE WHEN t.is_fraud = 1 THEN 1 END) AS fraud_tx,
       ROUND(SUM(CASE WHEN t.is_fraud = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM customer_segments cs
JOIN Tranzaksiyalar t ON cs.card_id = t.card_id
GROUP BY cs.customer_segment, cs.card_segment
ORDER BY cs.customer_segment, cs.card_segment;


/* 2️⃣ Dormant Card – Time Before Fraud */
SELECT
    t.card_id,
    t.transaction_id,
    t.transaction_datetime,
    t.is_fraud,
    MAX(CASE WHEN is_fraud = 0 THEN transaction_datetime END)
        OVER (PARTITION BY card_id ORDER BY transaction_datetime
              ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
        AS last_legit_datetime,
    ROUND(
        (CAST(t.transaction_datetime AS DATE) -
         CAST(MAX(CASE WHEN is_fraud = 0 THEN transaction_datetime END)
              OVER (PARTITION BY card_id ORDER BY transaction_datetime
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS DATE))
    ) AS dormant_days
FROM Tranzaksiyalar t
ORDER BY t.card_id, t.transaction_datetime;


/* 3️⃣ Spending Velocity Anomaly */
SELECT 
    t.card_id,
    t.transaction_id,
    t.transaction_datetime,
    t.transaction_amount,
    t.is_fraud,
    SUM(t.transaction_amount) OVER (
        PARTITION BY t.card_id
        ORDER BY t.transaction_datetime
        RANGE BETWEEN INTERVAL '24' HOUR PRECEDING AND CURRENT ROW
    ) AS rolling_sum_24h,
    ROUND(
        AVG(t.transaction_amount) OVER (
            PARTITION BY t.card_id
            ORDER BY t.transaction_datetime
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_3tx
FROM Tranzaksiyalar t
ORDER BY t.card_id, t.transaction_datetime;


/* 4️⃣ First Attack Analysis – Stolen Cards Only */
WITH FirstFraudAttacks AS (
    SELECT *
    FROM (
        SELECT t.card_id,
               t.transaction_id,
               t.transaction_datetime,
               t.transaction_amount,
               ROW_NUMBER() OVER (PARTITION BY t.card_id ORDER BY t.transaction_datetime) AS rn
        FROM Tranzaksiyalar t
        JOIN Kartlar c ON t.card_id = c.card_id
        WHERE t.is_fraud = 1 AND c.card_status = 'Stolen'
    )
    WHERE rn = 1
)
SELECT 
    f.card_id,
    COUNT(t.transaction_id) AS follow_up_frauds,
    SUM(t.transaction_amount) AS total_loss
FROM FirstFraudAttacks f
JOIN Tranzaksiyalar t ON f.card_id = t.card_id
WHERE t.is_fraud = 1
  AND t.transaction_datetime BETWEEN f.transaction_datetime 
                                 AND f.transaction_datetime + INTERVAL '1' HOUR
GROUP BY f.card_id
ORDER BY f.card_id;


/* 5️⃣ Fraud Chain Mapping – Merchant Hotspots */
SELECT 
    s.merchant_name,
    COUNT(*) AS fraud_count,
    COUNT(DISTINCT t.card_id) AS unique_cards
FROM Tranzaksiyalar t
JOIN Saticilar s ON t.merchant_id = s.merchant_id
WHERE t.is_fraud = 1
GROUP BY s.merchant_name, TRUNC(t.transaction_datetime, 'HH24')
HAVING COUNT(DISTINCT t.card_id) > 5
ORDER BY fraud_count DESC;


/* 6️⃣ Smart Limit Rule Simulation */
SELECT 
  SUM(CASE WHEN t.is_fraud = 1 THEN 1 END) AS true_positive,
  SUM(CASE WHEN t.is_fraud = 0 THEN 1 END) AS false_positive,
  COUNT(*) AS total_blocked
FROM Tranzaksiyalar t
LEFT JOIN (
    SELECT card_id, MAX(transaction_amount) AS max_legit_amount
    FROM Tranzaksiyalar
    WHERE is_fraud = 0 
      AND transaction_datetime >= SYSDATE - 30
    GROUP BY card_id
) max_tx 
  ON t.card_id = max_tx.card_id
WHERE t.transaction_amount > 10 * COALESCE(max_tx.max_legit_amount, 0)
  AND (UPPER(t.transaction_location) IN ('USA','CHINA','TURKEY')
    OR UPPER(t.transaction_location) NOT IN ('BAKI','SUMQAYIT','GƏNCƏ','ŞƏKİ','LƏNKƏRAN',
                                             'MİNGƏÇEVİR','NAXÇIVAN','QUBA','ŞİRVAN','ONLINE'));
