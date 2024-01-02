select top 5* 
from dbo.CovidDeaths$

select top 5*
from dbo.CovidVaccinations$

select *
from dbo.coviddeaths$
where continent is not null
order by 3,4

--select *
--from dbo.CovidVaccinations$
--order by 3,4 

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from dbo.CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country

--Need to change navarchar data type to number to get result, this query doesn't work
--select location, date, total_cases, total_deaths, 
--(total_deaths/total_cases)*100 as DeathPercentage
--from dbo.CovidDeaths$
--order by 1,2


select location, date, total_cases, total_deaths, CAST(total_deaths as decimal) / Nullif (CAST(total_cases as decimal), 0)*100 
as DeathPercentage
from dbo.CovidDeaths$
order by 1,2


SELECT location, date, total_cases, total_deaths, Nullif(CAST(total_deaths AS DECIMAL), 0) / Nullif(CAST(total_cases AS DECIMAL),0)* 100 AS DeathPercentage
FROM dbo.CovidDeaths$
where location like '%states%' 
order by 1, 2 

--Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

select location, date,  Population, total_cases, (total_cases/Population)* 100 
as PercentPopulationInfected
from dbo.CovidDeaths$
--where location like '%states%'
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population

select location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population))* 100 
as PercentPopulationInfected
from dbo.CovidDeaths$
--where location like '%states%'
group by location, population 
order by  PercentPopulationInfected desc 

--showing countries with Highest Death Count per population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by  TotalDeathCount desc 

--Let's break things down by Continet
--Showing continents with the highest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent 
order by TotalDeathCount desc 


--Global Numbers

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
nullif(cast(sum(new_deaths)AS decimal),0)/nullif(cast(sum(new_cases) as decimal),0)* 100 as DeathPercentage
FROM dbo.CovidDeaths$
--where location like '%states%' 
where continent is not null
--group by date
order by 1, 2 


--Looking at Total Population vs Vaccination


select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
Sum(isnull(convert(decimal,CV.new_vaccinations),0)) over (Partition by cd.location order by cd.location,
cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths$ CD
join dbo.CovidVaccinations$ CV
    on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
order by 2,3

--Use CTE


with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
Sum(isnull(convert(decimal,CV.new_vaccinations),0)) over (Partition by cd.location order by cd.location,
cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths$ CD
join dbo.CovidVaccinations$ CV
    on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac
order by Location, Date; 

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
Sum(isnull(convert(decimal,CV.new_vaccinations),0)) over (Partition by cd.location order by cd.location,
cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths$ CD
join dbo.CovidVaccinations$ CV
    on CD.location = CV.location
	and CD.date = CV.date
--where CD.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
Sum(isnull(convert(decimal,CV.new_vaccinations),0)) over (Partition by cd.location order by cd.location,
cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths$ CD
join dbo.CovidVaccinations$ CV
    on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
--order by 2,3

select* 
from dbo.PercentPopulationVaccinated
