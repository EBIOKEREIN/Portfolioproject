EXEC sp_help 'vaccinations'
ALTER TABLE vaccinations
ALTER COLUMN new_vaccinations INT




SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Coviddeaths
ORDER BY 1,2


---Looking at total cases vs total deaths(this point shows the likelihood of dying if you contact covid in your country)
SELECT Location,Date,population,total_cases, (total_cases/population )*100 AS Death_Percentage
FROM Coviddeaths
ORDER BY Death_Percentage DESC

---Looking at countries with the highest infection rate compared to poppulation
SELECT location,MAX(total_cases) AS Highest_infection_rate,Population,(MAX(total_cases)/population)*100 AS CTP_RATE
FROM Coviddeaths
GROUP BY location,population
ORDER BY CTP_RATE DESC

---Showing Countries with Highest Death Count Per Population
SELECT location,MAX(cast(total_deaths as int)) AS Highest_death_count
FROM Coviddeaths
WHERE continent IS not NULL
GROUP BY location
ORDER BY Highest_death_count DESC

---Showing Continents with highest death count per population
SELECT continent,MAX(cast(total_deaths as int)) AS Highest_death_count
FROM Coviddeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY Highest_death_count DESC

---In terms of Global Numbers
SELECT SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 AS Global_Death_Percentage
FROM Coviddeaths
WHERE continent is not null
order by 1,2


---Total Population vs Vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,MAX(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
AS Rolling_People_Vaccinated
FROM Coviddeaths dea 
JOIN Vaccinations vac
   ON dea.location=vac.location
   AND dea.date=vac.date
where dea.continent is not null
ORDER BY 2,3 DESC



---CTE
with POPvsVAC (continent,location,date,population,new_vaccinations,Rolling_People_Vaccinated)
as
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
AS Rolling_People_Vaccinated
FROM Coviddeaths dea 
JOIN Vaccinations vac
   ON dea.location=vac.location
   AND dea.date=vac.date
where dea.continent is NOT null
----ORDER BY 2,3 
)

SELECT *,(Rolling_People_Vaccinated/Population)*100 AS RPV_vs_POP
FROM POPvsVAC




--TEMP TABLE

CREATE TABLE #PercentPopulationconfirmedVaccinations
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_Vaccinations bigint,
Rolling_People_Vaccinated bigint
)

INSERT INTO #PercentPopulationconfirmedVaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
AS Rolling_People_Vaccinated
FROM Coviddeaths dea 
JOIN Vaccinations vac
   ON dea.location=vac.location
   AND dea.date=vac.date
where dea.continent is NOT null
----ORDER BY 2,3 

SELECT *,(Rolling_People_Vaccinated/Population)*100 AS RPV_vs_POP
FROM #PercentPopulationconfirmedVaccinations


CREATE VIEW PercentPopulationconfirmedVaccinations AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
AS Rolling_People_Vaccinated
FROM Coviddeaths dea 
JOIN Vaccinations vac
   ON dea.location=vac.location
   AND dea.date=vac.date
where dea.continent is NOT null

CREATE VIEW Covid_deaths AS
SELECT location,MAX(total_cases) AS Highest_infection_rate,Population,(MAX(total_cases)/population)*100 AS CTP_RATE
FROM Coviddeaths
GROUP BY location,population
--ORDER BY CTP_RATE DESC

CREATE VIEW Covid_Deaths_2 AS
SELECT Location,Date,population,total_cases, (total_cases/population )*100 AS Death_Percentage
FROM Coviddeaths
--ORDER BY Death_Percentage DESC



