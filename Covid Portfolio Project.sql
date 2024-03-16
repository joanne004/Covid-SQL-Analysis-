Select*
From PortfolioProject01..CovidDeaths
where continent is not null
order by 3,4 /* Order by the 3rd and then the 4th column*/

--Select*
--From PortfolioProject01..CovidVaccinations
--order by 3,4/* Order by the 3rd and then the 4th column*/

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject01..CovidDeaths
where continent is not null
order by 1, 2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject01..CovidDeaths
where continent is not null
and location like '%states%'
order by 1, 2


-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
Select Location, date, total_cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject01..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject01..CovidDeaths
where continent is not null
Group by Location, Population
ORDER BY PercentPopulationInfected desc 


-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject01..CovidDeaths
where continent is not null
GROUP BY Location
order by HighestDeathCount desc

Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject01..CovidDeaths
where continent is null
GROUP BY location
order by HighestDeathCount desc


-- Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject01..CovidDeaths
where continent is not null
GROUP BY continent
order by HighestDeathCount desc


-- Global Numbers by date
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject01..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
order by 1, 2

--Overall Global Numbers
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject01..CovidDeaths
--Where location like '%states%'
where continent is not null
order by 1, 2


-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int))OVER(Partition by dea.Location Order by dea.location, dea.Date) as Rolling PeopleVaccinated,

From PortfolioProject01..CovidDeaths dea
Join PortfolioProject01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2, 3



--USE CTE 

With PopulationVSvaccination(Continent,Location,Date,Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations))OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject01..CovidDeaths dea
Join PortfolioProject01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3
	)

Select*, (RollingPeopleVaccinated/Population)*100
From PopulationVSvaccination


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations))OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject01..CovidDeaths dea
Join PortfolioProject01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations))OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject01..CovidDeaths dea
Join PortfolioProject01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3

Select*
From PercentPopulationVaccinated