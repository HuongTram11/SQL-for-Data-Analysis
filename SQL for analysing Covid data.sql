CREATE DATABASE COVID

USE COVID
GO

-- Before conducting data analysis, I usually check missing value or null value to make sure my data is full and avoid errors during analysis. Let's do it :))
--CHECK NULL data
SELECT * FROM dbo.Data
WHERE Province IS NULL
OR Country IS NULL
OR Latitude IS NULL
OR Longitude IS NULL
OR Date IS NULL
OR Confirmed IS NULL
OR Deaths IS NULL
OR Recovered IS NULL

--Update null value = 0
UPDATE dbo.Data 
SET Longitude = 0 WHERE Longitude IS NULL

UPDATE dbo.Data
SET Latitude = 0 WHERE Latitude IS NULL

UPDATE dbo.Data
SET Recovered = 0 WHERE Recovered IS NULL

UPDATE dbo.Data
SET Active = 0 WHERE Active IS NULL

UPDATE dbo.Data
SET Incidence_Rate = 0 WHERE Incidence_Rate IS NULL

UPDATE dbo.Data
SET Case_Fatality_Ratio = 0 WHERE Case_Fatality_Ratio IS NULL

--- 1. DESCRIPTIVE STATISTICS ---
---- We will check some basic statistics before going to the indexs of 2 major characteristics of descriptive stastistics

/* check first 10 rows */
SELECT TOP 10 * FROM dbo.Data

/* check how many rows */
SELECT COUNT(*) AS 'Nb of row'
FROM dbo.Data;
/* how many month */
SELECT DATEPART(YEAR, Date) AS 'Year', COUNT(DISTINCT(MONTH(Date))) AS 'NB of month' FROM dbo.Data
GROUP BY DATEPART(YEAR, Date)
/*start_date - end_date*/
SELECT MIN(Date) AS 'start_date', MAX(Date) AS 'end_date' FROM dbo.Data
/* how many rows in each month */
SELECT DATEPART(YEAR, Date) AS 'Year', DATEPART(MONTH, Date) AS 'Month', COUNT(*) AS 'Nb of row'
FROM dbo.Data
GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
ORDER BY 1,2,3

/*min: confirmed, deaths, recovered per month*/

SELECT DATEPART(YEAR, Date) AS 'Year', 
	DATEPART(MONTH, Date) AS 'Month', 
	MIN(Confirmed) AS min_confirmed, 
	MIN(Deaths) AS min_dealths, 
	MIN(Recovered) AS min_recovered
FROM dbo.Data
GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
ORDER BY 1,2

--max: confirmed, deaths, recovered per month
SELECT DATEPART(YEAR, Date) AS 'Year', 
	DATEPART(MONTH, Date) AS 'Month', 
	MAX(Confirmed) AS max_confirmed, 
	MAX(Deaths) AS max_dealths, 
	MAX(Recovered) AS max_recovered
FROM dbo.Data
GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
ORDER BY 1,2

-- The total case: confirmed, deaths, recovered per month

SELECT DATEPART(YEAR, Date) AS 'Year', 
	DATEPART(MONTH, Date) AS 'Month', 
	sum(Confirmed) AS sum_confirmed, 
	sum(Deaths) AS sum_dealths, 
	sum(Recovered) AS sum_recovered
FROM dbo.Data
GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
ORDER BY 1,2

/********* 1.1. The central tendency: a distribution is an estimate of the “center” of a distribution of values: 
-- MEAN
-- MODE
-- MEDIAN
*********/

---------- MEAN ----------

SELECT DATEPART(YEAR, Date) AS 'Year', 
	DATEPART(MONTH, Date) AS 'Month', 
	ROUND(AVG(Confirmed),0) AS avg_confirmed,
	ROUND(AVG(Deaths),0) AS avg_dealths, 
	ROUND(AVG(Recovered),0) AS avg_recovered
FROM dbo.Data
GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
ORDER BY 1,2

---------- MEDIAN ----------
--To get the last value in the top 50 percent of rows.
SELECT TOP 1 Confirmed
FROM dbo.Data
WHERE Confirmed IN (SELECT TOP 50 PERCENT Confirmed 
					FROM dbo.Data
					ORDER BY Confirmed ASC)
ORDER BY Confirmed DESC

---------- MODE ----------
/* What is the frequently occuring numbers of confirmed cases in each month? */
/* we can see that February 2020 are the months which have most number of confirmed case*/
SELECT TOP 1 
	DATEPART(YEAR, Date) AS 'Year', 
	DATEPART(MONTH, Date) AS 'Month', 
	confirmed
FROM   dbo.Data
WHERE  Confirmed IS Not NULL
GROUP  BY DATEPART(YEAR, Date), DATEPART(MONTH, Date), confirmed
ORDER  BY COUNT(*) DESC

/********* 1.2. The dispersion: refers to the spread of the values around the central tendency:
-- RANGE = max value - min value
-- VARIANCE
-- STANDART DEVIATION
*********/

-- How spread out? 
--- confirmed case
SELECT 
	SUM(confirmed) AS total_confirmed, 
	ROUND(AVG(confirmed), 0) AS average_confirmed,
	ROUND(VAR(confirmed),0) AS variance_confirmed,
	ROUND(STDEV(confirmed),0) AS std_confirmed
FROM dbo.Data
--- deaths case
SELECT 
	SUM(deaths) AS total_deaths, 
	ROUND(AVG(deaths), 0) AS average_deaths,
	ROUND(VAR(deaths),0) AS variance_deaths,
	ROUND(STDEV(deaths),0) AS std_deaths
FROM dbo.Data
--- recovered case
SELECT 
	SUM(recovered) AS total_recovered, 
	ROUND(AVG(recovered), 0) AS average_recovered,
	ROUND(VAR(recovered),0) AS variance_recovered,
	ROUND(STDEV(recovered),0) AS std_recovered
FROM dbo.Data

/* How spread out in each month? */
--- confirmed case
SELECT 
	DATEPART(YEAR, Date) AS 'Year', 
	DATEPART(MONTH, Date) AS 'Month', 
	SUM(confirmed) AS total_confirmed, 
	ROUND(AVG(confirmed), 0) AS average_confirmed,
	ROUND(VAR(confirmed),0) AS variance_confirmed,
	ROUND(STDEV(confirmed),0) AS std_confirmed
FROM dbo.Data
GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
ORDER BY 1,2
--- deaths case
SELECT 
	DATEPART(YEAR, Date) AS 'Year', 
	DATEPART(MONTH, Date) AS 'Month', 
	SUM(deaths) AS total_deaths, 
	ROUND(AVG(deaths), 0) AS average_deaths,
	ROUND(VAR(deaths),0) AS variance_deaths,
	ROUND(STDEV(deaths),0) AS std_deaths
FROM dbo.Data
GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
ORDER BY 1,2
--- recovered case
SELECT 
	DATEPART(YEAR, Date) AS 'Year', 
	DATEPART(MONTH, Date) AS 'Month', 
	SUM(recovered) AS total_recovered, 
	ROUND(AVG(recovered), 0) AS average_recovered,
	ROUND(VAR(recovered),0) AS variance_recovered,
	ROUND(STDEV(recovered),0) AS std_recovered
FROM dbo.Data
GROUP BY DATEPART(YEAR, Date), DATEPART(MONTH, Date)
ORDER BY 1,2

--2. PERCENTITLES AND FREQUENCY
--Percentiles : One hundreds equal groups; population divided across group
--Percentiles help us understand the distribution of data by grouping values into equal sized buckets.

--Discrete Percentile: returns value that exists in the column.
--Discrete Percentile is very useful when you want to know the value in the column, that falls into a percentile.

--Continuous Percentile: interpolates the boundary value between the percentiles.
--Continuous Percentile is very useful when you want to know what is the value at the boundary between two percentile buckets.

--TOP 5
SELECT TOP 5 * FROM dbo.Data

/* What are the top data ? */
/* Data Interpretion: 
it seems like top cases are coming from 12 month, which is not suprising due to seasonality trend of holidays or regions*/

--TOP 10 of the Confirmed case: the most Confirmed case are from India in April and May 2021
SELECT TOP 10 *
FROM dbo.Data
ORDER BY Confirmed DESC

--TOP 10 of the Deaths case: the most deaths case are from India. It causes the largest number of confirmed case.
SELECT TOP 10 *
FROM dbo.Data
ORDER BY Deaths DESC

--TOP 10 of the recovered case: is similar to Deaths case
SELECT TOP 10 *
FROM dbo.Data
ORDER BY recovered DESC


/* What about average of each case ? */
/* the average confirmed, deaths, recovered case are respectively about 1256, 27, 848 but it doesn't tell us the full story, like
- Are there many days with low cases?
- Are there many days with high cases? 
- or our cases evenly distributed across all days?
*/

SELECT
	ROUND(AVG(Confirmed),0) AS avg_confirmed,
	ROUND(AVG(Deaths),0) AS avg_deaths,
	ROUND(AVG(Recovered),0) AS avg_recoverd
FROM dbo.Data

/****** we can use percentiles to answer above question and understand our data distributions *******/

/*** Percentile Discrete Function ***/

/* get 50 percentile of values, and compare to the average value
--- confirmed: it seem like 50 percentile of revenue 3 cases, it is too far off from the average confrimed case - 1256 case
--- it is similarly to deaths and recovered case*/
--- it means that there are many low values in each type of case.
---PERCENTITLE
SELECT
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY Confirmed) OVER() AS percentitles_confirmed_50,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY Deaths) OVER() AS percentitles_deaths_50,
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY Recovered) OVER() AS percentitles_recovered_50
FROM dbo.Data


/* let's look at 50th, 60th , 90th , 95th percentiles OF confirmed case */

SELECT
	PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY Confirmed) OVER () AS pct_50_revenues,
	PERCENTILE_DISC(0.6) WITHIN GROUP(ORDER BY Confirmed) over () AS pct_60_revenues,
	PERCENTILE_DISC(0.9) WITHIN GROUP(ORDER BY Confirmed) over () AS pct_90_revenues,
	PERCENTILE_DISC(0.95) WITHIN GROUP(ORDER BY Confirmed) over () AS pct_95_revenues
FROM dbo.Data;

/*** Percentile Continuous Function ***/
SELECT 
	PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY confirmed) OVER() AS pct_95_cont_confirmed,
	PERCENTILE_DISC(0.95) WITHIN GROUP(ORDER BY confirmed) OVER() AS pct_95_disc_reconfirmed
FROM dbo.Data;

--- 3.CORRELATION AND RANKS

/* check the correlation between confirmed, deaths and recoverd case*/
/* we can see that there is high correlation between confirmed, deaths and recoverd case, which make sense.*/
-- confirmed-deaths: 0.7917
SELECT ((Avg(Confirmed * Deaths) - (Avg(Confirmed) * Avg(Deaths))) / (StDev(Confirmed) * StDev(Deaths))) AS 'Cor_cf_dt'
FROM dbo.Data
--confirmed - recovered: 0.68807
SELECT ((Avg(Confirmed * Recovered) - (Avg(Confirmed) * Avg(Recovered))) / (StDev(Confirmed) * StDev(Recovered))) AS 'Cor_cf_rc'
FROM dbo.Data
--deaths - recovered: 0.60565
SELECT ((Avg(deaths * Recovered) - (Avg(deaths) * Avg(Recovered))) / (StDev(deaths) * StDev(Recovered))) AS 'Cor_dt_rc'
FROM dbo.Data


/* We want to add a row number based on the case */
SELECT
	ROW_NUMBER() OVER(ORDER BY Confirmed) AS Row_number, *
FROM dbo.Data;


/* We also want to know the standing (rank) of month_of_year based on the units sold */
SELECT
	ROW_NUMBER() OVER(ORDER BY confirmed) AS row_number,
	Province,
	Country,
	confirmed
FROM dbo.Data
ORDER BY confirmed DESC;


--- 4.LINEAR MODELS
/***************** Linear Models ****************/
/* Linear Model such as regression are useful for estimating values for business.
Such as: We just want to estimate how much revenue we get after run a marketing campaign with xx cost.*/

--- The result of Linear Regression: y=mx+b => y = 0.0136x + 9.9926. It means that when confirmed case increases 100 case, there will increase 1 deadth.

/*********** Computing Slope (Deaths on y-axis and confirmed case in x-asis) *********/
/* Result: 0.01360387 */
SELECT (count(Confirmed)*sum(Confirmed*Deaths) - sum(Confirmed)* sum(Deaths))/(count(Confirmed)*sum(Confirmed*Confirmed) - sum(Confirmed)* sum(Confirmed))
FROM dbo.Data

/*********** Computing Intercept (deaths on y-axis and confirmed case in x-asis) *********/ 
--Intercept = avg(y) - slope*avg(x)
/* Result: 9.992565367 */
SELECT AVG(Deaths) - ((count(Confirmed)*sum(Confirmed*Deaths) - sum(Confirmed)* sum(Deaths))/(count(Confirmed)*sum(Confirmed*Confirmed) - sum(Confirmed)* sum(Confirmed)))*AVG(Confirmed)
FROM dbo.Data

