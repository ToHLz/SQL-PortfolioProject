SELECT *
FROM PortfolioProject..CovidDeaths2
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths2
order by 1,2



--EXPLORATORY ANALYSIS

-- We are going to look at Total Cases vs Total Deaths in various countries of the world. It also shows the probability of dying if you catch the virus at different dates.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths2
Where location like '%Africa%'
order by 1,2

--Now we are going to look at the Total cases vs Population of different countries of the world
--Shows what percentage of population has gotten Covid
--We could see that from 2020 when covid started, till date, that the number of cases recorded with proportion to its population, is not even up to 1%
Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths2
--Where location like '%Africa%'
order by 1,2

-- Now we are going to look at countries with the highest infection rate compared to their population in descending order i.e highest to lowest
Select location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 as MaximumInfectedPopulationPercentage
From PortfolioProject..CovidDeaths2
--Where location like '%Africa%'
Group by location, population
order by MaximumInfectedPopulationPercentage desc


--Now we are going to look at countries with the highest death count per population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount    --the Total_death column in the dataset was not an integer so when we used the data like that without casting it, it gave us a wrong result, so we had to cast it to integer, for us to be able to use it in our analysis
From PortfolioProject..CovidDeaths2
--Where location like '%Africa%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--lET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount    
From PortfolioProject..CovidDeaths2
--Where location like '%Africa%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as GlobalNumbers, SUM(cast(new_deaths as int)) as GlobalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths2
--Where location like '%Africa%'
where continent is not null
Group by date
order by 1,2


-- here, we joined Deaths with vaccinations to work with them
Select *
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date

--looking at the Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

 -- Partitioning by location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location)
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--OR-- it can either work as the query above, or the query below

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Amount of people that are vaccinated 
--Using city
With PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentageofPeopleVaccinated
From PopvsVac



-- CREATING A TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/population)*100 as PercentageofPeopleVaccinated
From #PercentPopulationVaccinated


--IN CASE YOU WANT TO CHANGE SOMETHING

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/population)*100 as PercentageofPeopleVaccinated
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths2 dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 


Select *
From PercentPopulationVaccinated
