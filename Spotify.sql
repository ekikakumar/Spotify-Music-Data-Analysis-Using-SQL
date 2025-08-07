CREATE DATABASE spotify;
CREATE TABLE IF NOT EXISTS song_list(
artist VARCHAR(50),
track VARCHAR(200),
album VARCHAR(200),
album_type VARCHAR(50),
dancebility FLOAT,
energy FLOAT,
loudness FLOAT,
speechiness FLOAT,
acousticness FLOAT,
instrumentalness FLOAT,
liveness FLOAT,
valence FLOAT,
tempo FLOAT,
duration FLOAT,
title VARCHAR(300),
channel_name VARCHAR(50),
views INT,
likes INT,
comments INT,
licensed BOOLEAN,
official_video BOOLEAN,
stream_no INT,
energy_liveness FLOAT,
most_played_on VARCHAR(50)); 

LOAD DATA LOCAL INFILE 'C:\\Users\\91620\\Downloads\\Spotify dataset.csv'
INTO TABLE song_list
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

#EDA 
SELECT * FROM song_list; 
SELECT COUNT(*) FROM song_list; 
SELECT DISTINCT(track)
FROM song_list; 

SELECT COUNT(DISTINCT artist) FROM song_list; 
SELECT COUNT(DISTINCT album) FROM song_list; 
SELECT DISTINCT album_type FROM song_list;
SELECT MAX(duration) FROM song_list; 
SELECT MIN(duration) FROM song_list; 

SELECT * FROM song_list
WHERE duration = 0; 

DELETE FROM song_list
WHERE duration = 0;

SELECT DISTINCT channel_name FROM song_list; 
SELECT DISTINCT most_played_on FROM song_list; 

#Business Problems
 
#1 Retrieve the names of all the tracks that have more than 1 billions streams.
SELECT * FROM song_list
WHERE stream_no > 1000000000; 

#2 List all the albums along with their respective artists.
SELECT DISTINCT album, artist FROM song_list;

#3 Get the total number of comments for tracks where liceSced = TRUE. 
SELECT SUM(comments) AS Total_comments FROM song_list 
WHERE licensed = 'true'; 

#4 Find all the tracks that belong to the album type 'single'.
SELECT * FROM song_list 
WHERE album_type = 'single'; 

#5 Count the total number of tracks by each artist.
SELECT artist, COUNT(track) AS Total_tracks FROM song_list
GROUP BY artist
ORDER BY Total_tracks ASC; 

#6 Calculate the average dancebility of tracks in each album. 
SELECT album, AVG(dancebility) AS Average_dancebility
FROM song_list
GROUP BY album
ORDER BY Average_dancebility DESC; 

#7 Find the top 5 tracks with highest energy values.
SELECT track, MAX(energy) as Energy_values
FROM song_list
GROUP BY track
ORDER BY AVG(energy) DESC
LIMIT 5; 

#8 List all the tracks with their views and likes where official_video = TRUE. 
SELECT track, SUM(likes) AS Total_likes, SUM(views) AS Total_views
FROM song_list
WHERE official_video = 'true'
GROUP BY track; 

#9 For each album, calculate the total views of all associated track. 
SELECT album, track, SUM(views) AS Total_views
FROM song_list
GROUP BY album, track
ORDER BY Total_views DESC; 

#10 Find the top three most viewed tracks for each artist using window functions. 
WITH ranking AS(
SELECT track, artist, album, total_views,
       DENSE_RANK() OVER (
         PARTITION BY artist
         ORDER BY total_views DESC
       ) AS top_viewed
FROM (
    SELECT track, artist, album, SUM(views) AS total_views
    FROM song_list
    GROUP BY track, artist, album
) AS ranked_tracks
ORDER BY artist, total_views DESC
)
SELECT * FROM ranking 
WHERE top_viewed <=3; 

#11 Write a query to find the tracks where liveness score is above the average. 
 SELECT track, artist, album, liveness 
 FROM song_list 
 WHERE liveness> (SELECT AVG(liveness)
 FROM song_list); 

#12 Find tracks where energy-to-liveness ration is greater than 1.2. 
SELECT track, artist, album, energy/liveness AS energy_liveness_ratio  
FROM song_list 
WHERE energy/liveness > 1.2; 

#13 Find the cummulative likes of each track. 
SELECT track, artist, album, views, likes,
       SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM song_list;
