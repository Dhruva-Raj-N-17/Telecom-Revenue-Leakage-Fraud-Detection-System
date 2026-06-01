CREATE DATABASE telecom_fraud_detection;

USE telecom_fraud_detection;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    phone_number VARCHAR(15) UNIQUE,
    city VARCHAR(50),
    state VARCHAR(50),
    sim_type VARCHAR(20),
    activation_date DATE
);
CREATE TABLE call_records (
    call_id INT PRIMARY KEY AUTO_INCREMENT,
    caller_number VARCHAR(15),
    receiver_number VARCHAR(15),
    call_duration INT,
    call_type VARCHAR(20),
    call_time DATETIME,
    call_cost DECIMAL(10,2)
);

CREATE TABLE recharge_history (
    recharge_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    recharge_amount DECIMAL(10,2),
    recharge_date DATE,
    payment_method VARCHAR(50)
);

CREATE TABLE fraud_alerts (
    fraud_id INT PRIMARY KEY AUTO_INCREMENT,
    phone_number VARCHAR(15),
    fraud_type VARCHAR(100),
    fraud_score INT,
    detected_on DATETIME
);

SHOW TABLES;