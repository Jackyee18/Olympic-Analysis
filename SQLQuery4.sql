--1. How many olympics games have been held?
--2. List down all Olympics games held so far.
--3. Mention the total no of nations who participated in each olympics game?
--4. Which year saw the highest and lowest no of countries participating in olympics?
--5. Which nation has participated in all of the olympic games?
--6. Identify the sport which was played in all summer olympics.
--7. Which Sports were just played only once in the olympics?
--8. Fetch the total no of sports played in each olympic games.
--9. Fetch details of the oldest athletes to win a gold medal.
--10. Find the Ratio of male and female athletes participated in all olympic games.

SELECT * FROM athlete_events
--1. How many olympics games have been held?
SELECT COUNT(DISTINCT(games)) AS Olympic_game FROM athlete_events
--2. List down all Olympics games held so far.
SELECT DISTINCT(games) AS Olympic_game FROM athlete_events
ORDER BY 1
--3. Mention the total no of nations who participated in each olympics game?
SELECT games, COUNT(DISTINCT(NOC)) as Team_count FROM athlete_events
GROUP BY games
ORDER BY 1
--4. Which year saw the highest and lowest no of countries participating in olympics?
-- The lowest no of countries participating in Olympic
SELECT TOP 1 games, COUNT(DISTINCT(NOC)) as Team_count FROM athlete_events
GROUP BY games
ORDER BY COUNT(DISTINCT(NOC)) 
-- The highest no of countries participating in Olympic
SELECT TOP 1 games, COUNT(DISTINCT(NOC)) as Team_count FROM athlete_events
GROUP BY games
ORDER BY COUNT(DISTINCT(NOC)) DESC

--5. Which nation has participated in all of the olympic games?
--- Olympic games by Nation
SELECT NOC, COUNT(DISTINCT(games)) as Games_count FROM athlete_events
			GROUP BY NOC
--- NOC have participated in all olympic games
SELECT NOC, COUNT(DISTINCT(games)) as Games_count FROM athlete_events
GROUP BY NOC
HAVING COUNT(DISTINCT(games)) IN (SELECT COUNT(DISTINCT(games)) AS Olympic_game FROM athlete_events)
--- Final solution
WITH cte AS(SELECT NOC, COUNT(DISTINCT(games)) as Games_count 
			FROM athlete_events
			GROUP BY NOC)
SELECT a.NOC, region, Games_count
FROM cte a
JOIN noc_regions b
ON a.NOC = b.NOC
WHERE Games_count IN (SELECT COUNT(DISTINCT(games)) AS Olympic_game FROM athlete_events)
--6. Identify the sport which was played in all summer olympics.
----- a. HOW MANY SUMMER OLYMPIC GAMES
SELECT COUNT(DISTINCT(games)) as Summer_Olympic_games FROM athlete_events
WHERE Season = 'Summer'
--- b. SPORT BY OLYMPIC GAMES
SELECT sport, COUNT(DISTINCT(games)) as Games_count FROM athlete_events
WHERE Season = 'Summer'
GROUP BY sport
ORDER BY 2 DESC
---  the sport which was played in all summer olympics
SELECT sport, COUNT(DISTINCT(games)) as Games_count FROM athlete_events
WHERE Season = 'Summer'
GROUP BY sport
HAVING COUNT(DISTINCT(games)) IN (SELECT COUNT(DISTINCT(games)) as Summer_Olympic_games 
									FROM athlete_events	WHERE Season = 'Summer')
--7. Which Sports were just played only once in the olympics?
SELECT sport, COUNT(DISTINCT(games)) as Games_count FROM athlete_events
WHERE Season = 'Summer'
GROUP BY sport
HAVING COUNT(DISTINCT(games)) = 1
--8. Fetch the total no of sports played in each olympic games.
SELECT games, COUNT(DISTINCT(sport)) AS Sport_count FROM athlete_events
GROUP BY games
ORDER BY 1
--9. Fetch details of the oldest athletes to win a gold medal.
--- list of athletes win gold medal
SELECT * FROM athlete_events
WHERE Medal = 'Gold'
ORDER BY Age DESC
--- THE AGE OF OLDEST ATHLETES TO WIN A GOLD MEDAL
SELECT MAX(Age) AS Max_age
FROM athlete_events
WHERE Medal = 'Gold'
--- details of the oldest athletes to win a gold medal
SELECT * FROM athlete_events
WHERE Medal = 'Gold' AND Age in (SELECT MAX(Age) AS Max_age
								FROM athlete_events
								WHERE Medal = 'Gold')
--10. Find the Ratio of male and female athletes participated in all olympic games.
-- LIST OF ATHLETES 
SELECT 
SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END) AS Female_athletes,
SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END) AS Male_athletes,
ROUND(CAST(SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END) AS decimal) / (SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END) + SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END)) *100,2) AS Female_percent,
ROUND(CAST(SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END) AS decimal) / (SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END) + SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END)) *100,2) AS Male_percent
FROM athlete_events

--11. Fetch the top 5 athletes who have won the most gold medals.
--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
--14. List down total gold, silver and broze medals won by each country.
--15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.
--16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
--18. Which countries have never won gold medal but have won silver/bronze medals?
--19. In which Sport/event, India has won highest medals.
--20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.


--11. Fetch the top 5 athletes who have won the most gold medals.
--- list of gold medal athletes
SELECT Name, count(Name) AS Gold_medals
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name
ORDER BY 2 DESC
--- LIST OF GOLD MEDAL ATHELTES
SELECT Name, count(Name) AS Gold_medals, DENSE_RANK() OVER(ORDER BY count(Name) DESC) AS No
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name

SELECT Name, count(Name) AS Gold_medals, ROW_NUMBER() OVER(ORDER BY count(Name) DESC) AS No
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY Name
--- TOP 5 ATHLETES WHO HAVE WON THE MOST GOLD MEDAL
WITH CTE AS (SELECT Name, count(Name) AS Gold_medals, DENSE_RANK() OVER(ORDER BY count(Name) DESC) AS No
			FROM athlete_events
			WHERE Medal = 'Gold'
			GROUP BY Name)
SELECT Name, Gold_medals
FROM CTE
WHERE No <= 5
--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
--- list of athletes who have won medal
SELECT * FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
--- name list of athletes who have won medal
SELECT Name, COUNT(Name) AS Medals, DENSE_RANK() OVER(ORDER BY COUNT(Name) DESC) As No
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Name
--- final solution
WITH CTE AS(SELECT Name, COUNT(Name) AS Medals, DENSE_RANK() OVER(ORDER BY COUNT(Name) DESC) As No
			FROM athlete_events
			WHERE Medal IN ('Gold','Silver','Bronze')
			GROUP BY Name)
SELECT Name, Medals
FROM CTE
WHERE No <= 5
--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
-- list of medals by teams
SELECT Team, COUNT(Team) AS Medals, DENSE_RANK() OVER(ORDER BY COUNT(Name) DESC) As No
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Team

WITH CTE AS (SELECT NOC, COUNT(NOC) AS Medals, DENSE_RANK() OVER(ORDER BY COUNT(Name) DESC) As No
			FROM athlete_events a
			WHERE Medal IN ('Gold','Silver','Bronze')
			GROUP BY NOC)
SELECT a.NOC, region, Medals
FROM CTE a
JOIN noc_regions b
ON a.NOC = b.NOC
ORDER BY Medals DESC

-- top 5 most successful team in olympics
WITH CTE AS (SELECT Team, COUNT(Team) AS Medals, DENSE_RANK() OVER(ORDER BY COUNT(Name) DESC) As No
			FROM athlete_events
			WHERE Medal IN ('Gold','Silver','Bronze')
			GROUP BY Team)
SELECT Team, Medals
FROM CTE
WHERE No <= 5
-- top 5 most successful countries in olympics
WITH CTE AS (SELECT NOC, COUNT(NOC) AS Medals, DENSE_RANK() OVER(ORDER BY COUNT(Name) DESC) As No
			FROM athlete_events a
			WHERE Medal IN ('Gold','Silver','Bronze')
			GROUP BY NOC)
SELECT a.NOC, region, Medals
FROM CTE a
JOIN noc_regions b
ON a.NOC = b.NOC
WHERE No <= 5
ORDER BY 3 DESC
--14. List down total gold, silver and broze medals won by each country.
SELECT Team, COUNT(Team) AS Medals, 
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold_medals,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver_medals,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze_medals
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Team
ORDER BY 2 DESC


SELECT NOC, COUNT(NOC) AS Medals, 
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold_medals,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver_medals,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze_medals
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY NOC
ORDER BY 1

--- FINAL SOLUTION
SELECT Team, COUNT(Team) AS Medals, 
	SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
	SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
	SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze
FROM athlete_events
WHERE Medal IN ('Gold','Silver','Bronze')
GROUP BY Team
ORDER BY 2 DESC

WITH CTE AS(
		SELECT NOC, COUNT(NOC) AS Medals, 
			SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
			SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
			SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze
		FROM athlete_events
		WHERE Medal IN ('Gold','Silver','Bronze')
		GROUP BY NOC)
SELECT a.NOC, region, Medals, Gold, Silver, Bronze
FROM CTE a
LEFT JOIN noc_regions b
ON a.noc = b.noc
ORDER BY 3 DESC

--- PIVOT TABLE SOLUTION
--- FIND THE SOURCE TABLE TO PIVOT
SELECT region AS Country, medal, count(1) as total_medals
FROM athlete_events a
JOIN noc_regions b ON a.noc = b.noc
WHERE Medal <> 'NA'
GROUP BY region, medal
--- PIVOT TABLE IN SQLServer
SELECT Country, Gold AS Gold,  Silver AS Silver,  Bronze AS Bronze  
FROM  
    (SELECT region AS Country, medal, count(1) as total_medals
	FROM athlete_events a
	JOIN noc_regions b ON a.noc = b.noc
	WHERE Medal <> 'NA'
	GROUP BY region, medal)   
    AS medal_per_countries1
PIVOT  
(  
    SUM(total_medals)  
FOR   
MEDAL  
    IN (Gold,Silver, Bronze)  
) AS medal_per_countries2 
--- FINAL SOLUTION WITH PIVOT TABLE FUNCTION
SELECT Country, isnull(Gold,0) AS Gold, isnull(Silver,0) AS Silver, isnull(Bronze,0) AS Bronze  
FROM  
    (SELECT region AS Country, medal, count(1) as total_medals
	FROM athlete_events a
	JOIN noc_regions b ON a.noc = b.noc
	WHERE Medal <> 'NA'
	GROUP BY region, medal)   
    AS Source_table
PIVOT  
(  
    SUM(total_medals)  
FOR   
MEDAL  
    IN (Gold,Silver, Bronze)  
) AS Pivot_table 

--15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.

WITH CTE AS(
		SELECT NOC, games, COUNT(1) AS Medals, 
			SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
			SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
			SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze
		FROM athlete_events
		WHERE Medal IN ('Gold','Silver','Bronze')
		GROUP BY NOC, games)
SELECT a.NOC, region, a.games, Medals, Gold, Silver, Bronze
FROM CTE a
LEFT JOIN noc_regions b
ON a.noc = b.noc
ORDER BY 4 DESC
--16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
WITH CTE AS(
		SELECT NOC, games, COUNT(1) AS Medals, 
			SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
			SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
			SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze
		FROM athlete_events
		WHERE Medal IN ('Gold','Silver','Bronze')
		GROUP BY NOC, games)
SELECT *
FROM CTE
ORDER BY 2

--- find max gold/silver/bronze with first value function
WITH CTE AS(
		SELECT NOC, games, COUNT(1) AS Medals, 
			SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
			SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
			SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze
		FROM athlete_events
		WHERE Medal IN ('Gold','Silver','Bronze')
		GROUP BY NOC, games)
SELECT *, FIRST_VALUE(Gold) over(partition by games ORDER BY Gold Desc) AS max_gold,
FIRST_VALUE(Silver) over(partition by games ORDER BY Silver Desc) AS max_silver,
FIRST_VALUE(Bronze) over(partition by games ORDER BY Bronze Desc) AS max_bronze
FROM CTE
ORDER BY 2
--- FIND THE MAX GOLD AND MAX COUNTRY BY FIRST VALUE
WITH CTE AS(
		SELECT NOC, games, COUNT(1) AS Medals, 
			SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
			SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
			SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze
		FROM athlete_events
		WHERE Medal IN ('Gold','Silver','Bronze')
		GROUP BY NOC, games)
SELECT distinct games, FIRST_VALUE(Gold) over(partition by games ORDER BY Gold Desc) As Max_gold
,FIRST_VALUE(NOC) OVER(PARTITION BY games ORDER BY Gold desc) As Max_Gold_Country
FROM CTE a
--- OUTPUT TABLE WITH NOC AND MAX MEDAL
WITH CTE AS(
		SELECT NOC, games, COUNT(1) AS Medals, 
			SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
			SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
			SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze
		FROM athlete_events
		WHERE Medal IN ('Gold','Silver','Bronze')
		GROUP BY NOC, games)
SELECT distinct games, 
CONCAT(FIRST_VALUE(NOC) OVER(PARTITION BY games ORDER BY Gold desc),' - ',FIRST_VALUE(Gold) over(partition by games ORDER BY Gold Desc)) AS Gold_max_country,
CONCAT(FIRST_VALUE(NOC) OVER(PARTITION BY games ORDER BY Silver desc),' - ',FIRST_VALUE(Silver) over(partition by games ORDER BY Silver Desc)) AS Silver_max_country,
CONCAT(FIRST_VALUE(NOC) OVER(PARTITION BY games ORDER BY Bronze desc),' - ',FIRST_VALUE(Bronze) over(partition by games ORDER BY Bronze Desc)) AS Bronze_max_country
FROM CTE
--- MY SOLUTION
WITH CTE AS (SELECT NOC, games, COUNT(1) AS Medals, 
						SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
						SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
						SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze
			FROM athlete_events
			WHERE Medal IN ('Gold','Silver','Bronze')
			GROUP BY NOC, games)
SELECT DISTINCT games,
CONCAT(FIRST_VALUE(region) OVER(partition by games ORDER BY GOLD DESC),' - ',FIRST_VALUE(gold) OVER(partition by games ORDER BY GOLD DESC)) AS max_gold,
CONCAT(FIRST_VALUE(region) OVER(partition by games ORDER BY silver DESC),' - ',FIRST_VALUE(silver) OVER(partition by games ORDER BY silver DESC)) AS max_silver,
CONCAT(FIRST_VALUE(region) OVER(partition by games ORDER BY bronze DESC),' - ',FIRST_VALUE(bronze) OVER(partition by games ORDER BY bronze DESC)) AS max_bronze
FROM CTE a
JOIN noc_regions b
ON a.noc = b.noc

--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
WITH CTE AS (SELECT NOC, games, COUNT(1) AS Medals, 
						SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS Gold,
						SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS Silver,
						SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS  Bronze
			FROM athlete_events
			WHERE Medal IN ('Gold','Silver','Bronze')
			GROUP BY NOC, games)
SELECT DISTINCT games,
CONCAT(FIRST_VALUE(region) OVER(partition by games ORDER BY Medals DESC),' - ',FIRST_VALUE(Medals) OVER(partition by games ORDER BY Medals DESC)) AS max_medals,
CONCAT(FIRST_VALUE(region) OVER(partition by games ORDER BY GOLD DESC),' - ',FIRST_VALUE(gold) OVER(partition by games ORDER BY GOLD DESC)) AS max_gold,
CONCAT(FIRST_VALUE(region) OVER(partition by games ORDER BY silver DESC),' - ',FIRST_VALUE(silver) OVER(partition by games ORDER BY silver DESC)) AS max_silver,
CONCAT(FIRST_VALUE(region) OVER(partition by games ORDER BY bronze DESC),' - ',FIRST_VALUE(bronze) OVER(partition by games ORDER BY bronze DESC)) AS max_bronze
FROM CTE a
JOIN noc_regions b
ON a.noc = b.noc

--18. Which countries have never won gold medal but have won silver/bronze medals?
SELECT region FROM athlete_events ae
JOIN noc_regions nr
ON nr.noc = ae.noc
WHERE Medal in ('silver','bronze')
GROUP BY region

--19. How many vietnamese atletes have participate in olympic.
SELECT count(distinct(name)) as total_vietnam_athletes FROM athlete_events
WHERE Team = 'Vietnam'

--20. Who is the first vietnamese athlete that won the gold medal in olympic
SELECT * FROM athlete_events
WHERE Team = 'Vietnam' AND Medal = 'Gold'

SELECT * FROM athlete_events
WHERE Team = 'Vietnam' AND Medal = 'Silver'

SELECT * FROM athlete_events
WHERE Team = 'Vietnam' AND Medal = 'Bronze'


--20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
SELECT * FROM athlete_events
SELECT * FROM noc_regions