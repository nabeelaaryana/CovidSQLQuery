-- Queries to create tables for our Tableau Visuals --

-- Global Numbers --
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as float))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From [dbo].[CovidDeath]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Deaths Per Continent --
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeath]
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- Percent Population Infected Per Country --
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  
Max((cast(total_cases as float))/(cast(population as float)))*100 as PercentPopulationInfected
From [dbo].[CovidDeath]
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Percent Population Infected --
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  
Max((cast(total_cases as float))/(cast(population as float)))*100 as PercentPopulationInfected
From [dbo].[CovidDeath]
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc