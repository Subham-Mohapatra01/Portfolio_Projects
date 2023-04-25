--select * from portfolioproject..CovidVaccinations
--order by 3,4 ;
select * from portfolioproject..CovidDeaths
where continent is not null
order by 3,4;

--Select data that we are going to be using

select location, date, total_cases,new_cases,total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2;

-- Total cases vs Total deaths(Percentage of people who are dieing)

select location, date, total_cases,total_deaths,Round(((total_deaths/total_cases)*100),4) AS Death_Percentage
from CovidDeaths
where location like '%NDIA' and  continent is not null
order by 1,2;


--Total Cases Vs Population( what percentage of population got into covid)
Select location,date,total_cases,population, ROUND((total_cases/population)*100,4) AS PercentPopulationInfected
from CovidDeaths
where location like '%NDIA'
order by 1,2;

--Looking at countries with highest infection rates compared to population
Select location,Population,MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((Total_cases/population)*100,4)) AS PercentPopulationInfected
from CovidDeaths
where continent is not null
Group by location,population
order by PercentPopulationInfected desc;

-- Showing countries with highest death counts per population
Select location,MAX(cast (total_deaths as INT)) AS TotalDeathCount, MAX(ROUND((total_deaths/population)*100,4)) AS PercentPopulationDeath
from CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc;

--Continent Data--
-- Showing continent with Highest death count per population
Select continent,MAX(cast (total_deaths as INT)) AS TotalDeathCount, MAX(ROUND((total_deaths/population)*100,4)) AS PercentPopulationDeath
from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

--Looking at countries with highest infection rates compared to population
Select continent,Population,MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((Total_cases/population)*100,4)) AS PercentPopulationInfected
from CovidDeaths
where continent is not null
Group by continent,population
order by PercentPopulationInfected desc;

--Total Cases Vs Population( what percentage of population got into covid)
Select continent,date,total_cases,population, ROUND((total_cases/population)*100,4) AS PercentPopulationInfected
from CovidDeaths
order by 2;


----GLOBAL NUMBERS ------

select SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2;

---Looking at total population vs Vaccinations

--USE CTE
with PopvsVac(Continent,Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated

from CovidDeaths cd
Join CovidVaccinations cv
ON cd.location=cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated

from CovidDeaths cd
Join CovidVaccinations cv
ON cd.location=cv.location
and cd.date = cv.date
--where cd.continent is not null
--order by 2,3;
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualization
Create view PercentPopulationVaccinated AS
Select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
Join CovidVaccinations cv
ON cd.location=cv.location
and cd.date = cv.date
where cd.continent is not null;


Select * from PercentPopulationVaccinated;