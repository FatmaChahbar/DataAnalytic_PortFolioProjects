-- Covid Death Table
Select *
From [Portfolio Project]..CovidDeaths
where continent is not null

-- Covid Vaccination Table
Select* 
From [Portfolio Project]..CovidVaccinations
where Continent is not null

Select location , date ,population  , new_cases,total_cases, total_deaths
From [Portfolio Project]..CovidDeaths
where Continent is not null
order by 1,2

-- Death Percentage (Total deaths vs total Cases)

Select location , date ,population  , new_cases,total_cases, total_deaths , (CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where Continent is not null
order by 1,2

--Percentage  of Population infected with covid

Select location , date ,population  , new_cases,total_cases, total_deaths , (CONVERT(float,total_cases)/CONVERT(float,population))*100 as PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths
where Continent is not null
order by 1,2

Select location ,population  , MAX(CONVERT(float,total_cases))as HighestInfection, Max((CONVERT(float,total_cases)/CONVERT(float,population)))*100 as HighestPercentagePopulationInfected
From [Portfolio Project]..CovidDeaths
where Continent is not null
Group by location,population
order by HighestInfection desc


-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as float)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Continent with highest death count
Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global calculation 
Select SUM(cast(new_cases as float)) as TotalCases,SUM(cast(new_deaths as float)) as TotalDeath,  (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as TotalDeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinatedPercentage
From PopvsVac
   
-- Create Temporary Table
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
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create View

Create View PercentVaccinatedView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Create View GlobalCalcul as 
Select SUM(cast(new_cases as float)) as TotalCases,SUM(cast(new_deaths as float)) as TotalDeath,  (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as TotalDeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null

-- For Testing
Select* 
From PercentVaccinatedView