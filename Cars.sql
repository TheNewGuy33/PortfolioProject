-- Car Sales Dataset --
-- Skills Used: CTE's, Windows Functions, Aggregate Functions, Groups, Order By --



-- Select All Car Data --
select* from cars;

-- COUNT AUTOMATIC CARS VS MANUAL CARS VS UNKNOWN --

select
	count(case when transmission = 'automatic' then 'automatic' end) as Automatic_Transmission,
	count(case when transmission = 'manual' then 'manual' end) as Manual_Transmission,
	count(case when transmission != 'manual' and transmission != 'automatic' then 'manual' end) as Unknown_Transmission
from cars
where transmission is not null;


-- Total Cars Sold --
-- Total Value --
select
	count(vin) as Total_Cars_Sold,
	sum(sellingprice) Total_Value
from cars



	
-- Cars Sold Per Year --
-- Revenue Per Year --
select
	year,
	count(vin) as Cars_Sold,
	sum(sellingprice) as Revenue
from cars
group by year
order by year desc)




-- Percent of Cars Sold --
-- Percent of Revenue --
with 
car_totals as
(select
	count(vin) as total_cars
from cars),

value_totals as
(select 
	sum(sellingprice) as total_value
from cars)

select 
	Year,
	round(count(vin)/ cast(total_cars as dec) * 100, 3) as Percent_Cars_sold,
	round(sum(sellingprice)/ cast(total_value as dec) * 100, 3) as Percent_Revenue_sold
from 
	car_totals,
	value_totals,
	cars
group by year, total_cars, total_value
order by year desc;





-- Cars Sold Per Year --
select
	year,
	count(vin) as SoldCars
from cars
group by year
order by year desc;




-- Auto vs Manual --
select
	count(case when Transmission = 'manual' then Transmission end) as Manual_Cars,
	count(case when Transmission = 'automatic' then Transmission end) as Automatic_Cars,
	count(case when Transmission != 'automatic' and Transmission != 'manual' then Transmission end) as UnListed
from cars;




-- Auto sold per year vs manual sold per year --
select
	Year,
	count(case when Transmission = 'manual' then Transmission end) as Manual_Cars,
	count(case when Transmission = 'automatic' then Transmission end) as Automatic_Cars,
	count(case when Transmission != 'automatic' and Transmission != 'manual' then Transmission end) as UnListed
from cars
group by year
order by year desc;




-- Car make sold ranking --
select
	make,
	count(make) Total_Sold
from cars
group by make
order by Total_Sold desc;




-- color ranking --
select
	color,
	count(color) Total_sold
from cars
group by color
order by total_sold desc;
