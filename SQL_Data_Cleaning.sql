/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [id]
      ,[title]
      ,[url]
      ,[is_paid]
      ,[num_subscribers]
      ,[avg_rating]
      ,[avg_rating_recent]
      ,[rating]
      ,[num_reviews]
      ,[is_wishlisted]
      ,[num_published_lectures]
      ,[num_published_practice_tests]
      ,[created]
      ,[published_time]
  FROM [PortfolioProject].[dbo].[course_info]

  --Data Cleaning

  --1. Remove duplicates:
  WITH CTE AS (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY title ORDER BY id) AS rn
  FROM Udemy
)
DELETE FROM CTE WHERE rn > 1;

--2. Remove currency sign:
UPDATE Udemy
SET discount_price__price_string = REPLACE(discount_price__price_string, '₹', '')

UPDATE Udemy
SET price_detail__price_string = REPLACE(price_detail__price_string, '₹', '')

--3. Remove courses with missing or null data in the num_subscribers column.
DELETE FROM Udemy WHERE num_subscribers IS NULL OR num_subscribers = 0;

--4. Remove courses with invalid or negative values in the price_detail__amount column.
DELETE FROM Udemy WHERE price_detail__amount < 0 OR price_detail__amount IS NULL;

--5. Convert the published_time column to a standard date format.
UPDATE Udemy
SET created = CONVERT(DATETIME, LEFT(created, 19), 126)

UPDATE Udemy
SET published_time = CONVERT(DATETIME, LEFT(created, 19), 126)

UPDATE Udemy
SET created = CONVERT(varchar, CAST(created AS date), 23) 

UPDATE Udemy
SET published_time = CONVERT(varchar, CAST(published_time AS date), 23) 









