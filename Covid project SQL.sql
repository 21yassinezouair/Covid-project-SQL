Select * 
from PortfolioProject..CovidDeaths
order by 3,4

Select * 
from PortfolioProject..Covidvaccination
order by 3,4

--We will select the data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths
order by 1,2

-- We're looking at Total cases vs Total Deaths, we will be looking for the percentage of death of people diagnosed by the virus
-- Ranking the DeathPercentage in Morocco in a descending way

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage  from PortfolioProject..CovidDeaths
Where location like '%Morocco%'
 where continent is not null
order by 5 desc

--Shows what percentage of population got covid (Incidence Rate) in Morocco


Select location,date, total_cases, population,(total_cases/population) as IncidenceRate  from PortfolioProject..CovidDeaths
Where location like '%Morocco%'
 where continent is not null
order by 1,2

--looking for countries with highest Incidence rate
Select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as IncidenceRate  from PortfolioProject..CovidDeaths
group by location,population
order by 4 desc

-- looking for countries with highest DeathPercentage
Select location,population, max(total_deaths/population)*100 as DeathPercentage  from PortfolioProject..CovidDeaths
group by location,population
order by 3 desc

-- looking for countries with highest DeathCount 
Select location, max(cast(total_deaths as int)) as totaldeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by totaldeaths desc

-- looking for continents with highest DeathCount
Select continent, max(cast(total_deaths as int)) as totaldeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeaths desc

--Global Numbers
Select sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DailyDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2,3

--Looking at Total Population vs Vaccinations

--USE CTE
With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,sum(convert(int,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..Covidvaccination vacc
on dea.location=vacc.location
and dea.date=vacc.date
where dea.continent is not null
--order by 1,2,3
)
select *,(RollingPeopleVaccinated/Population)*100 as VaccinatedPeoplepercentageperpopulation
from PopvsVac

--create view to store data for data visualization later
create view VaccinatedPeoplepercentageperpopulation as
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,sum(convert(int,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..Covidvaccination vacc
     on dea.location=vacc.location
     and dea.date=vacc.date
where dea.continent is not null
--order by 2,3






