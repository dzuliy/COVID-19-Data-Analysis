Select *
From PortfolioProjectNewData..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are doing to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectNewData..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- shows likelohood of dying if you contract in your country 

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProjectNewData..CovidDeaths
where continent is not null and location like '%Finland%'
order by 1,2

-- looking at total cases vs population
-- shows what precentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as procentpopulationinfected
From PortfolioProjectNewData..CovidDeaths
where continent is not null and location like '%Finland%'
order by 1,2


-- looking at counties with higest infection rate compared to population 

Select location, population, MAX(total_cases) as highestinfectioncount, MAX(total_cases)/population*100 as procentpopulationinfected
From PortfolioProjectNewData..CovidDeaths
--Where location like '%Finland%' 
Where continent is not null
group by location, population
order by procentpopulationinfected desc

--showing Countries with highest deat count per population 

Select location, MAX(cast(total_deaths as int)) as totaldeathscount
From PortfolioProjectNewData..CovidDeaths
--Where location like '%states%'
where continent is not null
group by location
order by totaldeathscount desc

-- looking at counties with higest infection rate compared to population and countries with highest deat rate per population 

Select location, population, MAX(total_cases) as highestinfectioncount, MAX(total_cases)/population*100 as procentpopulationinfected, MAX(cast(total_deaths as int)) as totaldeathscount,  MAX(cast(total_deaths as int))/population*100 as procentpopulationdeaths
From PortfolioProjectNewData..CovidDeaths
--Where location like '%Finland%' 
Where continent is not null
group by location, population
order by procentpopulationdeaths desc

--lets break things down by location

Select location, MAX(cast(total_deaths as int)) as totaldeathscount
From PortfolioProjectNewData..CovidDeaths
--Where location like '%states%'
where continent is null and location not like '%income%'
group by location
order by totaldeathscount desc


Select location, MAX(cast(total_deaths as int)) as totaldeathscount
From PortfolioProjectNewData..CovidDeaths
--Where location like '%states%'
where continent is null and location not in ('World', 'European Union')and location not like '%income%'
group by location
order by totaldeathscount desc

--lets break things down by  location (income)

Select location, MAX(cast(total_deaths as int)) as totaldeathscount
From PortfolioProjectNewData..CovidDeaths
--Where location like '%states%'
where continent is null and location like '%income%'
group by location
order by totaldeathscount desc

--lets break things down by continent
--showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as totaldeathscount
From PortfolioProjectNewData..CovidDeaths
--Where location like '%states%'
where continent is not null
group by continent
order by totaldeathscount desc

 --global numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(New_cases) *100 as deathprecentage -- , total_deaths, (total_deaths/total_cases)*100 as deathprecentage
From PortfolioProjectNewData..CovidDeaths
-- Where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

Select *
From PortfolioProjectNewData..CovidDeaths cd
Join PortfolioProjectNewData..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date


Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition by cd.location
    Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVcactinated --(cv.new_vaccinations/RollingPeopleVcactinated)*100 as PercentageIncreaseInTheNumberofVaccinated 

From PortfolioProjectNewData..CovidDeaths cd
Join PortfolioProjectNewData..CovidVaccinations cv
    on cd.location = cv.location
    and cd.date = cv.date
where cd.continent is not null
and cv.new_vaccinations is not null
order by 2,3


-- USE CTE 

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVcactinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition by cd.location
    Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVcactinated
From PortfolioProjectNewData..CovidDeaths cd
Join PortfolioProjectNewData..CovidVaccinations cv
    on cd.location = cv.location
    and cd.date = cv.date
where cd.continent is not null
and cv.new_vaccinations is not null 
-- order by 2,3
)
select *, (RollingPeopleVcactinated/population)*100 as PercentagePeopleVaccinated

from PopvsVac

-- temp table


Create table PerPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vacctinations numeric,
RollingPeoplevaccinated numeric
)

Insert into PerPopulationVaccinated

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as bigint)) OVER (Partition by cd.location Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING) as RollingPeoplevaccinated
From PortfolioProjectNewData..CovidDeaths cd
Join PortfolioProjectNewData..CovidVaccinations cv
    on cd.location = cv.location
    and cd.date = cv.date
where cd.continent is not null 

select *, (RollingPeoplevaccinated/population)*100 as perPeoplevaccinated
from PerPopulationVaccinated

Select *
From PortfolioProjectNewData..CovidVaccinations
where continent is not null
order by 3,4

Select Location, Population, date, Max(total_cases) as HighstInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjectNewData..CovidDeaths
Group by location, Population, date
order by PercentPopulationInfected desc