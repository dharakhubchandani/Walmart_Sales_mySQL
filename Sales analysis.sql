#Creating schema 
CREATE SCHEMA IF NOT EXISTS walmart;
USE walmart;

#Creating table
CREATE TABLE salesdata 
(
Store INT,
Date DATE,
Weekly_sales DECIMAL(12,2),
Holiday_flag TINYINT,
Temperature Decimal(5,2),
Fuel_Price Decimal (6,3),
CPI Decimal (12,7),
Unemployment Decimal (5,3)
)

-- Importing the csv file using 'Table data import wizard'

-- Step 1: Add a new column for the year
ALTER TABLE walmart
ADD COLUMN sales_year INT;

-- Step 2: Update the new column with the year extracted from the "Date" column
UPDATE walmart
SET sales_year = 
    CASE
        WHEN CHAR_LENGTH(Date) = 10 AND Date LIKE '__-__-____' THEN YEAR(STR_TO_DATE(Date, '%d-%m-%Y'))
        WHEN CHAR_LENGTH(Date) = 10 AND Date LIKE '__/__/____' THEN YEAR(STR_TO_DATE(Date, '%d/%m/%Y'))
        ELSE YEAR(STR_TO_DATE(Date, '%Y-%m-%d'))
    END;

-- Question 1: Which year had the highest sales?

SELECT 
DISTINCT sales_year,
Round(SUM(Weekly_Sales),2) as Total_Sales
from walmart
GROUP BY sales_year
ORDER BY Total_Sales desc;

-- Question 2: How was the temperature during the year of highest sales?

SELECT 
sales_year,
MIN(Temperature) as minimum_temp,
MAX(Temperature) as maximum_temp,
(MIN(Temperature) + MAX(Temperature))/2 as average_temp
FROM walmart 
WHERE sales_year = 2011
;

-- Question 3: Does weather have any impact on Sales?

SELECT 
sales_year,
Round(SUM(Weekly_Sales),2) as Total_Sales,
ROUND(MIN(Temperature),2) as minimum_temp,
ROUND(MAX(Temperature),2) as maximum_temp,
ROUND((MIN(Temperature) + MAX(Temperature))/2,2) as average_temp
FROM walmart
GROUP BY sales_year
ORDER BY Total_Sales desc;

-- Question 4: Does Unemployment have any impact on Sales?

SELECT 
sales_year,
Round(SUM(Weekly_Sales),2) as Total_Sales,
ROUND(MIN(Unemployment),2) as minimum_unemp,
ROUND(MAX(Unemployment),2) as maximum_unemp,
ROUND((MIN(Unemployment) + MAX(Temperature))/2,2) as average_unemp
FROM walmart
GROUP BY sales_year
ORDER BY Total_Sales desc;

-- Question 5: Do the sales always rise near the holiday season for all the years? 

SELECT
    sales_year,
    SUM(weekly_sales) as total_sales_holiday_season
FROM
    walmart
WHERE
    holiday_flag = 1
GROUP BY
    sales_year;

-- Question 6: Are there any patterns in sales and months?
-- Step 1: Add a new column for the month
ALTER TABLE walmart
ADD COLUMN sales_month INT;

-- Step 2: Update the new column with the month extracted from the "Date" column
UPDATE walmart
SET sales_month = 
    CASE
        WHEN CHAR_LENGTH(Date) = 10 AND Date LIKE '__-__-____' THEN month(STR_TO_DATE(Date, '%d-%m-%Y'))
        WHEN CHAR_LENGTH(Date) = 10 AND Date LIKE '__/__/____' THEN MONTH(STR_TO_DATE(Date, '%d/%m/%Y'))
        ELSE MONTH(STR_TO_DATE(Date, '%Y-%m-%d'))
    END;

-- Step 3: Find the total sales month-wise
SELECT 
    sales_month,
    ROUND(SUM(weekly_sales),2) AS total_sales,
    CONCAT(ROUND((SUM(weekly_sales) / (SELECT SUM(weekly_sales) FROM walmart)) * 100, 2), '%') AS percentage_of_total_sales
FROM 
    walmart
GROUP BY 
    sales_month
ORDER BY 
    sales_month;

-- Question 7: Which are the top 3 high performing stores? 

SELECT 
DISTINCT Store,
ROUND(SUM(Weekly_Sales),2) as Total_sales
FROM walmart
GROUP BY Store
ORDER BY Total_sales desc
LIMIT 3;

-- Question 8: Is there a difference in the customer behavior during weekdays and weekends?

UPDATE walmart
SET Date = DATE_FORMAT(STR_TO_DATE(Date, '%d-%m-%Y'), '%Y-%m-%d');

Select Date
From walmart;

-- Add the new column 'DayOfWeek' to your table
ALTER TABLE walmart
ADD COLUMN DayOfWeek VARCHAR(10);

-- Update the 'DayOfWeek' column with the day names
UPDATE walmart
SET DayOfWeek = DATE_FORMAT(Date, '%W');

SELECT *
From walmart;

-- All the dates are for Friday so no further analysis is possible