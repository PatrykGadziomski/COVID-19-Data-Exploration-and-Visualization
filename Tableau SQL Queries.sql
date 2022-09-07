/*

Queries used for Tableau Visualization

*/

-- 1

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- 2

SELECT location, SUM(cast(new_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 3

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- 4

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC