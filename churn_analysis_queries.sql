SHOW DATABASES;

USE churn_project;

-- View dataset
SELECT * FROM customers;

-- Verifying Row Count
SELECT COUNT(*) FROM customers;

-- Overall Churn Rate
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN `Churn Label` = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN `Churn Label` = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customers;

-- Churn by Contract Type
SELECT 
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN `Churn Label` = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN `Churn Label` = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM customers
GROUP BY Contract
ORDER BY churn_rate_percentage DESC;

-- Churn by Tenure
SELECT 
    CASE 
        WHEN `Tenure in Months` <= 12 THEN '0-12 Months'
        WHEN `Tenure in Months` <= 24 THEN '13-24 Months'
        ELSE '24+ Months'
    END AS tenure_group,
    
    COUNT(*) AS total_customers,
    
    SUM(`Churn Label` = 'Yes') AS churned_customers,
    
    ROUND(
        SUM(`Churn Label` = 'Yes') * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage

FROM customers
GROUP BY tenure_group
ORDER BY churn_rate_percentage DESC;

-- Churn by Monthly charge bucket
SELECT 
    CASE 
        WHEN `Monthly Charge` < 40 THEN 'Low (0-40)'
        WHEN `Monthly Charge` < 80 THEN 'Medium (40-80)'
        ELSE 'High (80+)'
    END AS charge_group,

    COUNT(*) AS total_customers,

    SUM(`Churn Label` = 'Yes') AS churned_customers,

    ROUND(
        SUM(`Churn Label` = 'Yes') * 100.0 / COUNT(*),
        2
    ) AS churn_rate_percentage

FROM customers
GROUP BY charge_group
ORDER BY churn_rate_percentage DESC;

-- Risk Segmentation
SELECT 
    `Customer ID`,
    `Contract`,
    `Tenure in Months`,
    `Monthly Charge`,
    `Churn Label`,
    
    CASE
        WHEN `Contract` = 'Month-to-Month'
             AND `Tenure in Months` <= 12
             AND `Monthly Charge` >= 80
        THEN 'High Risk'
        
        WHEN `Contract` = 'Month-to-Month'
             AND `Tenure in Months` <= 24
        THEN 'Medium Risk'
        
        ELSE 'Low Risk'
    END AS churn_risk_segment

FROM customers;

SELECT 
    CASE
        WHEN `Contract` = 'Month-to-Month'
             AND `Tenure in Months` <= 12
             AND `Monthly Charge` >= 80
        THEN 'High Risk'
        
        WHEN `Contract` = 'Month-to-Month'
             AND `Tenure in Months` <= 24
        THEN 'Medium Risk'
        
        ELSE 'Low Risk'
    END AS churn_risk_segment,
    
    COUNT(*) AS total_customers

FROM customers
GROUP BY churn_risk_segment;

-- Risk segmentation validation
WITH risk_segmentation AS (
    SELECT 
        `Churn Label`,
        CASE
            WHEN `Contract` = 'Month-to-Month'
                 AND `Tenure in Months` <= 12
                 AND `Monthly Charge` >= 80
            THEN 'High Risk'
            
            WHEN `Contract` = 'Month-to-Month'
                 AND `Tenure in Months` <= 24
            THEN 'Medium Risk'
            
            ELSE 'Low Risk'
        END AS churn_risk_segment
    FROM customers
)

SELECT 
    churn_risk_segment,
    COUNT(*) AS total_customers,
    SUM(`Churn Label` = 'Yes') AS churned_customers,
    ROUND(SUM(`Churn Label` = 'Yes') * 100.0 / COUNT(*), 2) AS churn_rate
FROM risk_segmentation
GROUP BY churn_risk_segment
ORDER BY churn_rate DESC;

-- Structured Analysis View for Dashboard
CREATE OR REPLACE VIEW churn_analysis_final AS
SELECT 
    `Customer ID`,
    `Tenure in Months`,
    `Contract`,
    `Monthly Charge`,
    `Churn Label`,
    
    CASE 
        WHEN `Tenure in Months` <= 12 THEN '0-12 Months'
        WHEN `Tenure in Months` <= 24 THEN '13-24 Months'
        ELSE '24+ Months'
    END AS tenure_group,
    
    CASE 
        WHEN `Monthly Charge` < 40 THEN 'Low (0-40)'
        WHEN `Monthly Charge` < 80 THEN 'Medium (40-80)'
        ELSE 'High (80+)'
    END AS charge_group,
    
    CASE
        WHEN `Contract` = 'Month-to-Month'
             AND `Tenure in Months` <= 12
             AND `Monthly Charge` >= 80
        THEN 'High Risk'
        
        WHEN `Contract` = 'Month-to-Month'
             AND `Tenure in Months` <= 24
        THEN 'Medium Risk'
        
        ELSE 'Low Risk'
    END AS churn_risk_segment

FROM customers;

