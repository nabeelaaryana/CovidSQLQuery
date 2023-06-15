-- Select * 
-- From [dbo].[CovidDeaths]
-- Where continent is not null
-- Order by 3,4

-- Select * 
-- From [dbo].[CovidVaccincations]
-- Order by 3,4

-- Select Data that we are going to be using --
Select location, date, total_cases, new_cases, total_deaths, population_density
From [dbo].[CovidDeaths]
Order by 1,2

-- Looking at Total Cases vs Total Deaths --
-- Shows the likelihood of dying if you contract Covid from your country --
Select location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population --
-- Shows what percentage of population got Covid --
Select location, date, population_density, total_cases, (CAST(total_cases as float)/CAST(population_density as float))*100 as PercentPopulationInfected
From [dbo].[CovidDeaths]
Where location like '%states%'
Order by 1,2

-- Looking for Countries with Highest Infection Rate compared to Population --
Select location, population_density, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as float)/CAST(population_density as float)) as PercentPopulationInfected
From [dbo].[CovidDeaths]
--Where location like '%states%'
Group by location, population_density
Order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population --
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

---- Let's break things down by continent ----

-- Showing the Continents with the Highest Death Counts --
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers --
-- Using aggregate functions --
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
From [dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations --

Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date)
    as RollingPeopleVaccinated,
    (RollingPeopleVaccinated/population_density)*100
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE --

With PopvsVac (continent, location, date, population_density, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date)
    as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population_density) 
From PopvsVac

-- Temp Table --
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population_density numeric, 
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date)
    as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
 On dea.location = vac.location
 and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population_density) 
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations --

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date)
    as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

SELECT * from PercentPopulationVaccinated