-- Dataset for Project Provided by Coursera Google Professional Data Analytics Certification

CREATE DATABASE cyclistic;
	
CREATE TABLE IF NOT EXISTS tripdata_2020_2021 
(
ride_id text NOT NULL,
rideable_type text NOT NULL, 
started_at datetime NOT NULL, 
ended_at datetime NOT NULL,
start_station_name texT NOT NULL, 
start_station_id int NOT NULL,
end_station_name text NOT NULL,
end_station_id int NOT NULL,
start_lat double NOT NULL,
start_lng double NOT NULL,
end_lat double NOT NULL,
end_lng double NOT NULL, 
member_casual text NOT NULL
); 

LOAD DATA LOCAL INFILE "C:/Users/Vicentic/Documents/01_Dusan/01_Professional/02_DataAnalyst/02_Projects/01_CaseStudyCyclistic/01_ProjectData/divvy-tripdata.csv"
INTO TABLE tripdata_2020_2021
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Cleaning Dataset

DELETE FROM cleaned_tripdata
WHERE 
	start_station_id = 0
    OR
    end_station_id = 0;

-- Separating Ride Data From Geocode

CREATE TABLE station_geocode AS
SELECT
	DISTINCT t.start_station_name,
    t.start_lat,
	t.start_lng
FROM tripdata_2020_2021 t;

ALTER TABLE cleaned_tripdata
DROP COLUMN ride_id,
DROP COLUMN start_lat,
DROP COLUMN Start_lng,
DROP COLUMN end_lat,
DROP COLUMN end_lng;

-- Removing Outliers & Altering ride_length

UPDATE tripdata_2020_2021
SET ride_length = TIMESTAMPDIFF(SECOND, started_at, ended_at);

CREATE TABLE cleaned_tripdata AS
SELECT *
FROM tripdata_2020_2021
WHERE ride_length
BETWEEN (SELECT AVG(ride_length) - 3 * STDDEV(ride_length) FROM tripdata_2020_2021) AND (SELECT AVG(ride_length) + 3 * STDDEV(ride_length) FROM tripdata_2020_2021);

UPDATE cleaned_tripdata
SET ride_length = TIME_FORMAT(ride_length, '%H:%i:%s');

DELETE FROM cleaned_tripdata
WHERE ride_length = '00:00:00';

-- Separating Date Format

ALTER TABLE cleaned_tripdata
ADD COLUMN day VARCHAR(10);

UPDATE cleaned_tripdata
SET day = DAYNAME(started_at);

ALTER TABLE cleaned_tripdata
ADD COLUMN month VARCHAR(10);

UPDATE cleaned_tripdata
SET month = MONTHNAME(started_at);

-- Weekly Usage

SELECT
	day,
    member_casual,
    count(*)
FROM cleaned_tripdata
GROUP BY
	day,
    member_casual
ORDER BY 
    count(*) DESC;

-- Yearly Usage

SELECT
	month,
	member_casual,
    count(*)
FROM cleaned_tripdata
GROUP BY 
	day,
    member_casual
ORDER BY 
	count(*) DESC;

-- 5 Busiest Stations

SELECT
	DISTINCT start_station_name
FROM 
	cleaned_tripdata;

SELECT 
	start_station_name,
    start_station_id,
	COUNT(*) AS ride_count
FROM
	cleaned_tripdata
GROUP BY
	start_station_name,
    start_station_id
ORDER BY ride_count DESC
LIMIT 5;


