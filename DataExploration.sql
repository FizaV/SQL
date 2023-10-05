--SELECT TOP 1000 *
--FROM PortfolioProject.dbo.CovidDeaths


--SELECT TOP 1000 *
--FROM PortfolioProject.dbo.CovidVaccinations


--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject.dbo.CovidDeaths
--ORDER BY 1, 2


--Total Cases vs Total Deaths
--SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercent
--FROM PortfolioProject.dbo.CovidDeaths
--ORDER BY 1, 2

--SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercent
--FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like 'India'
--ORDER BY 1, 2


--SELECT location, date, population, total_cases, (total_cases/population)*100 DeathPercent
--FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like '%states%'
--ORDER BY 1, 2


--SELECT location, date, population, total_cases, (total_cases/population)*100 DeathPercent
--FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like '%states%'
--ORDER BY 1, 2


--Infection Rate vs Population
SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Countries with highest death count 
SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


--BY CONTINENT 
SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Continent with highest death count
SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global Numbers
SELECT date, SUM(total_cases) TotalCases, SUM(new_cases) NewCases--, total_deaths, (total_deaths/total_cases)*100 DeathPercent
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like 'India'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2


SELECT date, SUM(new_cases) NewCases, SUM(cast(new_deaths as int)) NewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like 'India'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2


--Join the tables
SELECT *
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date


--Total population vs vaccination
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 1,2


SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))  OVER (PARTITION BY death.location ORDER BY death.location, death.date) RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 1,2


--Percent People Vaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))  OVER (PARTITION BY death.location ORDER BY death.location, death.date) RollingPeopleVaccinated
--(MAX(RollingPeopleVaccinated)/ Population) * 100 PercentPopulationVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 1,2



--USE CTE
WITH PopvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))  OVER (PARTITION BY death.location ORDER BY death.location, death.date) RollingPeopleVaccinated
--(MAX(RollingPeopleVaccinated)/ Population) * 100 PercentPopulationVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/ Population) * 100 PercentPopulationVaccinated
FROM PopvsVAC


--Creating view

CREATE VIEW PercentPopulationVaccinated1 AS
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations))  OVER (PARTITION BY death.location ORDER BY death.location, death.date) RollingPeopleVaccinated
--(MAX(RollingPeopleVaccinated)/ Population) * 100 PercentPopulationVaccinated
FROM PortfolioProject.dbo.CovidDeaths death
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3