--/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP (1000) [id]
--      ,[title]
--      ,[url]
--      ,[is_paid]
--      ,[num_subscribers]
--      ,[avg_rating]
--      ,[avg_rating_recent]
--      ,[rating]
--      ,[num_reviews]
--      ,[is_wishlisted]
--      ,[num_published_lectures]
--      ,[num_published_practice_tests]
--      ,[created]
--      ,[published_time]
--      ,[discount_price__amount]
--      ,[discount_price__currency]
--      ,[discount_price__price_string]
--      ,[price_detail__amount]
--      ,[price_detail__currency]
--      ,[price_detail__price_string]
--  FROM [PortfolioProject].[dbo].[Udemy]

------Portfolio Project. SQL Data Exploration------

--Skills used:
--1. SQL programming: The project involves writing SQL queries to extract, manipulate, and analyze data from a relational database.
--2. Data exploration and analysis: The project involves performing data exploration and analysis to gain insights into the Udemy dataset.
--3. Database design: The project involves creating tables and views to organize and present the data in a structured format.
--4. Data cleaning: The project involves cleaning and filtering the data to remove duplicates, missing values, and irrelevant records.
--5. Data visualization: The project mentions creating views for future data visualizations in Tableau.
--6. Data reporting: The project involves summarizing and presenting the findings in a clear and concise manner.
--7. Problem solving: The project involves identifying data quality issues, designing solutions, and optimizing SQL queries to address business questions.

--1. What is the total number of courses in the dataset?
SELECT COUNT(*) as total_courses
FROM Udemy;

--2. What is the average rating for courses in the dataset?
SELECT AVG(rating) as avg_rating
FROM Udemy;

--3. What are the top 10 most expensive courses in the dataset?
SELECT TOP 10 title, price_detail__amount AS price
FROM Udemy
ORDER BY price_detail__amount DESC;

--4. What are the top 10 highest rated courses in the dataset?
SELECT TOP 10 title, rating
FROM Udemy
ORDER BY rating DESC

--5. What are the top 10 most viewed courses in the dataset?
SELECT TOP 10 title, num_subscribers
FROM Udemy
ORDER BY num_subscribers DESC

--6. What is the total number of subscribers across all courses?
SELECT SUM(num_subscribers) as total_subscribers
FROM Udemy

--7. What are the top 10 courses with the most subscribers?
SELECT TOP 10 title, num_subscribers
FROM udemy
ORDER BY num_subscribers DESC;

--8. What is the average number of reviews per course?
SELECT AVG(num_reviews) AS avg_num_reviews
FROM udemy;

--9. What is the most expensive course and how much does it cost?
SELECT TOP 1 title, price_detail__amount, price_detail__currency
FROM udemy
WHERE price_detail__amount IS NOT NULL
ORDER BY price_detail__amount DESC;

--10. What are the top 10 courses with the highest average recent rating?
SELECT TOP 10 title, avg_rating_recent
FROM udemy
ORDER BY avg_rating_recent DESC;

--11. What is the total revenue generated by all the paid courses?
SELECT SUM(price_detail__amount) AS revenue
FROM udemy
WHERE is_paid = 'True';

--12. What are the top 10 courses with the highest number of lectures?
SELECT TOP 10 title, num_published_lectures
FROM udemy
ORDER BY num_published_lectures DESC;

--13. What is the average discount offered on Udemy courses?
SELECT AVG((discount_price__amount/price_detail__amount)*100) AS avg_discount
FROM udemy
WHERE discount_price__amount IS NOT NULL;

--14. What is the average rating of courses that are currently wishlisted by users?
SELECT AVG(avg_rating) AS avg_rating
FROM Udemy

-- Create the course_info table
CREATE TABLE course_info (
  id INT PRIMARY KEY,
  title VARCHAR(255),
  url VARCHAR(255),
  is_paid VARCHAR(10),
  num_subscribers INT,
  avg_rating FLOAT,
  avg_rating_recent FLOAT,
  rating FLOAT,
  num_reviews INT,
  is_wishlisted VARCHAR(10),
  num_published_lectures INT,
  num_published_practice_tests INT,
  created VARCHAR(50),
  published_time VARCHAR(50)
);
-- Insert data into the course_info table
INSERT INTO course_info(id, title, url, is_paid, num_subscribers, avg_rating, avg_rating_recent, rating, num_reviews,
  is_wishlisted, num_published_lectures, num_published_practice_tests, created, published_time)
SELECT DISTINCT
  id, title, url, is_paid, num_subscribers, avg_rating, avg_rating_recent, rating, num_reviews,
  is_wishlisted, num_published_lectures, num_published_practice_tests, created, published_time
FROM Udemy;

-- Create the course_price table
CREATE TABLE course_price (
  id INT PRIMARY KEY,
  discount_price__amount FLOAT,
  discount_price__currency VARCHAR(50),
  discount_price__price_string VARCHAR(50),
  price_detail__amount FLOAT,
  price_detail__currency VARCHAR(50),
  price_detail__price_string VARCHAR(50)
);

-- Insert data into the course_price table
INSERT INTO course_price (
  id, discount_price__amount, discount_price__currency, discount_price__price_string,
  price_detail__amount, price_detail__currency, price_detail__price_string
)
SELECT DISTINCT
  id, discount_price__amount, discount_price__currency, discount_price__price_string,
  price_detail__amount, price_detail__currency, price_detail__price_string
FROM Udemy;

--JOIN syntax--

--1. Find the top 10 courses with the highest number of subscribers and their prices.
SELECT TOP 10 ci.title, ci.num_subscribers, cp.price_detail__amount
FROM Course_Info ci
JOIN Course_Price cp ON ci.id = cp.id
ORDER BY ci.num_subscribers DESC;

--2. Find the courses that have both a high rating (above 4.5) and a high number of subscribers (above 10,000).
SELECT ci.title, ci.num_subscribers, ci.avg_rating
FROM Course_Info ci
JOIN Course_Price cp ON ci.id = cp.id
WHERE ci.avg_rating > 4.5 AND ci.num_subscribers > 10000;

--3. Find the courses that have a discount price and were published in the last 6 months, and their original price.
SELECT ci.title, cp.discount_price__amount, cp.price_detail__amount
FROM Course_Info ci
JOIN Course_Price cp ON ci.id = cp.id
WHERE cp.discount_price__amount IS NOT NULL AND ci.published_time >= DATEADD(month, -6, GETDATE());

--4. Find the number of courses that were published in 2020 and their average rating.
SELECT COUNT(ci.id), AVG(ci.avg_rating)
FROM Course_Info ci
JOIN Course_Price cp ON ci.id = cp.id
WHERE YEAR(ci.published_time) = 2020;

--Creating View to store data for later visualizations

--1. Subscribers by Course Category.
CREATE VIEW SubscribersByCategory AS
SELECT 
    SUM(num_subscribers) AS total_subscribers,
    LEFT(title, CHARINDEX('-', title)-2) AS course_category
FROM Udemy
GROUP BY LEFT(title, CHARINDEX('-', title)-2)

--2. Average Course Rating by Month.
CREATE VIEW AverageRatingByMonth AS
SELECT 
    AVG(avg_rating) AS avg_rating,
    MONTH(created) AS month,
    YEAR(created) AS year
FROM Udemy
GROUP BY MONTH(created), YEAR(created)

--3. Most Popular Courses.
CREATE VIEW Most_Popular_Courses AS
SELECT TOP 10 title, num_subscribers
FROM Udemy
ORDER BY num_subscribers DESC;


