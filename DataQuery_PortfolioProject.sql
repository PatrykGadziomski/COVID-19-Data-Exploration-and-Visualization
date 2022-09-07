SELECT *
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 3, 4

Select *
From PortfolioProject..CovidVaccinations
Order by 3, 4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
and location like '%states%'
ORDER BY 1, 2

-- Looking at the total Cases vs Population
-- Shows ehat percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectPopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location like 'germany'
Where continent is not null
ORDER BY 1, 2


-- Looking at Countries with highets Infection Rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS 
	InfectPopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location like 'germany'
Where continent is not null
GROUP by location, population
ORDER BY InfectPopulationPercentage desc


-- Showing Countries with the highest Death Count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location like 'germany'
Where continent is not null
GROUP by location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location like 'germany'
Where continent is not null
GROUP by continent
ORDER BY TotalDeathCount desc


-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location like 'germany'
Where continent is not null
GROUP by continent
ORDER BY TotalDeathCount desc

-- Global numbers

SELECT SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--Group by date
ORDER BY 1, 2


-- Looking at total population vs vaccinations
-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinationss, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating viwe to store data for later visualiations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

SELECT *
FROM PercentPopulationVaccinated