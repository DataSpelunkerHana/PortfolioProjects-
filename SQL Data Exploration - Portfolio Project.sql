# SELECT YOUR DATABASE

use portfolioproject;

SELECT 
    *
FROM
    coviddeaths;
    
SELECT 
    *
FROM
    covidvaccinations;

    
# SELECT DATA THAT WE ARE GOING TO BE USING

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths;
    

#LOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases) * 100 as DeathPercentage
FROM
    coviddeaths;
 
 
 #SHOWS THE LIKELIHOOD OF DYING, IF YOU CONTRACT COVID IN YOUR COUNTRY


SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    location LIKE '%states%';
    
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    location LIKE '%india%';
    
    
#LOOKING AT TOTAL CASES VS POPULATION
#SHOWS WHAT %AGE OF POPULATION GOT COVID

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM
    coviddeaths
WHERE
    location LIKE '%states%';
    
    
#LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    coviddeaths
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC;


#SHOWING COUNTIRES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT 
    location,
    max(total_deaths) as TotalDeathCount
FROM
    coviddeaths
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

/*USING THIS STATEMENT HERE TO SET ALL THE ZEROES TO NULL
UPDATE coviddeaths SET continent=NULL WHERE continent='0'; */


#LET'S BREAK THINGS DOWN BY CONTINENT

SELECT 
    continent,
    max(total_deaths) as TotalDeathCount
FROM
    coviddeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


#SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT

/*
SELECT 
    location,
    max(total_deaths) as TotalDeathCount
FROM
    coviddeaths
where continent is  null
GROUP BY location
ORDER BY TotalDeathCount DESC;  */

SELECT 
    continent,
    max(total_deaths) as TotalDeathCount
FROM
    coviddeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


#GLOBAL NUMBERS

SELECT 
    date,
    sum(new_cases) as TotalCases,
    sum(new_deaths) as TotalDeaths,
    sum(new_deaths) / sum(new_cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    continent is not null
group by date
order by date;


#GIVES TOTAL CASES, DEATHS AND DEATH PERCENTAGE

SELECT 
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
ORDER BY date;


#JOINING THE TWO TABLES COVIDDEATH AND COVIDVACCINATIONS

SELECT 
    *
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac 
		ON dea.location = vac.location
        AND dea.date = vac.date;
        
        
#LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT 
    dea.continent,
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
    as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
	where dea.continent is not null
        order by 2,3;
        
        
#USE CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
    dea.continent,
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
    as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
	where dea.continent is not null
      #  order by 2,3
)
select * , (RollingPeopleVaccinated / population) * 100 from PopVsVac;


#TEMP TABLE   

DROP TABLE IF EXISTS PercentPopulationVaccinated;
create table PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date varchar(255),
population int,
new_vaccinations int,
RollingPeopleVaccinated int
);


insert into  PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
    as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
	where dea.continent is not null;
      #  order by 2,3

SELECT 
    *, (RollingPeopleVaccinated / population) * 100
FROM
    PercentPopulationVaccinated;
    
    
#CREATING VIEW TO STORE DATA FOR LATER VISUALIZAIONS    

CREATE VIEW  PercentPopulationVaccinated1 AS
SELECT 
    dea.continent,
    dea.location, 
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
    as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
	where dea.continent is not null;
	#order by 2,3;


SELECT 
    *
FROM
    PercentPopulationVaccinated1;
    

