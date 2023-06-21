

SELECT *
FROM CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT*
--FROM CovidVaccinations
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IIF YOU CONTRACT

-- Assuming the current data type is NVARCHAR, change it to INT
ALTER TABLE CovidDeaths
ALTER COLUMN total_cases INT;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths INT;


SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE LOCATION LIKE '%STATES%'
ORDER BY 1,2

--looking at the total cases vs population
--shows what population has got covid

SELECT location,date,total_cases,Population, (total_cases/Population)*100 as Percentagepopulationinfected
FROM CovidDeaths
where continent is not null
and LOCATION LIKE '%STATES%'
ORDER BY 1,2


--looking at countries with highest infection raate compared to population

SELECT location , Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentpopulationInfected
FROM CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
where continent is not null
GROUP BY location,population
ORDER BY PercentpopulationInfected desc


--Showing Countries with Highest Death Count per Population

SELECT location ,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--LETS BREAK THIS DOWN BY CONTINENT


SELECT continent ,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

---Showing continents with highest Death Count

SELECT date ,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT
  date,
  SUM(new_cases) AS total_cases,
  SUM(cast(new_deaths as int)) as total_deaths,
  CASE
    WHEN SUM(new_cases) = 0 THEN NULL
    ELSE (SUM(cast(new_deaths as int)) / NULLIF(SUM(new_cases), 0)) * 100
  END AS DeathPercentage
FROM
  CovidDeaths
WHERE
  continent IS NOT NULL
GROUP BY
  date
ORDER BY
  1, 2;


 --Looking at Total Population vs Vacinations

 SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVacctinated
 , (RollingPeopleVacctinated/population)*100
 FROM CovidDeaths as dea
 JOIN CovidVaccinations as vac
	ON dea.location= vac.location
	and dea.date=vac.date
WHERE dea.continent is NOT NULL
	ORDER BY 2,3




--USE CTE

WITH PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
 FROM CovidDeaths as dea
 JOIN CovidVaccinations as vac
	ON dea.location= vac.location
	and dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--TEMP TABLES
DROP TABLE IF EXISTS #PecentagePeopleVaccinated
CREATE TABLE #PecentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PecentagePeopleVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
 FROM CovidDeaths as dea
 JOIN CovidVaccinations as vac
	ON dea.location= vac.location
	and dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PecentagePeopleVaccinated


--CREATING VIEW TO SHOW DATA FOR LATER VISUALIZATIONS


CREATE VIEW PecentagePeopleVaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
  --(RollingPeopleVaccinated/population)*100
 FROM CovidDeaths as dea
 JOIN CovidVaccinations as vac
	ON dea.location= vac.location
	and dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3


