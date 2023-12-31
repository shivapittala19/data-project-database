
-- 1. Write a SQL script that creates a new user, and database. Make the user the owner of the db.

CREATE DATABASE IPLPROJECT;


CREATE USER SQLUSER WITH PASSWORD 'password';


ALTER DATABASE IPLPROJECT OWNER TO SQLUSER;

-- 2.Write another SQL script that cleans up the user, and database created in the previous step.

ALTER DATABASE IPLPROJECT OWNER TO POSTGRES;


DROP USER SQLUSER;


DROP DATABASE IF EXISTS IPLPROJECT ;



-- Create tables
CREATE TABLE MATCHES(ID int PRIMARY KEY, SEASON int, CITY varchar, date date, TEAM1 varchar, TEAM2 varchar, TOSS_WINNER varchar, TOSS_DECISION varchar, RESULT varchar, DL_APPLIED int, WINNER varchar, WIN_BY_RUNS int, WIN_BY_WICKETS int, PLAYER_OF_MATCH varchar, VENUE varchar, UMPIRE1 varchar, UMPIRE2 varchar, UMPIRE3 varchar);

CREATE TABLE DELIVERIES(MATCH_ID int, INNING int, BATTING_TEAM varchar, BOWLING_TEAM varchar, OVER int, BALL int, BATSMAN varchar, NON_STRIKER varchar, BOWLER varchar, IS_SUPER_OVER int, WIDE_RUNS int, BYE_RUNS int, LEGBYE_RUNS int, NOBALL_RUNS int, PENALTY_RUNS int, BATSMAN_RUNS int, EXTRA_RUNS int, TOTAL_RUNS int, PLAYER_DISMISSED varchar, DISMISSAL_KIND varchar, FIELDER varchar);

ALTER TABLE DELIVERIES ADD
FOREIGN KEY (MATCH_ID) REFERENCES MATCHES(ID);

CREATE TABLE UMPIRES (UMPIRE varchar, COUNTRY varchar);

-- Import the data from csv files
COPY MATCHES
FROM '/var/lib/postgresql/matches.csv'
DELIMITER ',' CSV HEADER;

COPY UMPIRES
FROM '/var/lib/postgresql/umpires.csv'
DELIMITER ',' CSV HEADER;

COPY DELIVERIES
FROM '/var/lib/postgresql/deliveries.csv'
DELIMITER ',' CSV HEADER;


-- 1. Total runs scored by team
SELECT BATTING_TEAM,
	SUM(TOTAL_RUNS)
FROM DELIVERIES
GROUP BY BATTING_TEAM;

-- 2. Top batsman for Royal Challengers Bangalore
SELECT BATSMAN,
	SUM(BATSMAN_RUNS) AS RUNS
FROM DELIVERIES
WHERE BATTING_TEAM = 'Royal Challengers Bangalore'
GROUP BY BATSMAN
ORDER BY RUNS DESC
LIMIT 10;

-- 3. Foreign umpire analysis
SELECT COUNTRY,
	COUNT(UMPIRE) AS UMPIRE_COUNT
FROM UMPIRES
RIGHT JOIN
	(SELECT UMPIRE1 AS UMP
		FROM MATCHES
		WHERE UMPIRE1 IS NOT NULL
		UNION  SELECT UMPIRE2 AS UMP
		FROM MATCHES
		WHERE UMPIRE2 IS NOT NULL) AS UMPIRE_LIST ON UMPIRES.UMPIRE = UMPIRE_LIST.UMP
WHERE COUNTRY not like ' India'
GROUP BY COUNTRY;

-- 4. Stacked chart of matches played by team by season
SELECT COMBINED.TEAM,
	COUNT(COMBINED.TEAM) AS MATCHES_PLAYED
FROM
	(SELECT TEAM1 AS TEAM
		FROM MATCHES
		UNION ALL SELECT TEAM2 AS TEAM
		FROM MATCHES) AS COMBINED
GROUP BY COMBINED.TEAM;

-- 5. Number of matches played per year for all the years in IPL

SELECT SEASON,
	COUNT(SEASON) AS MATCHES_PLAYED
FROM MATCHES
GROUP BY SEASON
ORDER BY SEASON;

-- 6. Number of matches won per team per year in IPL

SELECT SEASON,
	WINNER,
	COUNT(WINNER)
FROM MATCHES
GROUP BY WINNER,
	SEASON
ORDER BY SEASON;

-- 7. Extra runs conceded per team in the year 2016

SELECT BOWLING_TEAM,
	SUM(EXTRA_RUNS) AS RUNS
FROM DELIVERIES
INNER JOIN MATCHES ON DELIVERIES.MATCH_ID = MATCHES.ID
WHERE MATCHES.SEASON = '2016' GROUP  BY BOWLING_TEAM
ORDER BY BOWLING_TEAM;


-- 8. Top 10 economical bowlers in the year 2015
SELECT
    DELIVERIES.BOWLER,
    ROUND(
        CAST(SUM(DELIVERIES.TOTAL_RUNS - DELIVERIES.LEGBYE_RUNS - DELIVERIES.BYE_RUNS) AS DECIMAL(10, 2)) * 6.0 /
        CAST(COUNT(CASE WHEN DELIVERIES.WIDE_RUNS = 0 AND DELIVERIES.NOBALL_RUNS = 0 THEN 1 END) AS DECIMAL(10, 2)), 2
    )AS ECONOMY
FROM
    MATCHES
JOIN DELIVERIES ON DELIVERIES.MATCH_ID = MATCHES.ID
WHERE
    MATCHES.SEASON = 2015
GROUP BY
    DELIVERIES.BOWLER
ORDER BY
    ECONOMY
LIMIT 10;
