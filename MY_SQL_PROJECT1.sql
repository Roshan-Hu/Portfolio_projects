

USE SQL_PROJECT;


--HERE I HAVE IMPORTED THE TWO COVID DATA FILES FROM WXCEL TO SQL SERVER 


select * from COVID_DEATHS;

SELECT DISTINCT location from COVID_DEATHS

--THERE ARE 244 COUNTRY DATA IN COVID_DEATH TABLE .


SELECT DATEDIFF(YEAR,01-01-2020,29-08-2022) AS DATE_DIFF FROM COVID_DEATHS

--THE DIFFERNCE BETWEEN THE DATES IS 2 YEARS 7 MONTHS 29 DAYS SO THE DATASET CONTAINS 2 YEARS DATA FROM THE BEGINING DATE AND THE ENDING DATE



select * from COVID_VACCINATIONS

--NOW I HAVE TO SORT THE TWO DATA FILES BY LOCATION AND DATE WISE .

 
SELECT * FROM COVID_DEATHS
 where continent is not null
ORDER BY 3,4;

SELECT * FROM COVID_VACCINATIONS
 where continent is not null
ORDER BY 3,4;
                                    
									--DATA MANIPULATION 
									-------------------------

=============
COVID_DEATHS
=============


-- NOW WE HAVE TO SELECT THE COVID_DEATHS DATA FIRST TO PERFORM DATA MANIPULATION ON IT .

-- NOW WE HAVE TO SORT THE DATA BY LOCATION,DATE,TOTAL-CASES,NEW-CASES,TOTAL-DEATHS AND POPULATION. AND ORDER THE DATA BY LOCATION AND DATE WISE.

SELECT location,date,total_cases,new_cases,total_deaths, population from COVID_DEATHS  where continent is not null  order by 1,2
 
 --THE FIRST DEATH CASE WAS OCCURED IN THE 23-03-2020 


 -- NOW WE HAVE TO CALCULATE THE TOTAL DEATHS VS TOTAL CASES BY LOCATION AND DATE WISE IN OUR COVID_DEATHS DATASET.

 SELECT location,date,total_cases,total_deaths , FORMAT((total_deaths/total_cases),'P2') as DEATH_PERCENTAGE FROM COVID_DEATHS  where continent is not null ORDER BY 1,2;

 --IF WE CALCULATE THE SAME FOR INDIA WITH PERCENTAGE FORMAT AND DATE WISE TOTAL CASE AND TOTAL DEATH AND DEATH RATIO.

 SELECT location,date,total_cases,total_deaths , FORMAT((total_deaths/total_cases),'P2') as DEATH_PERCENTAGE
 FROM COVID_DEATHS
 WHERE location like '%STATES%' and  continent is not null
 ORDER BY 1,2;

 
 -- IF WE LOOK FURTHER THE DEATHS CASES HAS STARTED IN INDIA FROM 01-30-2020 ONWARDS .
 
 SELECT location,date,total_cases,total_deaths , FORMAT((total_deaths/total_cases),'P2') as DEATH_PERCENTAGE
 FROM COVID_DEATHS
 WHERE location like '%India%' AND total_deaths is null  and  continent is not null 
 ORDER BY 1,2;


 -- NOW WE WILL CALCULATE THE TOTAL_CASES VS TOTAL_POPULATION BY LOCATION AND DATE WISE IN OUR COVID_DEATHS DATASET. TO GET THE PERCENTAGE OF POPULATION GOT INFECTED .

SELECT location,date, population, sum(total_cases) as total_cases,  format((total_cases/population),'p2')  as PERCENTAGE_OF_POPULATION_GOT_INFECTED
from COVID_DEATHS  
where location like '%INDIA%' and  continent is not null
group by location,date,population,total_cases
order by 1,2;


-- BUT IF WE CALCULATE THE OVERALL DATA FROM COVID_DEATHS FROM ALL THE LOCATIONS

SELECT location,date, population, total_cases,  FORMAT((total_cases/population)*100,'P2')  as DEATH_PERCENTAGE
from COVID_DEATHS  
--where location like '%INDIA%'
order by 1,2;




-- NOW WE WILL CALCULATE WHICH COUNTRY HAVING THE HIGHEST INFECTION RATE (HIGHEST NUMBER OF TOTAL CASES) COMPARED TO THE POPULATION BY LOCATION AND DEATH_PERCENTAGE WISE.

select * from COVID_DEATHS;

with cte as(select * from 
(select location,population,max(total_cases) as highest_infection , format((max((total_cases)/population)),'p2') as infection_by_population 
from COVID_DEATHS
where   continent is not null
group by location,population)t)
 
select * from cte
order by infection_by_population desc
 
 --NOW WE WILL CALCULATE THE HIGHEST DEATH COUNT BY  POPULATION WISE .
 

 select* from COVID_DEATHS;

select location ,population, max(cast(total_deaths as int )) as highest_death ,  (max(cast(total_deaths as int ))/population) as death_percent
from COVID_DEATHS
where continent is not  null
group by location,population
order by death_percent desc ;


--NOW LETS BREAK IT DOWN BY CONTINENT WISE HIGHEST DEATH
 
select location , max(cast(total_deaths as int )) as highest_death  
from COVID_DEATHS
where continent is  null
group by location
order by highest_death desc ;

--here we have to use location instead of continent to actually fetch the continent wise data.


--Global_numbers

-- BY DATE WISE TOTAL CASES , TOTAL DEATHS AND DEATH PERCENTAGE

select * from COVID_DEATHS

select date,sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases), as Death_percentage
from COVID_DEATHS
where continent is not null
group by date
order by 1;


--JUST BY GLOBALLY THE ENTIRE CASES VS DEATH VS DEATH PERCENTAGE 

select 
ISNULL(total_deaths,0),
sum(new_cases) as total_cases ,
sum(cast(total_deaths as int)) as total_deaths , format(sum(cast(new_deaths as int))/sum(new_cases),'P2') as Death_percentage
from COVID_DEATHS
where continent is not null
group by total_deaths
order by 1;



select
ISNULL(new_cases_smoothed,0)
from COVID_DEATHS;




select
sum(new_cases) as total_cases , 
sum(cast(new_deaths as int)) as total_deaths , 
format(sum(cast(new_deaths as int))/sum(new_cases),'p2') as Death_percentage
from COVID_DEATHS
where continent is not null
order by 1;


===================
COVID_VACCINATIONS
===================

-- NOW WE WILL PERFORM THESE TASKS ON A DIIFERENT FILE (COVID_VACCINATIONS) 

select 
location,
date,

total_tests,
new_tests,
positive_rate,
total_vaccinations,
total_boosters,
new_vaccinations,
population_density,
life_expectancy
from COVID_VACCINATIONS
order by 3,4

-- Now We have to calculate the total test vs total vaccination and also there ratio as total_vaccination_ratio


select
location,
date,
total_vaccinations,
cast(total_tests as int),
(total_vaccinations/cast(total_tests as int))*100  as total_vaccination_ratio
from COVID_VACCINATIONS
order by 1,2;


--NOW WE HAVE TO JOIN THE TWO TABLES.

SELECT * 
FROM COVID_DEATHS A
join COVID_VACCINATIONS B
on 
A.location=B.location
and
A.date=B.date

--NOW WE HAVE TO CALCULATE THE TOTAL POPULATION VS TOTAL VACCINATIONS
 
SELECT A.continent , A.location, A.date , A.population, B.new_vaccinations
FROM COVID_DEATHS A
join COVID_VACCINATIONS B
on 
A.location=B.location
and
A.date=B.date
where A.continent is not null
order by 2,3;


--NOW WE HAVE TO CALCULATE THE CUMMULATIVE SUM OF THE NEW_VACCINATION COLUMN IN ORDER TO CALCULATE THE VACCINATIONS_PER_DAY COUNT

SELECT A.continent , A.location, A.date , A.population, B.new_vaccinations,
sum( cast(B.new_vaccinations as bigint )) over (partition by  A.location order by A.location , A.date ) as cummilative_vaccinations_count
FROM COVID_DEATHS A
join COVID_VACCINATIONS B
on 
A.location=B.location
and
A.date=B.date
where A.continent is not null
order by 2,3;

--CONCLUSION
==============
--HERE I'VE FACED AN ERROR (Msg 8115, Level 16, State 2, Line 228 Arithmetic overflow error converting expression to data type int.) 
--BECAUSE IN MY ABOVE QUERY CALCULATION ON AINTEGER COLUMN HAS EXCEDED THE 'INT RANGE.'
-- SO TO OVERCOME THIS I HAVE TO CONVERT THE 'INT' COLUMN TO 'BIGINT'.


--IN THE ABOVE QUERY I HAVE ACHIVED TO PERFORM TO CALCULATE THE CUMMILATIVE SUM OF VACCINATION  BUT IF I WANT TO CALCULATE THE TOTAL_VACCINATIONS VS POPULATION WHICH IS THE MAIN GOAL
--THEN WE CANT NOT USE THE COLUMN AGAIN WHICVH WE HAVE CREATED IN THE SAME QUERY SO WE HAVE TO USE CTE (COMMON TABLE EXPRRESSION) OR TEMP_TABLE (TEMPORARY_TABLE) TO ACHIVE THAT.


--USE OF CTE
--FIRSTLY WITH CTE WE HAVE TO MENTION THE COLUMN NAMES THAT WIIL BE IN OUR RESULT DATA SET
--INSIDE OF A CTE WE CAN NOT HAVE ANY ORDER BY CLAUSE
--NOW AFTER SUCCESFULLY CREATING A CTE WE CAN HAVE OUR CALCULATED_COLUMN INSIDE IT TO FIND OUT THE TOTAL_VACCINATIONS/POPULATION.




with Pop_Vs_Vac(continent,location,date,population,new_vaccinations,cummilative_vaccinations_count)
as 
(
SELECT A.continent , A.location, A.date , A.population, B.new_vaccinations,
sum( cast(B.new_vaccinations as bigint )) over (partition by  A.location order by A.location , A.date ) as cummilative_vaccinations_count
FROM COVID_DEATHS A
join COVID_VACCINATIONS B
on 
A.location=B.location
and
A.date=B.date
where A.continent is not null
--order by 2,3;
)
select * , format((cummilative_vaccinations_count/population),'p2') as ppl_vaccinated_ratio
from Pop_Vs_Vac



--WITHOUT THE DATE THE SAME RESULT


with Pop_Vs_Vac(continent,location,population,new_vaccinations,cummilative_vaccinations_count)
as 
(
SELECT A.continent , A.location, A.population, B.new_vaccinations,
sum( cast(B.new_vaccinations as bigint )) over (partition by  A.location order by A.location , A.date ) as cummilative_vaccinations_count
FROM COVID_DEATHS A
join COVID_VACCINATIONS B
on 
A.location=B.location
and
A.date=B.date
where A.continent is not null
--order by 2,3;
)
select * , format((cummilative_vaccinations_count/population),'p2') as ppl_vaccinated_ratio
from Pop_Vs_Vac



--NOW SAVING IT AS AS VIEW TO CREATE VISUALIZATION LATER ON .
-- AGAIN WE CAN NOT USE ORDER BY CLAUSE IN A VIEW QUERY .

CREATE VIEW PercentOfPeopleVaccinated as 
SELECT A.continent , A.location, A.date , A.population, B.new_vaccinations,
sum( cast(B.new_vaccinations as bigint )) over (partition by  A.location order by A.location , A.date ) as cummilative_vaccinations_count
FROM COVID_DEATHS A
join COVID_VACCINATIONS B
on 
A.location=B.location
and
A.date=B.date
where A.continent is not null
--order by 2,3;


SELECT * FROM PercentOfPeopleVaccinated;


