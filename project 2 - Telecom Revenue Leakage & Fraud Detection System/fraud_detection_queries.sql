INSERT INTO customers
(customer_name, phone_number, city, state, sim_type, activation_date)
VALUES
('Rahul Sharma', '9876543210', 'Bangalore', 'Karnataka', 'Prepaid', '2023-01-15'),
('Priya Verma', '9876543211', 'Mumbai', 'Maharashtra', 'Postpaid', '2022-11-10'),
('Arjun Reddy', '9876543212', 'Hyderabad', 'Telangana', 'Prepaid', '2023-03-20'),
('Sneha Patil', '9876543213', 'Pune', 'Maharashtra', 'Prepaid', '2021-12-05'),
('Vikram Singh', '9876543214', 'Delhi', 'Delhi', 'Postpaid', '2020-07-18');

SELECT * FROM customers;

INSERT INTO call_records
(caller_number, receiver_number, call_duration, call_type, call_time, call_cost)
VALUES
('9876543210', '9123456780', 120, 'Local', '2026-05-01 10:15:00', 2.50),

('9876543211', '9198765432', 600, 'International', '2026-05-02 01:20:00', 150.00),

('9876543212', '9012345678', 45, 'Local', '2026-05-03 14:10:00', 1.20),

('9876543213', '9345678901', 900, 'International', '2026-05-03 02:45:00', 210.00),

('9876543214', '9988776655', 30, 'STD', '2026-05-04 18:25:00', 5.00);

SELECT * FROM call_records;
INSERT INTO recharge_history
(customer_id, recharge_amount, recharge_date, payment_method)
VALUES
(1, 299.00, '2026-05-01', 'UPI'),
(2, 599.00, '2026-05-02', 'Credit Card'),
(3, 199.00, '2026-05-03', 'Debit Card'),
(4, 399.00, '2026-05-03', 'UPI'),
(5, 699.00, '2026-05-04', 'Net Banking');

INSERT INTO fraud_alerts
(phone_number, fraud_type, fraud_score, detected_on)
VALUES
('9876543211', 'High International Usage', 85, '2026-05-02 01:30:00'),

('9876543213', 'Night-Time Fraud Activity', 92, '2026-05-03 03:00:00');

-- =========================================================================================
-- step 1-(VIEW ALL CALL DATA)------------------------------
SELECT * FROM call_records;
-- step 2 -(FIND HIGH-COST CALLS)---------------------------
SELECT 
    caller_number,
    receiver_number,
    call_type,       -- ( detects suspicious expensive calls )
    call_duration,    
    call_cost
FROM call_records
WHERE call_cost > 100;
-- step 3-(Detect international fraud calls)-------------------
SELECT 
    caller_number,
    receiver_number,      -- (finds :international activity,possible fraud usage,premium route abuse)
    call_duration,
    call_time
FROM call_records
WHERE call_type = 'International';

-- step 4 -(TIME FRAUD DETECTION)-----------------------------------
SELECT 
    caller_number,
    receiver_number,
    call_time,                   -- (this detects calls b/w 12 am - 4 am )
    call_cost
FROM call_records
WHERE HOUR(call_time) BETWEEN 0 AND 4;

-- step 5 -(FIND TOP SPENDING CUSTOMERS)--------------------------------
SELECT 
    caller_number,
    SUM(call_cost) AS total_call_cost
FROM call_records
GROUP BY caller_number
ORDER BY total_call_cost DESC;

-- step 6 -(REVENUE LEAKAGE ANALYSIS)------------------------------------
SELECT 
    c.customer_name,
    c.phone_number,
    SUM(cr.call_cost) AS total_call_cost,
    SUM(r.recharge_amount) AS total_recharge
FROM customers c
JOIN call_records cr                   -- Finds customers:spending heavily,but recharging less
ON c.phone_number = cr.caller_number  -- we will get to  know about  (Revenue Leakage)
JOIN recharge_history r
ON c.customer_id = r.customer_id
GROUP BY c.customer_name, c.phone_number;

--  STEP 7 — HIGH RISK FRAUD USERS---------------------
SELECT 
    phone_number,
    fraud_type,       -- (detects : high-risk telecom users)
    fraud_score
FROM fraud_alerts
WHERE fraud_score > 80;

-- STEP 8 — MOST IMPORTANT QUERY-----------------------------------------------
-- (Combined Fraud Detection Query)
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

-- Fraud Detection Engine

-- It uses:
-- CASE statements
-- business logic
-- fraud rules
-- telecom analytics

