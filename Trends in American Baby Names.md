# Trending American Baby Names - A Datacamp SQL project
How have American baby name tastes changed since 1920? Which names have remained popular for over 100 years, 
and how do those names compare to more recent top baby names? These are considerations for many new parents, but the skills you'll practice while answering these queries are broadly applicable. 
After all, understanding trends and popularity is important for many businesses, too!
I'll be working with data provided by the United States Social Security Administration, which lists first names along with the number and sex of babies they were given to in each year. 
For processing speed purposes, the dataset is limited to first names which were given to over 5,000 American babies in a given year. The data spans 101 years, from 1920 through 2020.

## The Data 

baby_names

| column | type | description|
|--- | --- | --- |
| year        | int        | year |
| first_name  | varchar    | first name |
| sex         | varchar    | gender |
| num         | int        | number of babies given with that first_name |


> Run this code to view the data in baby_names
```
SELECT *
FROM baby_names
LIMIT 5;
```

### Question #1
- List the overall top five names in alphabetical order and find out if each name is "Classic" or "Trendy." 
- column should have, (first_name, sum, popularity_type)
- (50 or more years using that name is 'Classic' else 'Trendy')

> I created a CTE that provides the count of unique years that a first_name is used.
```
WITH name_sums AS (
    SELECT first_name, SUM(num) AS total, COUNT(DISTINCT year) AS year_count
    FROM baby_names
    GROUP BY first_name
),  
-- create a CTE that turns the year count into a CASE WHEN statement
name_rankings AS (
    SELECT first_name, total,
           CASE
               WHEN year_count >= 50 THEN 'Classic'
               ELSE 'Trendy'
           END AS popularity_type
    FROM name_sums
)
-- Combine CTEs to get the result
SELECT first_name, total AS sum, popularity_type
FROM name_rankings
ORDER BY first_name
LIMIT 5;
```


## Question #2
- What were the top 20 male names overall, and how did the name Paul rank?

> a straightforward approach using WINDOW function. 
```
SELECT
	RANK() OVER(ORDER BY SUM(num) DESC) AS name_rank,
	first_name,
	SUM(num) sum
	FROM public.baby_names
	WHERE sex ='M'
	GROUP BY first_name
	LIMIT 20
```

## Question #3
- Which female names appeared in both 1920 and 2020?

> I created a CTE that extract the female names in 1920
```
WITH names_1920 AS (
    SELECT first_name
    FROM public.baby_names
    WHERE year = 1920 AND sex = 'F'
),
-- created a CTE that extract the female names in 2020
names_2020 AS (
    SELECT first_name
    FROM public.baby_names
    WHERE year = 2020 AND sex = 'F'
)
-- JOIN both CTEs to the main table
SELECT n.first_name, SUM(bn.num) AS total_occurrences
FROM names_1920 n
JOIN names_2020 n2 ON n.first_name = n2.first_name
JOIN public.baby_names bn ON bn.first_name = n.first_name AND bn.sex = 'F'
GROUP BY n.first_name;
```
# Conclusion
In this project, I demonstrated my proficiency in SQL by leveraging Common Table Expressions, aggregations, window functions, and joins.  
Using these techniques, I uncovered key insights that met the client's needs and provided valuable education on the common usage patterns of American baby names. After all, even the slightest information like baby names, would help a particular business.
