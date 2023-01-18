Select *
From PortfolioProject..coviddeaths$
Where continent is not NULL
order by 3,4

--Select *
--From PortfolioProject..covidvaccinations$
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population_density
From PortfolioProject..coviddeaths$
Where continent is not NULL
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if Covid contracted in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..coviddeaths$
Where continent is not NULL
Where location like '%states%'
order by 1,2


-- Lookng at Total cases vs Population Density
-- Shows what percentage of population got Covid
Select Location, date, Population_density, total_cases, (total_cases/population_density)*100 as PercentagePopulationInfected
From PortfolioProject..coviddeaths$
Where location like '%states%'
Where continent is not NULL
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population Density

Select Location, Population_density, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population_density))*100 as PercentagePopulationInfected
From PortfolioProject..coviddeaths$
-- Where location like '%states%'
Where continent is not NULL
Group by Location, Population_density
order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths$
-- Where location like '%states%'
Where continent is not NULL
Group by Location
order by TotalDeathCount desc

-- Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..coviddeaths$
Where continent is not null
Group by date
order by 1,2

-- Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covidvaccinations$ vac
Join PortfolioProject..coviddeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covidvaccinations$ vac
Join PortfolioProject..coviddeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulatonVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulatonVaccinated
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covidvaccinations$ vac
Join PortfolioProject..coviddeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date

-- where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulatonVaccinated

-- Creating View to store data for later visualizations

Create View as PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covidvaccinations$ vac
Join PortfolioProject..coviddeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
