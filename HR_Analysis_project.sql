create database IBM;
use IBM;

select * from hr_employee_attrition;

## 1. Total employees

SELECT COUNT(*) AS TotalEmployees
FROM hr_employee_attrition;
-- > 1470

## 2. Employees by department

SELECT Department, COUNT(Department) as Employees
from hr_employee_attrition
GROUP BY Department
order by Employees desc;


## 3. 3. Attrition by department

SELECT Department,
       COUNT(*) AS AttritionCount
FROM hr_employee_attrition
WHERE Attrition = 'Yes'
GROUP BY Department
ORDER BY AttritionCount DESC;


## 4. Average monthly income by department

SELECT Department,
       ROUND(AVG(MonthlyIncome),2) AS AvgSalary
FROM hr_employee_attrition
GROUP BY Department
ORDER BY AvgSalary DESC;


## 5. Overtime vs attrition

SELECT OverTime,
       Attrition,
       COUNT(*) AS TotalEmployees
FROM hr_employee_attrition
GROUP BY OverTime, Attrition
ORDER BY OverTime;


## Q6. Employees by Job Role

SELECT JobRole,
       COUNT(*) AS TotalEmployees
FROM hr_employee_attrition
GROUP BY JobRole
ORDER BY TotalEmployees DESC;


## Q7. Gender Distribution

SELECT Gender,
       COUNT(*) AS TotalEmployees
FROM hr_employee_attrition
GROUP BY Gender;

## Q8. Average Age by Department

select Department ,round(avg(Age),1) as AvgAge
FROM hr_employee_attrition
group by Department
order by AvgAge desc;


## Q9. Top 10 Highest Paid Employees

SELECT EmployeeNumber,
       JobRole,
       Department,
       MonthlyIncome
FROM hr_employee_attrition
ORDER BY MonthlyIncome DESC
LIMIT 10;


SELECT COUNT(DISTINCT EmployeeNumber) AS UniqueEMp
FROM hr_employee_attrition;


## Q10. Attrition Rate (%)

SELECT
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS EmployeesLeft,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS AttritionRate
FROM hr_employee_attrition;


## Q11. Attrition Rate by Department

SELECT Department,
       COUNT(*) AS TotalEmployees,
       SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS LeftEmployees,
       ROUND(
           SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
           2
       ) AS AttritionRate
FROM hr_employee_attrition
GROUP BY Department
ORDER BY AttritionRate DESC;

## Q12. Average Job Satisfaction by Department

SELECT Department,
       ROUND(AVG(JobSatisfaction),2) AS AvgJobSatisfaction
FROM hr_employee_attrition
GROUP BY Department
ORDER BY AvgJobSatisfaction DESC;

## Q13. Employees with More Than 10 Years at Company

SELECT EmployeeNumber,
       JobRole,
       Department,
       YearsAtCompany
FROM hr_employee_attrition
WHERE YearsAtCompany > 10
ORDER BY YearsAtCompany DESC;

## Q14. Highest Paid Employee in Each Department

SELECT Department,
       JobRole,
       MonthlyIncome
FROM hr_employee_attrition h1
WHERE MonthlyIncome = (
    SELECT MAX(MonthlyIncome)
    FROM hr_employee_attrition h2
    WHERE h1.Department = h2.Department
);


## Q15. Monthly Income Category (CASE WHEN)

SELECT EmployeeNumber,
       MonthlyIncome,
       CASE
           WHEN MonthlyIncome >= 15000 THEN 'High'
           WHEN MonthlyIncome >= 7000 THEN 'Medium'
           ELSE 'Low'
       END AS SalaryCategory
FROM hr_employee_attrition;

## Q16. Rank employees by salary within each department

SELECT EmployeeNumber,
       Department,
       JobRole,
       MonthlyIncome,
       DENSE_RANK() OVER (
           PARTITION BY Department
           ORDER BY MonthlyIncome DESC
       ) AS SalaryRank
FROM hr_employee_attrition;

## Q17. Top 3 highest paid employees in each department

SELECT *
FROM (
    SELECT EmployeeNumber,
           Department,
           JobRole,
           MonthlyIncome,
           DENSE_RANK() OVER (
               PARTITION BY Department
               ORDER BY MonthlyIncome DESC
           ) AS rnk
    FROM hr_employee_attrition
) t
WHERE rnk <= 3;

## Q18. Average salary by Job Role

SELECT JobRole,
       ROUND(AVG(MonthlyIncome),2) AS AvgSalary
FROM hr_employee_attrition
GROUP BY JobRole
ORDER BY AvgSalary DESC;

## Q19. Find employees earning above their department average

SELECT EmployeeNumber,
       Department,
       JobRole,
       MonthlyIncome
FROM hr_employee_attrition h1
WHERE MonthlyIncome >
(
    SELECT AVG(MonthlyIncome)
    FROM hr_employee_attrition h2
    WHERE h1.Department = h2.Department
)
ORDER BY Department, MonthlyIncome DESC;



CREATE VIEW vw_hr_summary AS
SELECT Department,
       COUNT(*) AS TotalEmployees,
       SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS LeftEmployees,
       ROUND(AVG(MonthlyIncome),2) AS AvgSalary,
       ROUND(AVG(JobSatisfaction),2) AS AvgSatisfaction,
       ROUND(
            SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),
            2
       ) AS AttritionRate
FROM hr_employee_attrition
GROUP BY Department;



## creating column 

## 1. Attrition Rate (Best for KPI)

USE IBM;

SET SQL_SAFE_UPDATES = 0;

-- =====================================================
-- 1. ATTRITION FLAG (0 = No, 1 = Yes)
-- =====================================================

ALTER TABLE hr_employee_attrition
ADD AttritionFlag INT;

UPDATE hr_employee_attrition
SET AttritionFlag = CASE
    WHEN Attrition = 'Yes' THEN 1
    ELSE 0
END;

-- =====================================================
-- 2. SALARY CATEGORY
-- =====================================================

ALTER TABLE hr_employee_attrition
ADD SalaryCategory VARCHAR(20);

UPDATE hr_employee_attrition
SET SalaryCategory = CASE
    WHEN MonthlyIncome >= 15000 THEN 'High'
    WHEN MonthlyIncome >= 7000 THEN 'Medium'
    ELSE 'Low'
END;

-- =====================================================
-- 3. AGE GROUP
-- =====================================================

ALTER TABLE hr_employee_attrition
ADD AgeGroup VARCHAR(20);

UPDATE hr_employee_attrition
SET AgeGroup = CASE
    WHEN Age < 30 THEN '18-29'
    WHEN Age BETWEEN 30 AND 39 THEN '30-39'
    WHEN Age BETWEEN 40 AND 49 THEN '40-49'
    ELSE '50+'
END;

SET SQL_SAFE_UPDATES = 1;


SELECT EmployeeNumber,
       AgeGroup,
       SalaryCategory,
       AttritionFlag
FROM hr_employee_attrition
LIMIT 10;