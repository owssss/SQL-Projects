-- Data Cleaning Project
-- Dataset  "Layoffs"
-- REMOVE DUPLICATES, STARDARDIZED, CHECK NULLS & BLANKS, REMOVE UNNECESSARY COLUMNS --

-- Start by Creating Database where you will import the table
CREATE DATABASE world_layoffs;
USE world_layoffs;

-- Import table via right click tables > table data import wizard
-- imported the file as is but we can already do some data cleaning like fixing data types.(TEXT to datetime or INT)

SELECT *
FROM layoffs;
-- quick look at the table we analyze what we need to do in order to have a clean data, dirty data can cause wrong informations
-- 4 steps to keep in mind if we are cleaning data
	-- 1. Remove Duplicates (rows, columns)
	-- 2. Standardize the Data (Spelling, in order to group them accordingly)
	-- 3. Null  Values or Blank values (these values most of the time doesnt represent anything, is it need to be populated or deleted or keep it as is?)
	-- 4. Remove unnecessary columns (remove temporary added columns, or columns that will not be used in your Project

-- Before Cleaning the Data I duplicated the table so I wont have to apply permanent changes to an original data which may cause problems in the future.
-- I will be working on the duplicated table to avoid critical erros.

-- duplicating table columns (This create table that has similar set of columns from the original table (CREATE TABLE table_copy LIKE original_table)
CREATE TABLE layoffs_staging
LIKE layoffs;
-- what this do is CREATE a table exact LIKE the original

-- I have already made a table, time to fill in some rows, but exact rows from the original table. (INSERT table_copy SELECT * FROM original_table).
-- inserting duplicated rows
INSERT layoffs_staging
SELECT *
FROM layoffs;
-- This statement INSERT rows exact same rows FROM the original as per (SELECT * FROM original_table).


SELECT * FROM layoffs_staging;
-- Check the entire table-- you can also run both tables to check side by side on a quick glance.

-- Time to identify the duplicates (row or columns)

SELECT *, ROW_NUMBER() OVER(
PARTITION BY company,industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
-- This statement run everything and adds row_number that we partition in every column name
-- We now know that row_num that is > 1 is a duplicate

-- I will make a CTE(common table expresion) name it as a duplicate and see what are the duplicate rows.
WITH duplicate_cte AS
(
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_Cte
WHERE row_num >1;
-- I have 5 duplicates here and before deleting, we can check what are these rows, and their purpose. 

SELECT * FROM layoffs_staging
WHERE company = "casper";

-- now we can delete these  duplicate rows.
WITH duplicate_cte AS
(
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE  
FROM duplicate_Cte
WHERE row_num >1;
-- we cant run this syntax above because MySQL limitation, what we do is create another table that will have extra column named row_num
-- leaving it here for future references on other SQL softwares


-- Hopefully this is the final copy of our table, we are going to clean this table,  add a row_num at the end. 
-- we can copy a table other than what I did earlier, earlier is create table by CREATE TABLE LIKE . . 
-- This time we right click on the table and copy to clipboard > create statement
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- then below // Insert the created SELECT statement from CTE duplicate(to find duplicates) // not the full CTE but just the SELECT statement


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- now we can filter duplicates by WHERE

SELECT * FROM layoffs_staging2
WHERE row_num >= 2;

-- delete duplicates
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Now that we have the duplicate removed, we can proceed with Data Cleaning #2. 

-- 2. Standardizing Data (Trim, Spelling)
-- look for spaces
SELECT DISTINCT(company) FROM layoffs_staging2;

SELECT DISTINCT(TRIM(company))
FROM layoffs_staging2;

-- compare columns
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- update column
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Next Column (look for almost same industry or spelling, "crpyto currency","cryptocurrency")
SELECT DISTINCT(industry)
FROM layoffs_staging2
ORDER BY 1;

-- explore and analyze the industry.
SELECT * FROM layoffs_staging2
WHERE industry LIKE "Crypto%";

-- update to set them similar
UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";

-- look at location column we are still in Standardizing the data
SELECT location FROM layoffs_staging2;

-- look at country
SELECT DISTINCT(country)
FROM layoffs_staging2;
-- we found a United States with a dot at the end.

SELECT DISTINCT country, TRIM(Trailing '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE "United States%"
ORDER BY 1;
-- if I run this, I will select the unique country, and the country that has a trailing dot(.)

UPDATE layoffs_staging2
SET country = TRIM(Trailing '.' FROM country)
WHERE country LIKE "United States%";
-- above statement will standardized the same same country to United States. so we can have an accurate data grouping them by.

-- TIME SERIES (we still at stardization)
SELECT * FROM layoffs_staging2;
-- date is in TEXT data (change to date)

SELECT `date`,
str_to_date(`date`,"%m/%d/%Y")
FROM layoffs_staging2;
-- take note that m,d are in lowercase and Y is in uppercase.
-- ifthe date is 3/4/2023 then its "%m/%d/%Y", if its 3-4-2023 , it is "%m-%d-%Y"

-- update
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`,"%m/%d/%Y");
-- SELECTING the data before updating is a good practice so we know what we update.

-- check and alter to "DATE" datatype ( we just changed the format,but datatype is still in TEXT)
SELECT `date`
FROM layoffs_staging2;

-- alter the table and change data type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT * FROM layoffs_staging2;

-- 3. NULLS & BLANKS
-- NULLS & BLANKS -- analyze if needs to be populate or delete or leave it blank
SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL;
-- here we see the NULLs in total_laid_off

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- I combined it with percentage_laid_off by using AND, now we have rows that have nulls on both columns

SELECT DISTINCT industry
FROM layoffs_staging2;
-- Looking if there are NULL or blank in industry quick glance.

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = "";
-- select them specifically, we can analyze if we can populate the column manually by checking the same company
-- this case Airbnb and inudstry is Travel, so safe to say that the blank column under Airbnb is also in Travel industry.

SELECT * FROM layoffs_staging2
WHERE company = "airbnb";

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
-- the statement above lets me select the blank/null industry and checking the same industry in same table
	-- that has industry so I can compare them side by side.

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = "";
-- this updates the industry column that has blanks to NULL

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
-- this statement updates the table where columns are NULLS and the data that will be used are the data from the same column which has data.


SELECT *
FROM layoffs_staging2;
-- Quick check =)

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- taking time to analyze what to do with rows that has 2 columns without data.

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- delete these rows. >.<

-- DELETE row_num colum
ALTER TABLE layoffs_staging2
DROP COLUMN row_num
-- finally delete the row_num column which at the beginning we used it to filter duplicates.

-- This End the Data Cleaning Project Using MySQL == Thank You

