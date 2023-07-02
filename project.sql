--------------------------------------------------select data we are going to use
select *
from [Portfolio project].dbo.CovidDeaths
order by 3,4
---------
select *
from [Portfolio project].dbo.CovidVaccinations
order by 3,4
------------------------------------------------------
select location ,date , total_cases, new_cases , total_deaths,population
from [Portfolio project]..CovidDeaths
order by 1,2
---------------------------------
-----Total Cases Vs Total deaths:likelihood of deaths against total no of cases
select location ,date , total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from [Portfolio project]..CovidDeaths
where location ='United States' and continent is not null
order by 1,2
--------------------------
-------------Total cases vs population
select location ,date , total_cases, population,(total_cases/population)*100 as Cases_percentage
from [Portfolio project]..CovidDeaths
where location ='United States' and  continent is not null
order by 1,2
-----------------------------------------
-----countries with highest infection rate based on their total population
select location ,population , max(total_cases) as Highest_Infection_count ,max((total_cases/population)*100) as Cases_percentage
from [Portfolio project]..CovidDeaths
where continent is not null
group by location ,population
order by Cases_percentage desc
------------------------------------------
-------- Continents with highest death count 
select continent , max(cast(total_deaths as int)) as Highest_Death_count 
from [Portfolio project]..CovidDeaths
where continent is not null
group by continent
order by Highest_Death_count desc
-------------------------------------------------
-----Daily new cases and new deaths administrated 
select date , sum(new_cases) as Total_new_cases , sum(cast(new_deaths as int)) as Total_new_deaths , (sum(cast(new_deaths as int))/sum(new_cases))*100 as new_deaths_percentage
from [Portfolio project]..CovidDeaths
where continent is not null
group by date
order by 1,2
--------------------------------------
----Across the world total new cases , total deaths 
select  sum(new_cases) as Total_new_cases , sum(cast(new_deaths as int)) as Total_new_deaths , (sum(cast(new_deaths as int))/sum(new_cases))*100 as new_deaths_percentage
from [Portfolio project]..CovidDeaths
where continent is not null
order by 1,2
-----------------------------
----Total population vs vaccinations
select cd.continent , cd.location ,cd.date,cd.population, cv.new_vaccinations
from [Portfolio project]..CovidDeaths cd
join [Portfolio project]..CovidVaccinations cv
on cd.location=cv.location and
cd.date=cv.date
where cd.continent is not null
order by 2,3
-------------------------------------------------------------------------
------Total no of vaccinations based on location ( Aggregated sum )
select cd.continent , cd.location ,cd.date,cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location ,cd.date) as Rolling_people_vaccinated
from [Portfolio project]..CovidDeaths cd
join [Portfolio project]..CovidVaccinations cv
on cd.location=cv.location and
cd.date=cv.date
where cd.continent is not null
order by 2,3
------------------------------------
-----Percentage of people vaccinated to the total population
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio project]..CovidDeaths dea
Join [Portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Vaccinated_percentage
From PopvsVac
--------------------------------------------------------------------------------
---another way to find percentage is by creating new table 
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio project]..CovidDeaths dea
Join [Portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as vaccinated_percentage
From #PercentPopulationVaccinated

-------------------------------
-------------------Creating view
GO
CREATE VIEW  PercentPopulationVaccinated 
AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From [Portfolio project]..CovidDeaths dea
Join [Portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * from PercentPopulationVaccinated