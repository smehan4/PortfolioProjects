--Selecting the data that we need

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2


--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order By 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, total_cases, total_deaths, (total_cases/population)*100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Order By 1,2

--Looking at Countries with Highest Infection Rate compared to infection

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group By Location, population
Order By PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is NOT NULL
Group By Location
Order By TotalDeathCount desc


--Break things down by continent

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not NULL
Group By continent
Order By TotalDeathCount desc


--Showing the continents with the highest Death count per population

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not NULL
Group By continent
Order By TotalDeathCount desc



--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as bigint)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is NOT NULL
Group By date
Order By 1,2

--Total death cases and death rate in world

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as bigint)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is NOT NULL
Order By 1,2



--Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for lataer visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
-- ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated