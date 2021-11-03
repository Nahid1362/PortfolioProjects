select *
From PortfolioProject..CovidDeaths
--WHERE continent is not NULL
Order By 3,4

--select *
--From PortfolioProject..CovidVacinations
--Order By 3,4


-- Select the Data that we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Order By 1,2

-- Looking at Total Cases vs Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Canada%' AND continent is not NULL
Order By 1,2

--Looking at Total Cases vs Population
--shows what percentage of the population got Covid
select Location, date, total_cases, population, (total_cases/ population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%Canada%' AND continent is not NULL
Order By 1,2

--Looking at Countries whit Highest Infection Rate Compared to population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By Location, population
Order By PercentPopulationInfected desc



--Showing Countries with Highest Death Per Population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group By Location
Order By TotalDeathCount desc

--Get the Total Number Of Deaths by Continent

select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL 
Group By Continent
Order By TotalDeathCount desc

--Global Number
select SUM(new_cases)as total_Cases,SUM(CAST(new_deaths as int))as total_Deaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Canada%' 
where continent is not NULL
--group by date
Order By 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- USE CTE(Common Table Expression)
WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations))
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentOfPeopleVaccinated
from PopVsVac


-- TEMP Table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentOfPeopleVaccinated
FROM #PercentPopulationVaccinated



--  Creating View to store data for later visualizations

Use PortfolioProject --Select the DataBase that we are going to create view there 

Drop View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations))
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 

Select * 
from PercentPopulationVaccinated