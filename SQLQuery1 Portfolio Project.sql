SELECT location, date,total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--SELECT *
--FROM CovidDeaths

SELECT location, date,total_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Percentage of Total deaths per total cases
SELECT location, date,total_cases,total_deaths, total_deaths / total_cases * 100 AS Perc
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--TOTAL CASES VS POPULATION in %
SELECT location, date,total_cases,population, total_cases / population * 100 AS PercentageOfTotalCases
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--Coubtry with the highest infection rate
SELECT location,population, MAX(total_cases) AS HighestInfectedArea,MAX(total_cases / population) * 100 AS PercentageOfTotalCases 
FROM CovidDeaths
GROUP BY location,population
ORDER BY PercentageOfTotalCases DESC

--Countries with the highest death count per population
SELECT location, population, MAX(CAST(total_deaths as int)) AS HighestNoOfDeaths
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location,population
ORDER By HighestNoOfDeaths DESC

--BREAKING DOWN THINGS BY CONTINENT
SELECT continent, MAX(CAST(total_deaths as int)) AS HighestNoOfDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER By HighestNoOfDeaths DESC

--Showing the continent with highest death count
SELECT continent, MAX(CAST(total_deaths as int)) AS HIGHESTDEATHS
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  HIGHESTDEATHS ASC

--Global Numbers
SELECT  date,SUM(new_cases) AS NewCasesSum, SUM(CAST(new_deaths as int)) AS NewDeathsSum,SUM(CAST(new_deaths AS int))/SUM(new_cases ) * 100 AS Perc
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--VACCINATION TABLE
SELECT*
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date

--Looking at Total population VS Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingCountPplVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CTE

WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingCountPplVaccinated) 
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingCountPplVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3)
)
SELECT *, (RollingCountPplVaccinated/population)*100
FROM PopvsVac

--TEMP_TABLE

CREATE TABLE #temp_PercentPopulationVaccinated(
continent VARCHAR(255),
location VARCHAR(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountPplVaccinated numeric
)


INSERT INTO #temp_PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingCountPplVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3)

SELECT *, (RollingCountPplVaccinated/population)*100
FROM #temp_PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingCountPplVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
