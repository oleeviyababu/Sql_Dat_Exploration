Select *
From Portfolio1..CovidDeath
where continent is not null
order by 3,4

--Select *
--From Portfolio1..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From Portfolio1..CovidDeath
where continent is not null
order by 1,2

--Looking into Total Cases vs Total Deaths

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolio1..CovidDeath
where location like '%states%'
and continent is not null
order by 1,2

--Looking into Total Cases vs Population
--shows what percentage of people affected by covid


Select location,date,total_cases,population,(total_cases/population)*100 as AffectedPercentage
From Portfolio1..CovidDeath
--where location like '%states%'
where continent is not null
order by 1,2

--Looking at Countries having Highest Infection Rate compared to Population
Select location,population,MAX(total_cases) as HighestInfectionRate,MAX((total_cases/population))*100 as AffectedPercentage
From Portfolio1..CovidDeath
--where location like '%states%'
where continent is not null
Group by location,population
order by AffectedPercentage desc

--Looking at Countries having Highest Death Count per Population
Select location,MAX(cast(total_deaths as int)) as HighestDeathRate
From Portfolio1..CovidDeath
--where location like '%states%'
where continent is not null
Group by location
order by HighestDeathRate desc

--Breaking based on Continents

--Showing Continnents with Highest Death Counts


Select location,MAX(cast(total_deaths as int)) as HighestDeathRate
From Portfolio1..CovidDeath
--where location like '%states%'
where continent is null
Group by location
order by HighestDeathRate desc


--Global Numbers

Select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as AffectedPercentage
From Portfolio1..CovidDeath
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

--Global Death Rate

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as AffectedPercentage
From Portfolio1..CovidDeath
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--Joining two tables

Select *
From Portfolio1..CovidDeath dea
join Portfolio1..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--Looking up Total Population vs New Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated
From Portfolio1..CovidDeath dea
join Portfolio1..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as(

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated
From Portfolio1..CovidDeath dea
join Portfolio1..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(rollingpeoplevaccinated/population)*100
From popvsvac

--TEMP TABLE
Drop Table if exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


Insert into #Percentpopulationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated
From Portfolio1..CovidDeath dea
join Portfolio1..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

--Percentage of people vaccinated per population

Select *,(rollingpeoplevaccinated/population)*100
From #Percentpopulationvaccinated

--Create View to Store Data  for Viaualizations

Create View Percentpopulationvaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated
From Portfolio1..CovidDeath dea
join Portfolio1..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


select *
from Percentpopulationvaccinated



















