-- =======================================================================================================================================
-- PROJEKT NETFLIX
-- =======================================================================================================================================

--Tworzenie pustej tabeli do zaimportowania pliku CSV
CREATE TABLE netflix_raw (
show_id VARCHAR(50), 
type VARCHAR(50), 
title TEXT, 
"cast" TEXT, 
country TEXT, 
date_added VARCHAR(100), 
release_year INTEGER, ra  
)


--Obsługa braków danych (NULL) i podmiana na 'unknown'
CREATE OR REPLACE VIEW netfix_clean AS
SELECT
	show_id,
	type,
	title,
	COALESCE(director, 'unknown') AS director,
	COALESCE(country, 'unknown') AS country,
--zmiana tekstu na datę
	TO_DATE(TRIM(date_added), 'Month DD, YYYY') AS data_added_clean,
	CAST (release_year AS INTEGER) AS release_year, rating,
--wyciągnięcie liczby minut dla filmów
	CASE
		WHEN type = 'Movie' THEN
		CAST (SPLIT_PART (duration, ' ', 1) AS INTEGER)
		ELSE NULL
	END AS duration_minutes,
--wyciągnięcie liczby sezonów dla seriali
	CASE
		WHEN type = 'TV Show' THEN CAST (SPLIT_PART(duration, ' ', 1) AS INTEGER)
		ELSE NULL
		END AS duration_seasons,
		listed_in AS genres
	FROM netflix_raw

--Procentowy udział filmów i seriali w danym roku
SELECT
	EXTRACT (YEAR FROM date_added_clean) AS addition_year,
	type,
	SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS  Movies_count,
	SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS  TV_show_count,
	ROUND(SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) * 100 / COUNT(*), 1) AS movies_percent,
	ROUND(SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) * 100 / COUNT(*), 1) AS TV_show_percent
FROM netflix_clean
WHERE date_added_clean IS NOT NULL
GROUP BY EXTRACT (YEAR FROM date_added_clean), type
ORDER BY addition_year DESC;


--Analiza gatunków filmów z podzialłem na serial i film
--Rozbicie gatunków po przecinku na osobne wiersze i usunięcie spacji
WITH RozbicieGatunkow AS (
SELECT 
	show_id, 
	type, 
	TRIM(UNNEST(STRING_TO_ARRAY(genres, ','))) AS genres
FROM netflix_clean ),
--Zliczanie ile razy dany gatunek występuje
ZliczoneGatunki AS (
SELECT
	type,
	genres,
	COUNT(*) AS total_sum
FROM RozbicieGatunkow
GROUP BY type, genres),
--Ranking osobno dla filmów i seriali
RankingGatunkow AS (
SELECT
	type,
	geres,
	total_sum,
	ROW_NUMBER () OVER (PARTITION BY type ORDER BY total_sum DESC) AS pozycja_w_rankingu
FROM ZliczoneGatunki)
--TOP 10
SELECT
	type,
	genres,
	total_sum,
	pozycja_w_rankingu
FROM RankingGatunkow
WHERE pozycja_w_rankingu <= 10
ORDER BY type, pozycja_w_rankingu


 --top 10 rezyserów seriali i filmow
 --wyodrębnienie pojedyńczych reżyserów, usunięcie spacji oraz odrzucenie 'unknow'
 WITH RozbiciiRezyserzy AS (
 SELECT 
 	type, 
 	TRIM (UNNEST (STRING_TO_ARRAY(director, ','))) AS director_name 
FROM netflix_clean
WHERE director != 'unknown'
)
--Zliczenie ile razy powtarza się dany reżyser
SELECT
	type,
	director_name,
	count(*) AS total_count,
	SUM(CASE WHEN type='TV Show' THEN 1 ELSE 0 END) AS TV_shows_count,
	SUM(CASE WHEN type='Movie' THEN 1 ELSE 0 END) AS Movie_count
FROM RozbiciiRezyserzy
GROUP BY type, director_name
ORDER BY total_count DESC
LIMIT 10


--Analiza top 10 państw produkujacych filmy i seriale
WITH RozbiciePanstw AS (
SELECT 
	type,
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name
FROM netflix_clean
)
--Zliczanie ile razy powtarza się dane państwo
ZliczonePanstwa AS (
SELECT 
	type,
	COUNT(*) AS country_total
	SUM (CASE WHEN type = 'movie' THEN 1 ELSE 0 END),
	SUM (CASE WHEN type = 'TV show' THEN 1 ELSE 0 END)
FROM RozbiciePanstw
GROUP BY type, country_name
ORDER BY country_total DESC
),
--Ranking osobno dla filmów i seriali
RankingPanstw AS (
SELECT
	type,
	country_name,
	country_total,
	ROW_NUMBER () OVER (PARTITION BY type ORDER BY country_total DESC) AS pozycja_w_rankingu
FROM ZliczonePanstwa)
--TOP 10  z każdej kategorii
SELECT
	type,
	country_name,
	country_total,
	pozycja_w_rankingu
FROM RankingPanstw
WHERE pozycja_w_rankingu <= 10
ORDER BY type, pozycja_w_rankingu