-- Visual scan of data to be used 

select country, date, total_cases, new_cases, total_deaths, population
from PortfolioCovid..covid_deaths
order by 1, 2

-- separating special locations to new tables

select * into special_covid
from covid_deaths
where country in ('European Union (27)','High-income countries','Lower-middle-income countries','Low-income countries','Summer Olympics 2020','Winter Olympics 2022','World','World excl. China','World excl. China and South Korea','World excl. China, South Korea, Japan and Singapore')

select * into special_vaccinations
from covid_vaccinations
where country in ('European Union (27)','High-income countries','Lower-middle-income countries','Low-income countries','Summer Olympics 2020','Winter Olympics 2022','World','World excl. China','World excl. China and South Korea','World excl. China, South Korea, Japan and Singapore')

insert into special_covid
select * from covid_deaths 
where country in ('Africa','Europe','North America','South America','Asia', 'Upper-middle-income countries')

insert into special_vaccinations
select * from covid_vaccinations 
where country in ('Africa','Europe','North America','South America','Asia', 'Upper-middle-income countries')

insert into special_covid
select * from covid_deaths 
where country in ('Asia excl. China')

insert into special_vaccinations
select * from covid_vaccinations 
where country in ('Asia excl. China')

insert into special_covid
select * from covid_deaths 
where country in ('Oceania')

insert into special_vaccinations
select * from covid_vaccinations 
where country in ('Oceania')

-- deleting special locations from main tables

delete from covid_deaths
where country in ('Africa','Europe','North America','South America','Asia', 'Upper-middle-income countries','European Union (27)','High-income countries','Lower-middle-income countries','Low-income countries','Summer Olympics 2020','Winter Olympics 2022','World','World excl. China','World excl. China and South Korea','World excl. China, South Korea, Japan and Singapore')

delete from covid_vaccinations
where country in ('Africa','Europe','North America','South America','Asia', 'Upper-middle-income countries','European Union (27)','High-income countries','Lower-middle-income countries','Low-income countries','Summer Olympics 2020','Winter Olympics 2022','World','World excl. China','World excl. China and South Korea','World excl. China, South Korea, Japan and Singapore')

delete from covid_vaccinations
where country in ('Asia excl. China')

delete from covid_deaths
where country in ('Asia excl. China')

delete from covid_vaccinations
where country in ('Oceania')

delete from covid_deaths
where country in ('Oceania')
 
 -- death rate By Country

select country, date, total_cases, new_deaths, (total_deaths/total_cases)*100 as death_rate
from PortfolioCovid..covid_deaths
where 
	total_cases <> 0 and 
	country = 'Serbia'
order by 1, 2 DESC

-- infection rate by country

select country, date, new_cases, population, (total_cases/population)*100 infection_rate
from PortfolioCovid..covid_deaths
where 
	population <> 0 and 
	country = 'Serbia' and
	total_cases <> 0
order by date desc

-- highest total cases/infection rate

select country, population, max(total_cases) total_cases, max((total_cases/population))*100 infection_rate
from PortfolioCovid..covid_deaths
where total_cases <> 0
group by 
	country,
	population
having population is not null
order by infection_rate desc

-- highest total deaths/death rate

select country, max(total_deaths) as death_count
from PortfolioCovid..covid_deaths
group by 
	country
order by death_count desc 

-- Global numbers by date

select date, sum(new_cases) cases, sum(new_deaths) deaths, sum(new_deaths)/sum(new_cases)*100 death_rate
from PortfolioCovid..covid_deaths 
where
	new_cases <> 0 and
	new_deaths <> 0
group by date
order by 1 desc

-- 10 deadliest covid days %

select top 10 date, sum(new_cases) cases, sum(new_deaths) deaths, sum(new_deaths)/sum(new_cases)*100 death_rate
from PortfolioCovid..covid_deaths 
where
	new_cases <> 0 and
	new_deaths <> 0
group by date
order by 4 desc

-- 10 deadliest covid days total

select top 10 date, sum(new_deaths) deaths
from PortfolioCovid..covid_deaths 
group by date
order by 2 desc

-- covid vaccinations

select *
from PortfolioCovid..covid_vaccinations

-- joining covid data

select *
from covid_deaths d
join covid_vaccinations v
	on d.country = v.country 
	and d.date = v.date

-- total population vs vaccinated population

select d.country, max(d.population) population, max(cast(v.people_vaccinated as float)) vaccinated, max(cast(v.people_vaccinated as float))/max(d.population)*100 vaccination_rate
from covid_deaths d
join covid_vaccinations v
	on d.country = v.country 
	and d.date = v.date
where 
	d.population is not null and
	v.people_vaccinated is not null
group by 
	d.country
order by d.country


-- Rolling Vaccination Count

select d.country, d.date, d.population, cast(v.new_vaccinations as float) new_vaccinations,
sum(cast(v.new_vaccinations as float)) over (partition by d.country order by d.country, d.date) people_vaccinated_rolling
from covid_deaths d
join covid_vaccinations v
	on d.country = v.country 
	and d.date = v.date
where
	d.population is not null and 
	v.new_vaccinations is not null
order by d.country

-- CTE for Rolling count (have to run with query)

With pop_vac (country, date, population, new_vaccinations, people_vaccinated_rolling)
as 
(
select d.country, d.date, d.population, cast(v.new_vaccinations as float) new_vaccinations,
sum(cast(v.new_vaccinations as float)) over (partition by d.country order by d.country, d.date) people_vaccinated_rolling
from covid_deaths d
join covid_vaccinations v
	on d.country = v.country 
	and d.date = v.date
where
	d.population is not null and 
	v.new_vaccinations is not null
)

select *, (people_vaccinated_rolling/population)*100
from pop_vac

-- Temp Table

select d.country, d.date, d.population, cast(v.new_vaccinations as float) new_vaccinations,
sum(cast(v.new_vaccinations as float)) over (partition by d.country order by d.country, d.date) people_vaccinated_rolling
into #percent_population_vaccinated
from covid_deaths d
join covid_vaccinations v
	on d.country = v.country 
	and d.date = v.date
where
	d.population is not null and 
	v.new_vaccinations is not null

select *
from #percent_population_vaccinated
--drop table if exists #percent_population_vaccinated

-- Creating Views for Visualizations

create view percent_population_vaccinated as
select d.country, d.date, d.population, cast(v.new_vaccinations as float) new_vaccinations, 
sum(cast(v.new_vaccinations as float)) over (partition by d.country order by d.country, d.date) people_vaccinated_rolling
from covid_deaths d
join covid_vaccinations v
	on d.country = v.country 
	and d.date = v.date
where
	d.population is not null and 
	v.new_vaccinations is not null

create view vaccination_rate as
select d.country, max(d.population) population, max(cast(v.people_vaccinated as float)) vaccinated, max(cast(v.people_vaccinated as float))/max(d.population)*100 vaccination_rate
from covid_deaths d
join covid_vaccinations v
	on d.country = v.country 
	and d.date = v.date
where 
	d.population is not null and
	v.people_vaccinated is not null
group by 
	d.country

create view deadliest_days as
select top 10 date, sum(new_deaths) deaths
from PortfolioCovid..covid_deaths 
group by date
