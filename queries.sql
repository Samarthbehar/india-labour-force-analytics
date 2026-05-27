---Q1: Unemployment Rate by State
run_query("""
    SELECT 
        state_name,
        COUNT(*) AS total_people,
        SUM(CASE WHEN lf_status = 'Employed' THEN 1 ELSE 0 END) AS employed,
        SUM(CASE WHEN lf_status = 'Unemployed' THEN 1 ELSE 0 END) AS unemployed,
        ROUND(
            SUM(CASE WHEN lf_status = 'Unemployed' THEN 1 ELSE 0 END) * 100.0 /
            SUM(CASE WHEN lf_status IN ('Employed','Unemployed') THEN 1 ELSE 0 END), 1
        ) AS unemployment_rate_pct
    FROM plfs
    WHERE state_name IS NOT NULL
    GROUP BY state_name
    ORDER BY unemployment_rate_pct DESC
""", "Q1 — Unemployment Rate by State (Highest First)")

---Q2:Unemployment by Education Level
run_query("""
    SELECT 
        education,
        COUNT(*) AS total_in_labour_force,
        SUM(CASE WHEN lf_status = 'Unemployed' THEN 1 ELSE 0 END) AS unemployed,
        ROUND(
            SUM(CASE WHEN lf_status = 'Unemployed' THEN 1 ELSE 0 END) * 100.0 /
            COUNT(*), 1
        ) AS unemployment_rate_pct
    FROM plfs
    WHERE lf_status IN ('Employed', 'Unemployed')
    AND education IS NOT NULL
    GROUP BY education
    ORDER BY unemployment_rate_pct DESC
""", "Q2 — Unemployment Rate by Education Level")

---Q3: LFPR by Gender and Area
run_query("""
    SELECT
        gender,
        area_type,
        COUNT(*) AS total,
        ROUND(
            SUM(CASE WHEN lf_status IN ('Employed','Unemployed') THEN 1 ELSE 0 END) * 100.0 /
            COUNT(*), 1
        ) AS lfpr_pct,
        ROUND(
            SUM(CASE WHEN lf_status = 'Unemployed' THEN 1 ELSE 0 END) * 100.0 /
            SUM(CASE WHEN lf_status IN ('Employed','Unemployed') THEN 1 ELSE 0 END), 1
        ) AS unemployment_rate_pct
    FROM plfs
    WHERE gender IN ('Male','Female')
    AND area_type IS NOT NULL
    GROUP BY gender, area_type
    ORDER BY gender, area_type
""", "Q3 — LFPR and Unemployment by Gender and Area")

-- Q4: Unemployment by Age Group
run_query("""
    SELECT
        CASE 
            WHEN AGE BETWEEN 15 AND 24 THEN '15-24 (Youth)'
            WHEN AGE BETWEEN 25 AND 34 THEN '25-34 (Young Adult)'
            WHEN AGE BETWEEN 35 AND 44 THEN '35-44 (Mid Career)'
            WHEN AGE BETWEEN 45 AND 60 THEN '45-60 (Experienced)'
        END AS age_group,
        COUNT(*) AS total,
        ROUND(
            SUM(CASE WHEN lf_status = 'Unemployed' THEN 1 ELSE 0 END) * 100.0 /
            SUM(CASE WHEN lf_status IN ('Employed','Unemployed') THEN 1 ELSE 0 END), 1
        ) AS unemployment_rate_pct,
        ROUND(
            SUM(CASE WHEN lf_status IN ('Employed','Unemployed') THEN 1 ELSE 0 END) * 100.0 /
            COUNT(*), 1
        ) AS lfpr_pct
    FROM plfs
    WHERE AGE BETWEEN 15 AND 60
    GROUP BY age_group
    ORDER BY unemployment_rate_pct DESC
""", "Q4 — Unemployment by Age Group")

-- Q5: Type of Employment
run_query("""
    SELECT
        activity_status,
        COUNT(*) AS count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
    FROM plfs
    WHERE lf_status = 'Employed'
    AND activity_status IS NOT NULL
    GROUP BY activity_status
    ORDER BY count DESC
""", "Q5 — How Are People Employed? (Type of Employment)")

-- Q6: Bottom 5 States for Female LFPR
run_query("""
    SELECT
        state_name,
        gender,
        ROUND(
            SUM(CASE WHEN lf_status IN ('Employed','Unemployed') THEN 1 ELSE 0 END) * 100.0 /
            COUNT(*), 1
        ) AS lfpr_pct
    FROM plfs
    WHERE gender IN ('Male','Female')
    AND state_name IS NOT NULL
    GROUP BY state_name, gender
    HAVING gender = 'Female'
    ORDER BY lfpr_pct ASC
    LIMIT 5
""", "Q6 — Bottom 5 States for Female LFPR (Worst Gender Gap)")

-- Q7: Earnings by Education and Gender
run_query("""
    SELECT
        education,
        gender,
        ROUND(AVG(CASE WHEN total_earnings > 0 THEN total_earnings END), 0) AS avg_monthly_earnings,
        COUNT(CASE WHEN total_earnings > 0 THEN 1 END) AS earners
    FROM plfs
    WHERE lf_status = 'Employed'
    AND education IS NOT NULL
    AND gender IN ('Male','Female')
    GROUP BY education, gender
    ORDER BY 
        CASE education
            WHEN 'Postgraduate & Above' THEN 1
            WHEN 'Graduate' THEN 2
            WHEN 'Diploma' THEN 3
            WHEN 'Higher Secondary' THEN 4
            WHEN 'Secondary' THEN 5
            WHEN 'Middle' THEN 6
            WHEN 'Primary' THEN 7
            WHEN 'Below Primary' THEN 8
            WHEN 'Literate (No Schooling)' THEN 9
            WHEN 'Not Literate' THEN 10
        END,
        CASE WHEN gender = 'Male' THEN 1 ELSE 2 END
""", "Q7 — Average Monthly Earnings by Education and Gender")

-- Q8: Educated Unemployment Rural vs Urban
run_query("""
    SELECT
        area_type,
        education,
        COUNT(*) AS total,
        ROUND(
            SUM(CASE WHEN lf_status = 'Unemployed' THEN 1 ELSE 0 END) * 100.0 /
            SUM(CASE WHEN lf_status IN ('Employed','Unemployed') THEN 1 ELSE 0 END), 1
        ) AS unemployment_rate_pct
    FROM plfs
    WHERE education IN ('Graduate','Postgraduate & Above','Higher Secondary')
    AND area_type IS NOT NULL
    GROUP BY area_type, education
    ORDER BY unemployment_rate_pct DESC
""", "Q8 — Educated Unemployment: Rural vs Urban Breakdown")