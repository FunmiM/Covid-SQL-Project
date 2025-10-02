select * from [dbo].[CovidDeaths]
where continent is not null
order by 3,4

select * from [dbo].[CovidVaccinationn]
order by 3,4

-- select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Looking at the Total_Cases vs Total Deaths
--Likelihood of dying if you contract Covid in your Country
select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like 'Nigeria'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 
as PercentPopulationInfected
from CovidDeaths
--where location like 'Nigeria'
group by Location, population
order by PercentPopulationInfected desc

--Showing Countries with highest Death Count per population

select Location, max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like 'Nigeria'
where continent is not null
group by Location, population
order by TotalDeathCount desc

--Showing the breakdown by Continent


--Showing the continent with the highest deathcount per population

select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths
--where location like 'Nigeria'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like 'Nigeria'
where continent is not null
--group by date
order by 1,2


--Location at Total Population vs Vaccinations
--Using CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations,  RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac




--TEMP Table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Looking at Total Populations vs Vaccinations

--Create View to store Data for later Visualizations


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated

Select location, sum(new_deaths) as TotalDeathCount
from CovidDeaths
where continent is null
and location not in ('world','European Union','International')
group by location
order by TotalDeathCount desc


select Location, population, date, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 
as PercentPopulationInfected
from CovidDeaths
--where location like 'Nigeria'
group by Location, population, date
order by PercentPopulationInfected desc