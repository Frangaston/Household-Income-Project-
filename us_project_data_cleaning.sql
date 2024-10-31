# US Household Income and US Houshold Income Statistics Cleaning 

SELECT * FROM us_project.us_household_income;

SELECT * FROM us_project.us_household_income_statistics;

ALTER TABLE us_project.us_household_income_statistics RENAME COLUMN `ï»¿id` TO `id`; 

SELECT * FROM us_project.us_household_income_statistics;

SELECT Count(id) FROM us_project.us_household_income;

SELECT Count(id) FROM us_project.us_household_income_statistics;

# Is there any duplicates using the ID number  
SELECT id, COUNT(id)
FROM us_project.us_household_income
GROUP BY id 
HAVING COUNT(id) > 1; 

# Once duplicates were identified, adding a row number to easily remove duplicates 
SELECT *
FROM (
SELECT row_id, id, 
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num 
FROM us_project.us_household_income
) duplicates 
WHERE row_num > 1 
; 


# Command to delete duplicate using above code 
DELETE FROM us_project.us_household_income
WHERE row_id IN (
SELECT row_id
FROM (
SELECT row_id, id, 
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num 
FROM us_project.us_household_income
) duplicates 
WHERE row_num > 1 )
; 

# Double checking that all duplicates have been removed 
SELECT id, COUNT(id)
FROM us_project.us_household_income_statistics
GROUP BY id 
HAVING COUNT(id) > 1; 


# Are all states included in the data 
SELECT DISTINCT State_Name
FROM us_project.us_household_income
ORDER BY 1 ;

# Updating errors noted in state names 
UPDATE us_project.us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia' ; 

UPDATE us_project.us_household_income
SET State_Name = 'Albama'
WHERE State_Name = 'alabama' ; 


# Identifying a blanks in the place column and updating it 
SELECT  *
FROM us_project.us_household_income
WHERE Place = '' ;

SELECT  *
FROM us_project.us_household_income
WHERE County = 'Autauga County' 
ORDER BY 1 ;

UPDATE us_project.us_household_income
SET Place = 'Autaugaville' 
WHERE County = 'Autauga County' 
AND City = 'Vinemont'; 

# Identifying inconsistencies in the Type column 
SELECT Type, COUNT(Type)
FROM us_project.us_household_income
GROUP BY Type; 


UPDATE us_project.us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs' ; 

# Is there any null,  blanks or 0 in the land or water columns 
SELECT ALand, AWater 
FROM us_project.us_household_income
WHERE AWater = 0 OR AWATER = '' OR AWater IS NULL ; 
 

SELECT ALand, AWater 
FROM us_project.us_household_income
WHERE (ALand = 0 OR ALand = '' OR ALand IS NULL); 

