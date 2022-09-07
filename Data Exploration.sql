/*
Covid 19 Data Exploration

Skills: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- Select data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location LIKE 'germany'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Total cases vs population
-- Shows what percentage of population infected with covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
-- WHERE location LIKE 'germany'
ORDER BY 1, 2

-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
-- WHERE locaion LIKE 'germany'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death count per population

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
-- WHERE location LIKE 'germany'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
-- WHERE location LIKE 'germany'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
-- WHERE location LIKE 'germany'
WHERE continent	IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2



-- Total population vs vaccinations
-- Shows percentage of population that has recieved at least ine covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE to perform calculation on partition by in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- Using Temp Table to perform calculation on partition by in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVAccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL