SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4;

-- SELECT * 
-- FROM PortfolioProject..CovidVaccinations 
-- ORDER BY 3,4;

-- select data that we are going to be using 

SELECT 
  location,
  date,
  total_cases,
  new_cases, 
  total_deaths,
  population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2;

-- Looking at Total Case vs Total Deaths
-- Shows the likelihood of dying if you obtain covid in your country

SELECT 
  location,
  date,
  total_cases,
  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%United States%'
  and continent is not null 
ORDER BY 1,2;

-- Creating View to store data for later visualizations

--drop view if exists TotalCasesvsTotalDeaths
CREATE VIEW TotalCasesvsTotalDeaths as
SELECT 
  location,
  date,
  total_cases,
  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%United States%'
  and continent is not null 
-- ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- shows what percentage of population got covid

SELECT 
  location,
  date,
  population,
  total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%United States%'
  and continent is not null 
ORDER BY 1,2;

-- Creating View to store data for later visualizations

--drop view if exists TotalCasesvsPopulationWithCovid
CREATE VIEW TotalCasesvsPopulationWithCovid as
SELECT 
  location,
  population,
MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%United States%'
WHERE continent is not null 
GROUP BY Population, Continent, Location
-- ORDER BY PercentPopulationInfected desc;

-- looking at Countries with Highest Infection Rate compared to Population

SELECT 
  location,
  population,
MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%United States%'
WHERE continent is not null 
GROUP BY Population, Continent, Location
ORDER BY PercentPopulationInfected desc;

-- Creating View to store data for later visualizations

--drop view if exists HighestInfectionRatevsPopulation
CREATE VIEW HighestInfectionRatevsPopulation as
SELECT 
  location,
  population,
MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%United States%'
WHERE continent is not null 
GROUP BY Population, Continent, Location
-- ORDER BY PercentPopulationInfected desc;

  -- Showing Countries with Highest Death Count per Population

SELECT 
  location,
MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%United States%'
WHERE continent is not null 
GROUP BY Continent, Location
ORDER BY TotalDeathCount desc;

-- Creating View to store data for later visualizations

--drop view if exists HighestDeathCountPerCountry
CREATE VIEW HighestDeathCountPerCountry as
SELECT 
  location,
MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%United States%'
WHERE continent is not null 
GROUP BY Continent, Location
-- ORDER BY TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

SELECT 
  continent,
MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%United States%'
WHERE continent is not null 
GROUP BY continent, Location
ORDER BY TotalDeathCount desc;

-- Creating View to store data for later visualizations

--drop view if exists HighestDeathCountPerContinent
CREATE VIEW HighestDeathCountPerContinent as
SELECT 
  continent,
MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%United States%'
WHERE continent is not null 
GROUP BY continent, Location
--ORDER BY TotalDeathCount desc;


-- GLOBAL NUMBERS

SELECT 
  SUM(new_cases) as total_case,
  SUM(cast(new_deaths as int)) as total_deaths, 
  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%United States%'
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations

SELECT 
 dea.continent, 
 dea.location, 
 dea.date, 
 dea.population, 
 vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
-- (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- Creating View to store data for later visualizations

--drop view if exists TotalPopvsVac
CREATE VIEW TotalPopulationvsVaccinations as
SELECT 
 dea.continent, 
 dea.location, 
 dea.date, 
 dea.population, 
 vac.new_vaccinations, 
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
-- (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
SELECT 
 dea.continent, 
 dea.location, 
 dea.date, 
 dea.population, 
 vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT*
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
SELECT 
 dea.continent, 
 dea.location, 
 dea.date, 
 dea.population, 
 vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

Use PortfolioProject;
go


-- Creating View to store data for later visualizations

--drop view if exists PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated as
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY 2,3

SELECT *
FROM TotalPopulationvsVaccinations