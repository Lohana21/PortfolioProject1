Select *
From PortfoiloProject..CovidDeaths$
Where continent is not null
order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfoiloProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract ccovid in your country 
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfoiloProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at the Total Cases vs Population 
-- Shows what percentage of population got covid 
Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
From PortfoiloProject..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at what country has the Highest Infection Rate compared to population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
From PortfoiloProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentagePopulationInfected desc

-- Showing the countries with the Highest Dedath COunt per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfoiloProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfoiloProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfoiloProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- New table COVID VACCINATIONS
Select *
From PortfoiloProject..CovidVaccinations 

-- Join tables 
Select *
From PortfoiloProject..CovidDeaths dea
Join PortfoiloProject..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfoiloProject..CovidDeaths dea
Join PortfoiloProject..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Adding the running total 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningVaccinationTotal
From PortfoiloProject..CovidDeaths dea
Join PortfoiloProject..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Showing how many people in the country are vaccinated 
-- using CTE 
With PopvsVac (Continent, location, date, population, new_vaccinations, RunningVaccinationTotal)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningVaccinationTotal
From PortfoiloProject..CovidDeaths dea
Join PortfoiloProject..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RunningVaccinationTotal/Population)*100 as RollingPercentageVaccinated
From PopvsVac

-- Temp Table

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RunningVaccinationTotal numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningVaccinationTotal
From PortfoiloProject..CovidDeaths dea
Join PortfoiloProject..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RunningVaccinationTotal/Population)*100 as RollingPercentageVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RunningVaccinationTotal
From PortfoiloProject..CovidDeaths dea
Join PortfoiloProject..CovidVaccinations vac
    on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- Which created this view:
Select*
From PercentPopulationVaccinated