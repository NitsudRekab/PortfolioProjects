SELECT *	
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *	
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases VS Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking At Countries with Highest Infection Rate compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Group by population, location
ORDER BY InfectedPercentage desc

--Showing Countires with the Highest Death Count per Population

SELECT Location, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
Group by Location
ORDER BY TotalDeathCount desc

--Breaking down by Continent

--Showing Continents with the highest death count per populaton

SELECT continent, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group by continent
ORDER BY TotalDeathCount desc


--Global Numbers

SELECT  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total Population VS Total Vacination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  ORDER BY 2,3

  -- Using a CTE

  WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
  as
  (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  --ORDER BY 2,3
  )
  Select *, (RollingPeopleVaccinated/Population)*100
  From PopvsVac

--Using a Temp Table

DROP Table if exists #PercentPeopleVaccinated
Create Table  #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location  nvarchar (255),
Date time,
population numeric,
new_vavvinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  --ORDER BY 2,3
   Select *, (RollingPeopleVaccinated/Population)*100
  From #PercentPeopleVaccinated


-- Creating View to store data for later Visualizations
CREATE View PercentPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
 WHERE dea.continent is not null
 --ORDER BY 2,3

 Select *
 From PercentPeopleVaccinated