-- most popular boy name
select 
name, sum(births) as sum
from names
where gender = 'M'
group by name
order by sum desc
limit 1
; --Michael

-- most popular girl name
select 
name, sum(births) as sum
from names
where gender = 'F'
group by name
order by sum desc
limit 1
; --Jessica

-- popularity rankings of males per year
select
year, name,
sum(births) as births, 
rank() over (partition by year order by sum(births) desc) as rank
from names
where gender = 'M'
group by year, name
;

-- Michael popularity over the years
select year, name, births, rank from (select
	year, name,
	sum(births) as births, 
	rank() over (partition by year order by sum(births) desc) as rank
	from names
	where gender = 'M'
	group by year, name) 
where name = 'Michael';

-- popularity rankings of females per year
select
year, name,
sum(births) as births, 
rank() over (partition by year order by sum(births) desc) as rank
from names
where gender = 'F'
group by year, name
;

-- Jessica popularity over the years
select year, name, births, rank from (select
	year, name,
	sum(births) as births, 
	rank() over (partition by year order by sum(births) desc) as rank
	from names
	where gender = 'F'
	group by year, name) 
where name = 'Jessica';

-- popularity rankings of males in the first year (1980)
select
year, name,
sum(births) as births, 
rank() over (partition by year order by sum(births) desc) as rank
from names
where gender = 'M' and year = 1980
group by year, name
;


-- popularity rankings of males in the latest year (2009)
select
year, name,
sum(births) as births, 
rank() over (partition by year order by sum(births) desc) as rank
from names
where gender = 'M' and year = 2009
group by year, name
;

-- names with the biggest jump in popularity from the first year to the last year
select *, fy.rank-ly.rank as popularity_diff, rank() over (order by (fy.rank-ly.rank) desc)
from (
	-- popularity ranking in 1980
	select
	year, name,
	sum(births) as births, 
	rank() over (partition by year order by sum(births) desc) as rank
	from names
	where year = 1980
	group by year, name) as fy
full join (
	-- popularity ranking in 2009
	select
	year, name,
	sum(births) as births, 
	rank() over (partition by year order by sum(births) desc) as rank
	from names
	where year = 2009
	group by year, name) as ly
on fy.name = ly.name
where fy.rank-ly.rank is not NULL
;

-- For each year, return the 3 most popular girl names and 3 popular boy names
select * from (select 
	year, name, gender, sum(births), rank() over (partition by year, gender order by sum(births) desc)
	from names
	group by year, gender, name
	)
where rank <= 3;

-- For each decade
select * from (
	-- births per decade
	select 
	decade, 
	gender, 
	name, 
	sum(births) as births,
	rank() over (partition by decade, gender order by sum(births) desc)
	from (
		-- births per year; added decade column
		select 
			year, 
			name, 
			gender, 
			sum(births) as births,
			case 
				-- From 1980 to 2009
				when year >= 2000 then '2000s'
				when year >= 1990 then '1990s'
				when year >= 1980 then '1980s'
				else 'Invalid'
			end as decade
			from names
			group by year, gender, name
			)
		group by decade, gender, name
	order by decade asc
	)
where rank <= 3
;

-- Cleaned regions:
-- New England has two entries: New England and New_England; normalized to New_England only.
-- MI state exists in the names table but not listed in the regions table; So we add it using union. 
select 
state, 
case when region = 'New England' then 'New_England' else region end as region
from regions
union 
select 'MI' as state, 'Midwest' as region

-- Number of babies born in each of the regions. 
select region, sum(births) from (
	select *
	from (
		-- cleaned regions	
		select 
		state, 
		case when region = 'New England' then 'New_England' else region end as region
		from regions
		union 
		select 'MI' as state, 'Midwest' as region
		) r
	left join (
		-- births per state
		select 
		state,
		sum(births) as births
		from names
		group by state
		) as bps
	on r.state = bps.state
	order by region
	)
group by region
;
	
-- 3 most popular girl names and 3 most popular boy names in each region
select * from (
	-- births per region
		select 
		region, name, gender,
		sum(births) as births,
		rank() over (partition by region, gender order by sum(births) desc)
		from (
			-- births per state
				select 
				name, 
				gender,
				state,
				sum(births) as births
				from names
				group by gender, name, state
			) bps
		join (
			-- cleaned regions	
			select 
			state, 
			case when region = 'New England' then 'New_England' else region end as region
			from regions
			union 
			select 'MI' as state, 'Midwest' as region
		) r 
		on bps.state = r.state
		group by region, name, gender
	)
where rank <= 3
;

-- Find the top 10 most popular androgynous names (names given to both males and females)
select
name,
count(distinct(gender)) as gender_count,
sum(births) as births
from names
group by name
having count(distinct(gender)) = 2
order by births desc
limit 10
;

-- Find the length of the shortest and longest names, then identify the most popular short names (those with the fewest chars) and the most popular long names (those with the most chars)

-- longest name length
select max(name_length), min(name_length) from (
	select 
	*, 
	length(name) as name_length
	from names
	)
; -- Longest = 15; Shortest = 2

-- most popular short names
select 
name, sum(births) as births
from (
	select 
	*, 
	length(name) as name_length
	from names
	)
where name_length = 2
group by name
order by births desc
;

-- most popular long names
select 
name, sum(births) as births
from (
	select 
	*, 
	length(name) as name_length
	from names
	)
where name_length = 15
group by name
order by births desc
;

-- The founder of Maven Analytics is named Chris. Find the state with the highest percent of babies named "Chris"
-- get total per state
SELECT
    state,
    round(100.0 * SUM(births) FILTER (WHERE name = 'Chris') / SUM(births),
          4
          ) AS chris_percentage
FROM names
GROUP BY state
having sum(births) filter (where name = 'Chris') > 0
ORDER BY chris_percentage DESC
;

-- END