SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..Vaccinations
ORDER BY 3,4

--SELECT DATA TO BE USED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELIHOOD OF DIEING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Nigeria' 
ORDER BY date

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS THE PERCENTAGE POPULATION THAT GOT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Nigeria' 
ORDER BY date


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATES

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--SHOWING COUTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Nigeria' 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--BREAK THINGS DOWN BY CONTINENT

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNTS

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Nigeria'
WHERE continent is null
AND location in ('Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania')
GROUP BY location
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

-- SHOWING NEW DEATHS AND NEW CASES PER DAY

SELECT date, SUM(new_cases) AS 'New Cases', SUM(cast(new_deaths AS int)) AS 'New Deaths', SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS 'Global Death Percentage'
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Nigeria' 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--SHOWING THE GLOBAL NUMBER OF CASES AND DEATHS WORLDWIDE

SELECT SUM(new_cases) AS 'New Cases', SUM(cast(new_deaths AS int)) AS 'New Deaths', SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS 'Global Death Percentage'
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Nigeria' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATIONS

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, CONVERT(date, dea.date)) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
(Partition by dea.location Order by dea.location, CONVERT(date, dea.date))
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..Vaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
AND dea.location LIKE 'Nigeria'
Order by 2, 3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, CONVERT(date, dea.date)) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageOfPopulationVaccinated
FROM PopvsVac

--TEMP TABLE 

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, CONVERT(date, dea.date)) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageOfPopulationVaccinated
FROM #PercentagePopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, CONVERT(date, dea.date)) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentagePopulationVaccinated