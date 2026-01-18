-- ============================================================================
-- DIABETES RISK ANALYSIS - SQL QUERIES
-- Dataset: CDC BRFSS 2015 (253,680 records)
-- Author: [Your Name]
-- Date: January 2026
-- ============================================================================

-- ============================================================================
-- BUSINESS QUESTION 1: Overall Diabetes Prevalence
-- ============================================================================

-- Q1: What percentage of the population has diabetes?
SELECT 
    Diabetes_binary,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM health_indicators), 2) as percentage
FROM health_indicators
GROUP BY Diabetes_binary;


-- ============================================================================
-- BUSINESS QUESTION 2: Demographic Analysis
-- ============================================================================

-- Q2a: Diabetes rate by Age Group
SELECT 
    Age,
    COUNT(*) as total_people,
    SUM(Diabetes_binary) as diabetes_cases,
    ROUND(SUM(Diabetes_binary) * 100.0 / COUNT(*), 2) as diabetes_rate
FROM health_indicators
GROUP BY Age
ORDER BY Age;

-- Q2b: Diabetes rate by Sex
SELECT 
    CASE 
        WHEN Sex = 0 THEN 'Female'
        WHEN Sex = 1 THEN 'Male'
    END as gender,
    COUNT(*) as total_people,
    SUM(Diabetes_binary) as diabetes_cases,
    ROUND(SUM(Diabetes_binary) * 100.0 / COUNT(*), 2) as diabetes_rate
FROM health_indicators
GROUP BY Sex;

-- Q2c: Diabetes rate by Income Level
SELECT 
    Income,
    COUNT(*) as total_people,
    SUM(Diabetes_binary) as diabetes_cases,
    ROUND(SUM(Diabetes_binary) * 100.0 / COUNT(*), 2) as diabetes_rate
FROM health_indicators
GROUP BY Income
ORDER BY Income;


-- ============================================================================
-- BUSINESS QUESTION 3: Risk Factor Analysis
-- ============================================================================

-- Q3: Compare health metrics between diabetic and non-diabetic groups
SELECT 
    Diabetes_binary,
    ROUND(AVG(BMI), 2) as avg_bmi,
    ROUND(AVG(CAST(HighBP as FLOAT)) * 100, 2) as high_bp_percentage,
    ROUND(AVG(CAST(HighChol as FLOAT)) * 100, 2) as high_chol_percentage,
    ROUND(AVG(GenHlth), 2) as avg_general_health,
    ROUND(AVG(CAST(PhysActivity as FLOAT)) * 100, 2) as physically_active_percentage
FROM health_indicators
GROUP BY Diabetes_binary;


-- ============================================================================
-- BUSINESS QUESTION 4: Lifestyle Factor Analysis
-- ============================================================================

-- Q4: Impact of lifestyle factors (Physical Activity + Smoking)
SELECT 
    CASE WHEN PhysActivity = 1 THEN 'Active' ELSE 'Not Active' END as activity_level,
    CASE WHEN Smoker = 1 THEN 'Smoker' ELSE 'Non-Smoker' END as smoking_status,
    COUNT(*) as total_people,
    SUM(Diabetes_binary) as diabetes_cases,
    ROUND(SUM(Diabetes_binary) * 100.0 / COUNT(*), 2) as diabetes_rate
FROM health_indicators
GROUP BY PhysActivity, Smoker
ORDER BY diabetes_rate DESC;


-- ============================================================================
-- BUSINESS QUESTION 5: High-Risk Profile Identification
-- ============================================================================

-- Q5: Identify highest-risk combinations of health factors
SELECT 
    HighBP,
    HighChol,
    CASE 
        WHEN BMI < 25 THEN 'Normal'
        WHEN BMI < 30 THEN 'Overweight'
        ELSE 'Obese'
    END as bmi_category,
    COUNT(*) as total_people,
    SUM(Diabetes_binary) as diabetes_cases,
    ROUND(SUM(Diabetes_binary) * 100.0 / COUNT(*), 2) as diabetes_rate
FROM health_indicators
GROUP BY HighBP, HighChol, bmi_category
HAVING COUNT(*) > 1000  -- Filter out small groups
ORDER BY diabetes_rate DESC
LIMIT 10;


-- ============================================================================
-- VIEW CREATION: Clean data for Tableau visualization
-- ============================================================================

DROP VIEW IF EXISTS diabetes_analysis_view;

CREATE VIEW diabetes_analysis_view AS
SELECT 
    Diabetes_binary,
    CASE 
        WHEN Age = 1 THEN '18-24'
        WHEN Age = 2 THEN '25-29'
        WHEN Age = 3 THEN '30-34'
        WHEN Age = 4 THEN '35-39'
        WHEN Age = 5 THEN '40-44'
        WHEN Age = 6 THEN '45-49'
        WHEN Age = 7 THEN '50-54'
        WHEN Age = 8 THEN '55-59'
        WHEN Age = 9 THEN '60-64'
        WHEN Age = 10 THEN '65-69'
        WHEN Age = 11 THEN '70-74'
        WHEN Age = 12 THEN '75-79'
        WHEN Age = 13 THEN '80+'
    END as age_group,
    CASE WHEN Sex = 0 THEN 'Female' ELSE 'Male' END as gender,
    Income as income_level,
    BMI,
    HighBP,
    HighChol,
    Smoker,
    PhysActivity,
    GenHlth,
    CASE 
        WHEN BMI < 25 THEN 'Normal Weight'
        WHEN BMI < 30 THEN 'Overweight'
        ELSE 'Obese'
    END as bmi_category
FROM health_indicators;
