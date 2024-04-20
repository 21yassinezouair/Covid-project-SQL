-- 1. 
-- This script calculates the total number of new cases, the total number of new deaths, and the percentage of deaths relative to new cases in the CovidDeaths dataset.
Select 
    SUM(new_cases) as total_cases, -- Total new cases
    SUM(cast(new_deaths as int)) as total_deaths, -- Total new deaths
    SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage -- Death percentage relative to new cases
From PortfolioProject..CovidDeaths
--Where location like '%states%' -- Filter by state if needed
where continent is not null -- Filter records where continent is not null
--Group By date -- Optional: group by date if needed
order by 1,2 -- Sort the results by the first and second column

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

-- This query calculates the total number of deaths for each location in the CovidDeaths dataset where the continent is null and the location is not 'World', 'European Union', or 'International'.

Select 
    location, -- Location
    SUM(cast(new_deaths as int)) as TotalDeathCount -- Total death count
From PortfolioProject..CovidDeaths
--Where location like '%states%' -- Filter by states if needed
Where continent is null -- Filter records where continent is null
and location not in ('World', 'European Union', 'International') -- Exclude specific locations
Group by location -- Group the results by location
order by TotalDeathCount desc -- Order the results by total death count in descending order



-- 3.

-- This query calculates the highest infection count and the percentage of population infected for each location in the CovidDeaths dataset.

Select 
    Location, -- Location
    Population, -- Population
    MAX(total_cases) as HighestInfectionCount, -- Highest infection count
    Max((total_cases/population))*100 as PercentPopulationInfected -- Percentage of population infected
From PortfolioProject..CovidDeaths
--Where location like '%states%' -- Filter by states if needed
Group by Location, Population -- Group the results by location and population
order by PercentPopulationInfected desc -- Order the results by percentage of population infected in descending order


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc












-- 1.

-- This query selects the continent, location, date, and population from the CovidDeaths table, and calculates the rolling total number of vaccinated people for each location and date from the CovidVaccinations table.

Select 
    dea.continent, -- Continent
    dea.location, -- Location
    dea.date, -- Date
    dea.population, -- Population
    MAX(vac.total_vaccinations) as RollingPeopleVaccinated -- Rolling total number of vaccinated people
--, (RollingPeopleVaccinated/population)*100 -- Percentage of population vaccinated (commented out for now)
From 
    PortfolioProject..CovidDeaths dea
Join 
    PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where 
    dea.continent is not null -- Exclude records where continent is null
group by 
    dea.continent, dea.location, dea.date, dea.population -- Group by continent, location, date, and population
order by 
    1,2,3 -- Order the results by continent, location, and date




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


-- This Common Table Expression (CTE) calculates the rolling total number of vaccinated people for each location and date, along with other relevant information.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
    Select 
        dea.continent, -- Continent
        dea.location, -- Location
        dea.date, -- Date
        dea.population, -- Population
        vac.new_vaccinations, -- New vaccinations
        SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated -- Rolling total number of vaccinated people
    -- , (RollingPeopleVaccinated/population)*100 -- Percentage of population vaccinated (commented out for now)
    From 
        PortfolioProject..CovidDeaths dea
    Join 
        PortfolioProject..CovidVaccinations vac
        On dea.location = vac.location
        and dea.date = vac.date
    where 
        dea.continent is not null -- Exclude records where continent is null
    -- order by 2,3 -- Ordering not necessary for the CTE
)
-- This query calculates the percentage of population vaccinated for each location and date.
Select 
    *, 
    (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated -- Percentage of population vaccinated
From 
    PopvsVac



-- 7. 

-- This query selects the location, population, date, highest infection count, and percentage of population infected for each location and date from the CovidDeaths table.

Select 
    Location, -- Location
    Population, -- Population
    date, -- Date
    MAX(total_cases) as HighestInfectionCount, -- Highest infection count
    Max((total_cases/population))*100 as PercentPopulationInfected -- Percentage of population infected
From 
    PortfolioProject..CovidDeaths
--Where location like '%states%' -- Filter by states if needed
Group by 
    Location, 
    Population, 
    date -- Group by location, population, and date
order by 
    PercentPopulationInfected desc -- Order the results by percentage of population infected in descending order


