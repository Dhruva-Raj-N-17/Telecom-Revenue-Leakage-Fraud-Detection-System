-- STEP 1 — CREATE A FRAUD ANALYSIS VIEW ---------------------------

CREATE VIEW fraud_analysis_view AS
SELECT 
    caller_number,
    call_type,
    call_duration,
    call_cost,
    call_time,

    CASE
        WHEN call_type = 'International'
             AND call_cost > 100
             AND HOUR(call_time) BETWEEN 0 AND 4
        THEN 'HIGH RISK FRAUD'

        WHEN call_cost > 100
        THEN 'Suspicious'

        ELSE 'Normal'
    END AS fraud_status

FROM call_records;

-- verify because 
SELECT * FROM fraud_analysis_view;

-- STEP 2 — USE CTE (Common Table Expression)
-- CTEs make complex queries cleaner.
WITH high_cost_calls AS (
    SELECT 
        caller_number,
        call_cost,     -- (Creates a temporary result set for:high-cost suspicious calls)
        call_type
    FROM call_records
    WHERE call_cost > 100
)

SELECT * FROM high_cost_calls;

-- STEP 3 — WINDOW FUNCTION (RANK)---------------------------------
SELECT 
    caller_number,
    SUM(call_cost) AS total_spending,

    RANK() OVER (
        ORDER BY SUM(call_cost) DESC
    ) AS spending_rank

FROM call_records                   -- (it Ranks customers based on:telecom spending)
GROUP BY caller_number;

-- STEP 4 — ROW_NUMBER()-----------------------------------------------
SELECT 
    caller_number,
    call_type,
    call_cost,    -- (Assigns unique ranking to each telecom call.
				  -- Used heavily in analytics companies.
    ROW_NUMBER() OVER (
        ORDER BY call_cost DESC
    ) AS row_num

FROM call_records;

-- STEP 5 — CREATE STORED PROCEDURE=====================================
DELIMITER //

CREATE PROCEDURE GetHighRiskFrauds()
BEGIN

    SELECT 
        caller_number,
        call_type,
        call_cost,
        call_time

    FROM call_records

    WHERE call_type = 'International'
          AND call_cost > 100
          AND HOUR(call_time) BETWEEN 0 AND 4;

END //

DELIMITER ;

-- execute stored procedure 
CALL GetHighRiskFrauds();

-- STEP 6 — CREATE REVENUE LEAKAGE REPORT=======================================

SELECT 
    c.customer_name,
    c.phone_number,

    IFNULL(SUM(cr.call_cost),0) AS total_usage,

    IFNULL(SUM(r.recharge_amount),0) AS total_recharge,

    IFNULL(SUM(cr.call_cost),0) 
      - 
    IFNULL(SUM(r.recharge_amount),0)

    AS revenue_difference

FROM customers c
                             -- (Detects:customers using more services but paying less recharge
LEFT JOIN call_records cr    -- Revenue Leakage)
ON c.phone_number = cr.caller_number

LEFT JOIN recharge_history r
ON c.customer_id = r.customer_id

GROUP BY c.customer_name, c.phone_number;

-- STEP 7 — PEAK FRAUD HOURS ANALYSIS
SELECT 
    HOUR(call_time) AS fraud_hour,
    COUNT(*) AS total_fraud_calls

FROM call_records                  -- finds when fraud activity is highest 

WHERE call_type = 'International'

GROUP BY HOUR(call_time)

ORDER BY total_fraud_calls DESC;

