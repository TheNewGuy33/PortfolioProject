
-- Covid 19 Data Exploration --

-- Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types --

select* 
from coviddeaths
where continent is not null
order by 3,4;

select* from covidvaccinations
order by 3,4;


-- Select data we are starting with --

select
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from coviddeaths
where continent is not null
order by 1,2;


-- Total Cases vs Population --
-- Likelihood of dying if contract covid in country --

select
	location,
	date,
	total_cases as Cases,
	total_deaths as Deaths,
	round((total_deaths/ total_cases) * 100,3) as DeathPercentage
from coviddeaths
where location like '%states%' and 
continent is not null;



-- total cases vs population --

select
	Location,
	Date,
	total_cases as Cases,
	Population,
	round((total_cases / population) * 100,3) as DeathPercentage
from coviddeaths
where location like '%states%' and
continent is not null;




-- Countries with Highest Infection Rate compared to Population --

select
	Location,
	Population,
	max(total_cases) as HighestInfectionCount,
	round((max(total_cases) / population) * 100,3) as PercentagePopulationInfected
from coviddeaths
--where location like '%states%' and
--continent is not null
group by location, population
order by PercentagePopulationInfected desc;



-- Country with Highest Death Count per Population --

select
	Location,
	max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
--where location like '%states%' and
where continent is not null
group by location
order by TotalDeathCount desc;



-- LETS BREAK DOWN BY CONTINENT --	

-- SHOWING CONTINENT WITH HIGHEST DEATH COUNT--

select
	Continent,
	max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
--where location like '%states%' and
where continent is not null
group by continent
order by TotalDeathCount desc;


--GLOBAL NUMBERS --

select
	date,
	sum(new_cases) as total_cases,
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/ sum(new_cases) * 100 as DeathPercentage
from coviddeaths
where continent is not null 
group by date 
order by 1,2;



-- Total population vs vaccinations--
-- Percentage of Population that has received at least one Covid Vaccine --
select
	coviddeaths.continent,
	coviddeaths.location,
	coviddeaths.date,
	coviddeaths.population,
	covidvaccinations.new_vaccinations,
	sum(cast(new_vaccinations as int)) over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as RollingPeopleVaccinated,
from coviddeaths
join covidvaccinations
	on coviddeaths.location = covidvaccinations.location
	and coviddeaths.date = covidvaccinations.date
where
	coviddeaths.continent is not null
order by 2,3;



-- USE CTE to perform Calculation on Partition in previous query --

with popvsvac
	(continenct,
	location,
	date,
	population,
	new_vaccinations,
	RollingPeopleVaccinated)
as

(select
	coviddeaths.continent,
	coviddeaths.location,
	coviddeaths.date,
	coviddeaths.population,
	covidvaccinations.new_vaccinations,
	sum(cast(new_vaccinations as int)) over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as RollingPeopleVaccinated
from coviddeaths
join covidvaccinations
	on coviddeaths.location = covidvaccinations.location
	and coviddeaths.date = covidvaccinations.date
where
	coviddeaths.continent is not null)

select*,
(rollingpeoplevaccinated/ population) * 100 as 
from popvsvac;



-- Using Temp Table to perform Calculation on Partition by in previous query --

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
Continenct nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)


insert into #PercentPopulationVaccinated
select
	coviddeaths.continent,
	coviddeaths.location,
	coviddeaths.date,
	coviddeaths.population,
	covidvaccinations.new_vaccinations,
	sum(cast(new_vaccinations as int)) over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as RollingPeopleVaccinated
from coviddeaths
join covidvaccinations
	on coviddeaths.location = covidvaccinations.location
	and coviddeaths.date = covidvaccinations.date
--where coviddeaths.continent is not null

select*, (RollingPeopleVaccinated/ population) * 100
from #PercentPopulationVaccinated



-- Creating View to store data for visualizations --

Create view PercentPopulationVaccinated as
select
	coviddeaths.continent,
	coviddeaths.location,
	coviddeaths.date,
	coviddeaths.population,
	covidvaccinations.new_vaccinations,
	sum(cast(new_vaccinations as int)) over (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as RollingPeopleVaccinated
from coviddeaths
join covidvaccinations
	on coviddeaths.location = covidvaccinations.location
	and coviddeaths.date = covidvaccinations.date
where coviddeaths.continent is not null;

select * from PercentPopulationVaccinated;
