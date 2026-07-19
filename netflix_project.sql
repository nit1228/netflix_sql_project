SELECT * FROM netflix;

-- 15 Business Problems & Solutions

1. Count the number of Movies vs TV Shows

SELECT type,count(*) AS Total_Number
FROM netflix 
GROUP BY type;

2. Find the most common rating for movies and TV shows

WITH t1 AS(
SELECT rating,type,count(*),
RANK() OVER(partition by type order by count(*) DESC) AS rnk
FROM netflix
GROUP BY rating,type)

SELECT rating,type
FROM t1
WHERE rnk=1;

3. List all movies released in a specific year (e.g., 2020)

SELECT *
FROM netflix
WHERE release_year=2020 AND type='Movie';

4. Find the top 5 countries with the most content on Netflix

WITH t1 AS(
SELECT country,count(*),
ROW_NUMBER() OVER(order by count(*) DESC) AS rnk
FROM(
SELECT TRIM(UNNEST(string_to_array(country, ','))) AS country
FROM netflix
WHERE country IS NOT NULL) AS t1
GROUP BY country)
SELECT COUNTRY
FROM t1
WHERE rnk<=5;

5. Identify the longest movie

SELECT title,duration
FROM(
SELECT title,cast(replace(duration,'min','') AS INTEGER) AS duration
FROM netflix
WHERE type='Movie' AND duration is NOT NULL) AS t1
order by duration DESC
LIMIT 1;

6. Find content added in the last 5 years

SELECT type, date
FROM
(SELECT type,
TO_DATE(date_added,'Month DD,YYYY') AS date
FROM netflix) AS t1
WHERE date>=current_date- INTERVAL '5 years';

7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT title 
FROM(
SELECT *,trim(unnest(string_to_array(director,','))) AS director_name
FROM netflix) AS t1
WHERE director_name='Rajiv Chilaka';

8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	cast(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5

9. Count the number of content items in each genre

SELECT TRIM(unnest(string_to_array(listed_in,','))) AS genre,COUNT(*) AS
number_of_content
FROM netflix
GROUP BY 1;

10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

WITH t1 AS
(SELECT trim(unnest(string_to_array(country,','))) AS coun,
extract(year FROM TO_DATE(date_added,'MONTH DD ,YYYY')) AS rele_year
FROM netflix)
,t2 AS(
SELECT rele_year,count(*) AS cnt
FROM t1
WHERE coun='India'
GROUP BY 1)
SELECT rele_year,ROUND((cnt/(SELECT sum(cnt) FROM t2))*100.0,2) AS aver
FROM t2
ORDER BY 2 DESC
LIMIT 5;

11. List all movies that are documentaries

SELECT title
FROM netflix
WHERE type='Movie' AND listed_in LIKE '%Documentaries%'

12. Find all content without a director

SELECT * 
FROM netflix
WHERE DIRECTOR IS NULL;

13. Find how many movies actor 'Salman Khan' appeared in last 10 years.

SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND 
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT actors,count(*) AS total_count
FROM
(SELECT TRIM(UNNEST(string_to_array(casts,','))) AS actors, country
FROM netflix
WHERE type='Movie' AND country ILIKE '%India%')
GROUP BY actors
ORDER BY 2 DESC
LIMIT 10;

15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

WITH t1 AS(
SELECT description,
CASE WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
ELSE 'Good' END AS labels
FROM netflix)
SELECT labels,count(*) AS number_of_items
FROM t1
GROUP BY labels











