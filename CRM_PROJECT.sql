create database CRM_Project;
use CRM_Project;
create table CustomerInfo(
CustomerId int,
Surname varchar(50),
Age int,
Gender varchar(50),
BankDOJ date,
EstimatedSalary decimal(10,2),
GeographyLocation varchar(50),
CreditScore int,
Tenure int,
Balance decimal(10,2),
NumOfProducts int,
CardCategory varchar(50),
ActiveCategory varchar(50),
ExitCategory varchar(50));

select * from CustomerInfo;

-- 1.What is the distribution of account balances across different regions?
select GeographyLocation, round(sum(Balance),2) as account_balance
from CustomerInfo
group by 1
order by Account_balance desc;

-- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
select Surname as Customers, sum(EstimatedSalary) as highest_Estimated_Salary
from CustomerInfo
where month(BankDOJ) in (10,11,12)
group by Customers
order by Highest_Estimated_Salary desc
limit 5;

-- 3.	Calculate the average number of products used by customers who have a credit card. (SQL)
select Surname as Customers, round(avg(NumOfProducts),2) as average_number_of_products
from CustomerInfo
where CardCategory="Credit card holder"
group by 1;

-- 4.	Determine the churn rate by gender for the most recent year in the dataset.
WITH CTE AS(
	SELECT Gender,COUNT(CustomerId) AS `Churn`
	FROM CustomerInfo
	WHERE ExitCategory="Exit" AND YEAR(BankDOJ)=(SELECT MAX(YEAR(BankDOJ))
	FROM CustomerInfo)
	GROUP BY 1
),totalCTE AS
(
	SELECT Gender,COUNT(*) AS `total`
	FROM CustomerInfo
    GROUP BY 1
)
SELECT a.Gender,ROUND(churn/total,2)*100 AS `churn rate`
FROM CTE a
JOIN totalCTE b
ON a.Gender=b.Gender
GROUP BY a.Gender;

-- 5.	Compare the average credit score of customers who have exited and those who remain.
select ExitCategory, avg(CreditScore) as average_credit_score
from CustomerInfo
group by 1;

-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts?
SELECT Gender,
ROUND(AVG(EstimatedSalary),2) AS Highest_Average_Estimated_Salary,
COUNT(distinct case when ActiveCategory="Active Member" then CustomerId else null end) AS Count_of_Active_Member
FROM CustomerInfo
GROUP BY Gender
ORDER BY Highest_Average_Estimated_Salary DESC 
LIMIT 1;

-- 7.	Segment the customers based on their credit score and identify the segment with the highest exit rate.
SELECT CASE WHEN CreditScore BETWEEN 350 AND 450 THEN '350-450'
WHEN CreditScore BETWEEN 450 AND 550 THEN '450-550'
WHEN CreditScore BETWEEN 550 AND 650 THEN '550-650'
WHEN CreditScore BETWEEN 650 AND 750 THEN '650-750'
ELSE '750-850' END AS CreditScoreRange,
COUNT(CustomerId) AS customers
FROM CustomerInfo
WHERE ExitCategory="Exit"
GROUP BY 1
ORDER BY customers DESC;

-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years.
SELECT GeographyLocation,COUNT(CustomerId) AS Active_Customers
FROM CustomerInfo
WHERE ActiveCategory="Active Member" AND tenure>5
GROUP BY GeographyLocation
ORDER BY Active_Customers DESC
LIMIT 1;

-- 9.	What is the impact of having a credit card on customer churn, based on the available data?

SELECT CardCategory,COUNT(CustomerId) AS Customer_Churn
FROM CustomerInfo
WHERE ExitCategory='Exit' AND CardCategory='Credit card holder'
GROUP BY 1;

-- 10.	For customers who have exited, what is the most common number of products they have used?

SELECT NumOfProducts,COUNT(CustomerId) AS customers
FROM CustomerInfo
WHERE ExitCategory='Exit'
GROUP BY 1
ORDER BY customers DESC 
LIMIT 1;

--  11.	Examine the trend of customer exits over time and identify any seasonal patterns (yearly or monthly).
--  Prepare the data through SQL and then visualize it.

SELECT YEAR(BankDOJ) AS Years,COUNT(CustomerId) AS CustomersCount
FROM CustomerInfo
WHERE ExitCategory='Exit'
GROUP BY 1
ORDER BY CustomersCount DESC;

-- 12.	Analyze the relationship between the number of products and the account balance for customers who have exited.

SELECT NumOfProducts,AVG(Balance) AS Account_Balance
FROM CustomerInfo
WHERE ExitCategory='Exit'
GROUP BY NumOfProducts
ORDER BY Account_Balance DESC;

-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id.
--  Also, rank the gender according to the average value. (SQL)

WITH CTE AS(
	SELECT Gender,GeographyLocation,ROUND(AVG(EstimatedSalary),2) AS average_value
	FROM CustomerInfo
	GROUP BY 1,2
)
SELECT DENSE_RANK() OVER(ORDER BY average_value DESC) AS Ranks ,Gender,GeographyLocation,average_value
FROM CTE;

-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

SELECT CASE WHEN Age BETWEEN 18 AND 30 THEN '18-30'
WHEN Age BETWEEN 30 AND 50 THEN '30-50' 
ELSE '50+' END AS AgeBracket,AVG(Tenure) AS Average_Tenure
FROM CustomerInfo
WHERE ExitCategory='Exit'
GROUP BY 1;


-- 19.	Rank each bucket of credit score as per the number of customers who have churned the bank.

WITH CTE AS(
	SELECT CASE WHEN CreditScore BETWEEN 350 AND 450 THEN '350-450'
	WHEN CreditScore BETWEEN 450 AND 550 THEN '450-550'
	WHEN CreditScore BETWEEN 550 AND 650 THEN '550-650'
	WHEN CreditScore BETWEEN 650 AND 750 THEN '650-750'
	ELSE '750-850' END AS CreditScoreRange,
	COUNT(CustomerId) AS No_of_Customers
	FROM CustomerInfo
	WHERE ExitCategory='Exit'
	GROUP BY 1
	ORDER BY No_of_Customers DESC
)
SELECT DENSE_RANK() OVER(ORDER BY No_of_Customers DESC) AS Ranks,
CreditScoreRange, No_of_Customers
FROM CTE;

-- 20.	According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser than average number of credit cards per bucket.
-- Calculate the number of customers with a credit card in each age bucket
SELECT 
    FLOOR(Age / 10) * 10 AS AgeBucket,
    COUNT(*) AS Num_Customers_With_Credit_Card
FROM CustomerInfo
WHERE CardCategory = 'Credit card holder'
GROUP BY FLOOR(Age / 10) * 10;

-- Calculate the average number of credit cards per age bucket
WITH Credit_Card_Counts AS (
    SELECT 
        FLOOR(Age / 10) * 10 AS Age_Bucket,
        COUNT(*) AS Num_Customers_With_Credit_Card
    FROM CustomerInfo
    WHERE CardCategory = 'Credit card holder'
    GROUP BY FLOOR(Age / 10) * 10
)
SELECT AVG(Num_Customers_With_Credit_Card) AS Avg_Credit_Cards_Per_Bucket
FROM Credit_Card_Counts;

-- Retrieve age buckets with fewer than the average number of credit cards per bucket
WITH Credit_Card_Counts AS (
    SELECT 
        FLOOR(Age / 10) * 10 AS Age_Bucket,
        COUNT(*) AS Num_Customers_With_Credit_Card
    FROM CustomerInfo
    WHERE CardCategory = 'Credit card holder'
    GROUP BY FLOOR(Age / 10) * 10
), Avg_Credit_Cards AS (
    SELECT AVG(Num_Customers_With_Credit_Card) AS Avg_Credit_Cards_Per_Bucket
    FROM Credit_Card_Counts
)
SELECT Age_Bucket
FROM Credit_Card_Counts
CROSS JOIN Avg_Credit_Cards
WHERE Num_Customers_With_Credit_Card < Avg_Credit_Cards_Per_Bucket;

-- 21.	Rank the Locations as per the number of people who have churned the bank and the average balance of the learners.
WITH CTE AS(
	SELECT GeographyLocation,COUNT(CustomerId) AS number_of_people,ROUND(AVG(Balance),2) AS average_balance
	FROM customerInfo
	WHERE ExitCategory='Exit'
	GROUP BY GeographyLocation
)
SELECT DENSE_RANK() OVER(ORDER BY number_of_people DESC,average_balance DESC) AS Ranks,
GeographyLocation,number_of_people,average_balance
FROM CTE;

-- 22.	As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.
SELECT 
CustomerID,Surname, CONCAT(CustomerID, '_', Surname) AS CustomerID_Surname
FROM 
CustomerInfo;

-- 25. Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
SELECT 
CustomerId,
Surname,
ActiveCategory
FROM CustomerInfo
WHERE Surname LIKE '%on';

-- subjective Questions:
-- 9. Utilize SQL queries to segment customers based on demographics and account details.
select GeographyLocation, sum(Balance) as account_balance
from CustomerInfo
group by 1
order by 2 desc;



    
    
    




