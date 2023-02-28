--Covid-19 Data Exploration
--Techniques use: Joins, CTE's, Temp Tables, Windows Functions, Aggrerate Functions,Creating Views, Converting Data types

Select *
From PortfolioProjects..CovidDeaths$
where continent is not null
order by 3,4

--Selecting data that we are going to be starting with
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths$
where continent is not null
order by 1,2

--Total Cases Vs Total Deaths
--Shows likelihood of dying if you contact covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
where location like '%kingdom%'
and continent is not null
order by 1,2 

-- Query to retrive data for all location with Covid cases and death data
Select location, date, total_cases, total_deaths, population
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 1,2

--Query to retrive data for Bangadesh death percentage
Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as death_percentage
From PortfolioProjects..CovidDeaths$
where location = 'bangladesh'
order by 1,2

--Query to retrive data for countries with highest infection percentage
Select location, population, MAX(total_cases) as highest_infection, MAX(total_cases/population)*100 as infected_percentage
From PortfolioProjects..CovidDeaths$
where continent is not null
group by location, population
order by infected_percentage

--Query to retrive data for locations with highest death count
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProjects..CovidDeaths$
where continent is not null
group by location
order by total_death_count desc

--Query to retrive data for global death rate
Select date, SUM(new_cases) as cases_per_day, SUM(cast(new_deaths as int)) as death_per_day, round((SUM(cast(new_deaths as int))/sum(new_cases))*100,2) as death_percentage_day
from PortfolioProjects..CovidDeaths$
where continent is not null
group by date
order by 1, 2

--Query to retrive data for total death and covid cases overall
Select SUM(new_cases) as cases_per_day, SUM(cast(new_deaths as int)) as death_per_day, round((SUM(cast(new_deaths as int))/sum(new_cases))*100,2) as death_percentage_day
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 1, 2

--Total population Vs Vaccination
--Query to retrieve data for population with at least one vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingVaccinatedCount
From  PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform Calculation on partition By in previous query
 With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, rollingVaccineCount)
 as
 (Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as rollingVaccinatedCount
 From PortfolioProjects..CovidDeaths$ dea
 Join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (rollingVaccineCount/population)*100
from PopVsVac

--Using Temp Table to perform calculation on partition by in prev query
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225)
Location nvarchar(225)
Date datetime,
Population numeric
New_vaccinations numeric
RollingVaccineCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as rollingVaccinatedCount
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

Select * , (rollingVaccineCount/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccined
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
