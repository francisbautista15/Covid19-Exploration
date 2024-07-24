/*

EXPLORATION OF COVID19 DATA USING SQL
Data Used: https://ourworldindata.org/coronavirus#explore-the-global-situation

Skills Highlighted: CTE, JOINS, VIEWm Aggregate Functions, Windows Functions, Converting Data Type.

*/


SELECT *
FROM covid-analysis-francisbautista.Covid_Data.covid_deaths
WHERE continent IS NOT null
ORDER BY 3,4

-- Firstly, select data in which will be used as a starting point of exploration

SELECT 
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
FROM covid-analysis-francisbautista.Covid_Data.covid_deaths
ORDER BY 1,2

-- Exploring the contrast between Total Cases and Total Deaths within Australia
---- (Likelyhood of death due to COVID-19)

SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 AS death_percentage
FROM covid-analysis-francisbautista.Covid_Data.covid_deaths
WHERE location = "Australia"
ORDER BY 1,2


-- Exploring the percentage of population infected with COVID-19 within Australia

SELECT
  location,
  date,
  Population,
  total_cases,
  (total_cases/population)*100 AS population_infected_percentage
FROM covid-analysis-francisbautista.Covid_Data.covid_deaths
WHERE location = "Australia"
-- This WHERE function can be altered to represent any country or deleted to show all locations
ORDER BY 1,2


-- Exploring which countries have the highest infection rate in contrast to population
SELECT
  location,
  Population,
  MAX(total_cases) AS highest_infection_count,
  MAX((total_cases/population))*100 AS population_infected_percentage,
FROM covid-analysis-francisbautista.Covid_Data.covid_deaths
GROUP BY location, Population
ORDER BY population_infected_percentage DESC

-- Exploring countries with the highest deaths per population
SELECT
  location,
  MAX(CAST(Total_deaths AS INT64)) AS total_death_count
FROM covid-analysis-francisbautista.Covid_Data.covid_deaths
WHERE continent IS NOT null
GROUP BY Location
ORDER BY total_death_count desc
---- Upon investigation, it's noted that there are entries within "location" in which isn't group by a country. This is caused due to null values within the "continent" colummn. Therefore, use the function "WHERE" to disregard null values. 


-- EXPLORING COVID19 DATASET BY CONTINENT

-- Exploration of continents with the highest death count by population

SELECT 
  continent,
  MAX(CAST(Total_deaths AS INT64)) AS total_death_count
FROM covid-analysis-francisbautista.Covid_Data.covid_deaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY total_death_count desc


-- GLOBAL TOTAL EXPLORATION
SELECT
  SUM(new_cases) AS total_cases, 
  SUM(CAST(new_deaths AS INT64)) AS total_deaths,
  SUM(CAST(new_deaths AS INT64))/SUM(new_Cases)*100 AS death_percentage
FROM covid-analysis-francisbautista.Covid_Data.covid_deaths
WHERE continent IS NOT null
ORDER BY 1,2

-- EXPLORATION OF COVID VACCINATION IN AUSTRALIA

-- Percentage of population in which have recieved at lease one COVID vaccine

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64)) OVER
    (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_population_vaccinated,

FROM covid-analysis-francisbautista.Covid_Data.covid_deaths dea
JOIN covid-analysis-francisbautista.Covid_Data.covid_vaccinations vac 
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT null AND dea.location = "Australia" AND vac.new_vaccinations IS NOT null
ORDER BY 2,3 

-- Either a CTE or TEMP TABLE must be created to produce a percentage column

-- CTE Approach 

WITH population_and_vaccinated(continent, location, date, population, new_vaccinations, rolling_population_vaccinated) 
AS
(SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64)) OVER
    (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_population_vaccinated

FROM covid-analysis-francisbautista.Covid_Data.covid_deaths dea
JOIN covid-analysis-francisbautista.Covid_Data.covid_vaccinations vac 
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT null AND dea.location = "Australia" AND vac.new_vaccinations IS NOT null
ORDER BY 2,3)

SELECT *,
(rolling_population_vaccinated/population)*100
FROM population_and_vaccinated

-- TEMP TABLE Approach

DROP TABLE IF EXISTS #populationvaccinatedpercentage
--- DROP TABLE is used to regulate and avoid errors.

CREATE TABLE #populationvaccinatedpercentage
(
  continent STRING,
  location STRING,
  date DATETIME,
  population INT64,
  new_vaccinations INT64,
  rolling_population_vaccinated INT64
)

INSERT INTO #populationvaccinatedpercentage
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64)) OVER
    (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_population_vaccinated

FROM covid-analysis-francisbautista.Covid_Data.covid_deaths dea
JOIN covid-analysis-francisbautista.Covid_Data.covid_vaccinations vac 
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT null AND dea.location = "Australia" AND vac.new_vaccinations IS NOT null
ORDER BY 2,3)

SELECT *,
(rolling_population_vaccinated/population)*100
FROM population_and_vaccinated


--CREATING VIEW TO BE USED FOR DATA VIZ

CREATE VIEW population_vaccinated AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64)) OVER
    (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_population_vaccinated

FROM covid-analysis-francisbautista.Covid_Data.covid_deaths dea
JOIN covid-analysis-francisbautista.Covid_Data.covid_vaccinations vac 
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT null AND dea.location = "Australia" AND vac.new_vaccinations IS NOT null

---- Queries Written by Francis Bautista


