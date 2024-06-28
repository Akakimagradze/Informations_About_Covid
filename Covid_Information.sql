--                                          QUERIS FOR CovidDeaths


SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4 

-- What is the death rate on each day in 'Georgia' FROM 2020-02-26 TO 2021-04-30
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	population,
	(total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE 
	location = 'Georgia' AND
	continent IS NOT NULL
ORDER BY 1, 2
	

-- Shows what percentage of population got covid.
SELECT 
	location,
	date,
	population,
	total_cases,
	(total_cases/population) * 100 AS InfectedPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking for countries with highest infection rate compared to population
SELECT 
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases / population) * 100) AS InfectedPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY 
	location, 
	population
ORDER BY InfectedPercentage DESC

-- Looking for how many people died in each country totaly.
SELECT 
	location,
	MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY TotalDeathCount DESC 

-- Looking how many people died in each continent
SELECT 
	continent,
	MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global InfectedCases, Deaths, DeathPercentage
SELECT
	SUM(new_cases) AS Global_Infected,
	SUM(cast(new_deaths AS int)) AS Global_Deaths,
	SUM(cast(new_deaths AS int)) / SUM(new_cases) * 100 AS Global_Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL

--                                         QUERIES FOR CovidVaccinations


-- Looking for total amount of people that are vacinated in the world
SELECT 
	CovidDeaths.continent,
	CovidDeaths.location,
	CovidDeaths.date,
	CovidDeaths.population,
	CovidVaccinations.new_vaccinations,
	SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (PARTITION BY CovidDeaths.location ORDER BY 
		CovidDeaths.location, CovidDeaths.date) AS PeopleVaccinated
FROM CovidDeaths
INNER JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location AND
	   CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
ORDER BY 2, 3

CREATE VIEW VaccinatedPeopleTotal as
SELECT 
	CovidDeaths.continent,
	CovidDeaths.location,
	CovidDeaths.date,
	CovidDeaths.population,
	CovidVaccinations.new_vaccinations,
	SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (PARTITION BY CovidDeaths.location ORDER BY 
		CovidDeaths.location, CovidDeaths.date) AS PeopleVaccinated
FROM CovidDeaths
INNER JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location AND
	   CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL


WITH PopulationAndVaccination (continent, location, date, population, new_vaccinations, PeopleVaccinated) 
as 
(
SELECT 
	CovidDeaths.continent,
	CovidDeaths.date,
	CovidDeaths.location,
	CovidDeaths.population,
	CovidVaccinations.new_vaccinations,
	SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (PARTITION BY CovidDeaths.location ORDER BY 
		CovidDeaths.location, CovidDeaths.date) AS PeopleVaccinated
FROM CovidDeaths
INNER JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location AND
	   CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
)

SELECT *, (PeopleVaccinated / population) * 100 AS VaccinatedPercentage
FROM PopulationAndVaccination

Drop Table if exists #VaccinatedPeoplePercentage
Create Table #VaccinatedPeoplePercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert Into  #VaccinatedPeoplePercentage
SELECT 
	CovidDeaths.continent,
	CovidDeaths.location,
	CovidDeaths.date,
	CovidDeaths.population,
	CovidVaccinations.new_vaccinations,
	SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (PARTITION BY CovidDeaths.location ORDER BY 
		CovidDeaths.location, CovidDeaths.date) AS PeopleVaccinated
FROM CovidDeaths
INNER JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location AND
	   CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL

SELECT *, (PeopleVaccinated / population) * 100 AS VaccinatedPercentage
FROM  #VaccinatedPeoplePercentage


CREATE VIEW VaccinatedPeoplePercentage as
SELECT 
	CovidDeaths.continent,
	CovidDeaths.location,
	CovidDeaths.date,
	CovidDeaths.population,
	CovidVaccinations.new_vaccinations,
	SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (PARTITION BY CovidDeaths.location ORDER BY 
		CovidDeaths.location, CovidDeaths.date) AS PeopleVaccinated
FROM CovidDeaths
INNER JOIN CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location AND
	   CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent IS NOT NULL
