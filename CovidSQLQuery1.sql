select *
from portfolio_project1..['covid-deaths']
order by 3,4

--select *
--from portfolio_project1..['covid-vaccinations']
--order by 3,4

-- selecting data we need
select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project1..['covid-deaths']
order by 1,2

-- looking at the total cases vs total deaths
-- shows the likelyhood of dying if you contract covid in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolio_project1..['covid-deaths']
where location like '%india%'
order by 1,2

--Looking at total cases vs population
--shows what percentage population got covid
select location, date, total_cases, population, (total_cases/population)*100 as covidAffectedPercentage
from portfolio_project1..['covid-deaths']
--where location like '%india%'
order by 1,2

--looking at countries with highest infection rate
select location, population, MAX(total_cases) as highestInfectionRAte
from portfolio_project1..['covid-deaths']
--where location like '%india%'
group by location, population
order by 1,2

select location, MAX(total_deaths) as totalDeathCount
from portfolio_project1..['covid-deaths']
--where location like '%india%'
where continent is not null
group by location
order by totalDeathCount desc

-- global numbers

select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
from portfolio_project1..['covid-deaths']
where continent is not null
--group by date
order by 1,2


-- LOOKING AT TOTAL POPULATION VS TOTAL VACCINATION

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeople
From portfolio_project1..['covid-deaths'] dea
join portfolio_project1..['covid-vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with popuVsVacc (continent, location, date, population, New_vaccinations, RollingPeople)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeople
From portfolio_project1..['covid-deaths'] dea
join portfolio_project1..['covid-vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPEople/population)*100 as RollingPercent
from popuVsVacc


--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeople numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeople
From portfolio_project1..['covid-deaths'] dea
join portfolio_project1..['covid-vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeople/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeople
From portfolio_project1..['covid-deaths'] dea
join portfolio_project1..['covid-vaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


