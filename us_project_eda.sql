# US Household Income and US Household Income Statistics: Exploratory Data Analysis 

SELECT * FROM us_project.us_household_income;

SELECT * FROM us_project.us_household_income_statistics;

# Preliminary EDA 
SELECT State_Name, County, City, ALand, AWater
FROM us_project.us_household_income;

# Top 10 States with the biggest land 
SELECT State_Name,  SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10;

# Top 10 State with the largest sum of water 
SELECT State_Name,  SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10;

# Joining Both tables 
SELECT * 
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id;

# Identifying if there ID numbers not present in the household income data set 
    SELECT * 
FROM us_project.us_household_income u
RIGHT JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
WHERE u.id IS NULL;

# Right and Inner Join has the same output 
SELECT * 
FROM us_project.us_household_income u
RIGHT JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id ;
    
# Top 10 States with highest average median where the mean does not equal 0 
SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median), 1) 
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
WHERE Mean <> 0 
GROUP BY u.State_Name 
ORDER BY 3 ASC
LIMIT 10;

# Return the different type of cities with the Average mean and median  
SELECT Type, ROUND(AVG(Mean),1), ROUND(AVG(Median), 1) 
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type  
ORDER BY 2 DESC
LIMIT 10;


# Ouput type and the count of types greater than 100 throughout all the states with the average mean and median 
SELECT Type, Count(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median), 1) 
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type 
HAVING COUNT(Type) > 100 
ORDER BY 4 DESC
LIMIT 20;


# Output State name, city with the average mean and median 
SELECT u.State_Name, City, ROUND(AVG(Mean),1), ROUND(AVG(Median), 1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
GROUP BY u.State_Name, City 
ORDER BY u.State_Name, City, ROUND(AVG(Mean),1) DESC;


# Output all of the cities in the state of florida where mean is not equal to 0 
SELECT City, ROUND(AVG(Mean), 0), ROUND(AVG(Median),0)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
WHERE u.State_Name = 'Florida' AND Mean <> 0 
GROUP BY City 
ORDER BY ROUND(AVG(Mean), 0) ;


# Create a CTE called 'Summary' to summarize the data by the mean and median household income grouped by state and counting the number of distinct cities in each state 
# Using the CTE pull the state that has the max  and min. number of cities as well as the average mean and median 
WITH Summary (State_Name, Number_OF_Cities, Average_Mean, Average_Median) 
AS (
SELECT u.State_Name, COUNT(DISTINCT City) AS Number_OF_Cities, ROUND(AVG(Mean),0) AS Average_Mean, ROUND(AVG(Median), 0) AS Average_Median 
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
GROUP BY u.State_Name
)
SELECT State_Name, Number_OF_Cities, Average_Mean, Average_Median 
FROM Summary 
WHERE Number_OF_Cities IN (
	SELECT MIN(Number_OF_Cities)
    FROM SUMMARY
    ) OR 
    Number_OF_Cities IN ( 
    SELECT MAX(Number_OF_Cities) FROM Summary
    ) ; 


# Using the same CTE as above, pull the data from the state of florida 
WITH Summary (State_Name, Number_OF_Cities, Average_Mean, Average_Median) 
AS (
SELECT u.State_Name, COUNT(DISTINCT City) AS Number_OF_Cities, ROUND(AVG(Mean),0) AS Average_Mean, ROUND(AVG(Median), 0) AS Average_Median 
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us 
	ON u.id = us.id
GROUP BY u.State_Name
)
SELECT State_Name, Number_OF_Cities, Average_Mean, Average_Median 
FROM Summary 
WHERE State_Name = 'Florida'  ; 

# Create a CTE with state, qualifications of city with the average mean and median 
WITH City_Type (State_Name, Type, Avg_Mean, Avg_Median) AS 
( 
	SELECT u.State_Name, Type, ROUND(AVG(Mean),0) AS Avg_Mean, ROUND(AVG(Median), 0) AS Avg_Median
	FROM us_project.us_household_income u
	INNER JOIN us_project.us_household_income_statistics us 
		ON u.id = us.id
	GROUP BY u.State_Name, Type 
)
SELECT State_Name, Type, Avg_Mean, Avg_Median 
FROM City_Type 
ORDER BY State_Name, Type, Avg_Median ; 


# Using same CTE as above, create another one to rank the median from highest to lowest as High_Ranking and lowest to highest as Low_Ranking 
# Then outputs the Max and Min of the median for each state and the type associated with it 
WITH City_Type (State_Name, Type, Avg_Mean, Avg_Median) AS 
( 
	SELECT u.State_Name, Type, ROUND(AVG(Mean),0) AS Avg_Mean, ROUND(AVG(Median), 0) AS Avg_Median
	FROM us_project.us_household_income u
	INNER JOIN us_project.us_household_income_statistics us 
		ON u.id = us.id
	GROUP BY u.State_Name, Type 
),
Highest_Median_Type AS ( 
	SELECT State_Name, Type, Avg_Mean, Avg_Median, 
    ROW_NUMBER() OVER (PARTITION BY State_Name ORDER BY Avg_Median DESC) AS High_Ranking, 
    ROW_NUMBER() OVER (PARTITION BY State_Name ORDER BY Avg_Median ASC) AS Low_Ranking
    FROM City_Type 
)
SELECT State_Name, Type, Avg_Mean, Avg_Median 
FROM Highest_Median_Type 
WHERE High_Ranking = 1 OR Low_Ranking = 1 
ORDER BY State_Name ;  

# Data limitation: no time or date in data. It would have insgihtful to see the change in the median and mean over time.



