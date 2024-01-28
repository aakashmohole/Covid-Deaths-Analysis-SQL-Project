Select * 
From PortfolioProject..CovidDeaths
Order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Change the data type of the column
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths float

-- Loking at Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2


-- Looking at total cases VS Population
SELECT location, date, total_cases, population, (total_cases / population) * 100 as DeathPercentageByPopulation
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%india%'
ORDER BY 1,2


-- Lokking at countries with higest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfection, MAX((total_cases / population)) * 100 as
PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing Countries With Highest Death Count Per populatiuion
SELECT location, MAX(total_cases)  as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS BY CONTINENT
SELECT continent, MAX(total_cases)  as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_cases)  as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%india%'
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing the continent with the highest death count per population
SELECT continent, MAX(total_cases)  as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%india%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Beaking Global Numbers
SELECT sum(new_cases) as TotalCases, sum(new_cases) as TotalDeaths, sum(new_deaths) / sum(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
 -- GROUP BY date
ORDER BY 1,2

-- ******************************************************************************************************************************************
-- *******************************************************************************************************************************************

-- COVID VACCTIONATION

SELECT *
FROM PortfolioProject..CovidVaccinations

SELECT * 
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date


-- Change the data type of the column
ALTER TABLE PortfolioProject..CovidVaccinations
ALTER COLUMN new_vaccinations float

-- Looking at Total Population VS Vaccination
SELECT CD.continent, CD.location ,CD.date ,CD.population, CV.new_vaccinations,
sum(CV.new_vaccinations) OVER (Partition by CD.location ORDER BY CD.location, CD.date) as 
RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent is NOT NULL
ORDER BY 2,3


-- USE CTE
with popVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT CD.continent, CD.location ,CD.date ,CD.population, CV.new_vaccinations,
sum(CV.new_vaccinations) OVER (Partition by CD.location ORDER BY CD.location, CD.date) as 
RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent is NOT NULL
)

SELECT *, (RollingPeopleVaccinated / population) *100
FROM popVsVac