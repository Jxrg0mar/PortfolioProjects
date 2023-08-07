Select *
From PortfolioProject..COVIDDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..COVIDVaccination
--order by 3,4

--Select Data

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..COVIDDeaths
Where continent is not null
order by 1,2

----looking at total cases vs total deaths
---- shows likelihood of dying in Ecuador
Select Location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..COVIDDeaths
Where location  like '%ecuador%'
and continent is not null
order by 1,2

select *
from COVIDDeaths

exec sp_help 'COVIDDeaths';
ALTER TABLE COVIDDeaths
ALTER COLUMN total_deaths FLOAT


--Looking at total cases vs population
-- shows what percentage of population got COVID 

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..COVIDDeaths
Where location  like '%ecuador%'
order by 1,2


---Looking at countries with highest Infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..COVIDDeaths
--Where location  like '%ecuador%'
group by Location, population
order by PercentPopulationInfected desc

-- Showing Countries with the highest death count per population

Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..COVIDDeaths
--Where location  like '%ecuador%'
Where continent is not null
group by Location
order by TotalDeathCount desc


-- Let's break it down by continent


--Showing the continents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..COVIDDeaths
--Where location  like '%ecuador%'
Where continent is not null
group by continent
order by TotalDeathCount desc
 

 --Global numbers

Select  SUM(new_cases)as total_cases, SUM(new_deaths)as total_deaths, SUM(new_deaths)/nullif(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject..COVIDDeaths
--Where location  like '%ecuador%'
where continent is not null
--group by date 
order by 1,2

-- Looking at Total Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,	
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
From PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated


Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,	
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
From PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store Data



Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,	
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
From PortfolioProject..COVIDDeaths dea
Join PortfolioProject..COVIDVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated