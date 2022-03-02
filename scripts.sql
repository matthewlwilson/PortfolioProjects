SELECT * 
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
ORDER BY 3,4;

--SELECT * 
--FROM PortfolioProject..covid_vaccinations$
--ORDER BY 3,4;

-- Select the Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..covid_deaths$
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Looking at Total cases vs Population
SELECT location, date, total_cases, Population, (total_cases/population) * 100 AS InfectionRate
FROM PortfolioProject..covid_deaths$
--WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Count compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionRate, MAX(total_cases/population) * 100 AS InfectionRate
FROM PortfolioProject..covid_deaths$
--WHERE location LIKE '%china%'
GROUP BY location, population
ORDER BY InfectionRate desc;

-- Showing Countries with Highest deathcount 
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

--Lets break things down by continent

--Showing the continents with the highest death count
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc;

--Global Numbers
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..covid_deaths$
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2 desc;

--Looking at total population vs vaccinations
-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeoplePopulated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths$ dea
JOIN PortfolioProject..covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 as PeopleVaccinated
FROM PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeoplePopulated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths$ dea
JOIN PortfolioProject..covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
Select *, (RollingPeopleVaccinated/population)*100 as PeopleVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated 
as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeoplePopulated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths$ dea
JOIN PortfolioProject..covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
