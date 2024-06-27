-- Cleaning Data In SQL Queries

-- Skills Used: Converts, Update, Drops

---------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select 
	CONVERT(Date, SaleDate)
from [dbo].[NashvilleHousingMarket]


update [dbo].[NashvilleHousingMarket]
set saledate = CONVERT(Date, SaleDate)


Alter table [dbo].[NashvilleHousingMarket]
add SaleDateConverted Date;


update [dbo].[NashvilleHousingMarket]
set saledateconverted = convert(date,saledate)


select
	saledateconverted,
	saledate
from [dbo].[NashvilleHousingMarket]

---------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select
	a.parcelid,
	a.propertyaddress,
	b.parcelid,
	b.propertyaddress,
	isnull(a.propertyaddress,b.propertyaddress)
from NashvilleHousingMarket a
join NashvilleHousingMarket b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;


update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from NashvilleHousingMarket a
join NashvilleHousingMarket b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null;


---------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City)

Select
	propertyaddress
from nashvillehousingmarket

select
	substring(propertyaddress, 1, charindex(',', propertyaddress) -1) as Address,
	substring(propertyaddress, charindex(',', propertyaddress) +1, Len(propertyaddress)) as City
from nashvillehousingmarket;



Alter table [dbo].[NashvilleHousingMarket]
add Property_Address nvarchar(255);


update [dbo].[NashvilleHousingMarket]
set Property_Address = 	substring(propertyaddress, 1, charindex(',', propertyaddress) -1) 



Alter table [dbo].[NashvilleHousingMarket]
add Property_City nvarchar(50);


update [dbo].[NashvilleHousingMarket]
set Property_City = substring(propertyaddress, charindex(',', propertyaddress) +1, Len(propertyaddress))


---------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select
	parsename(replace(owneraddress, ',', '.'), 3),
	parsename(replace(owneraddress, ',', '.'), 2),
	parsename(replace(owneraddress, ',', '.'), 1)
from nashvillehousingmarket


Alter table [dbo].[NashvilleHousingMarket]
add Owner_State nvarchar(6);


update [dbo].[NashvilleHousingMarket]
set Owner_State = parsename(replace(owneraddress, ',', '.'), 1)




---------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant' field

Select distinct(soldasvacant)
from nashvillehousingmarket


select
	soldasvacant,
	case 
		when soldasvacant = 'N' then 'No' 
		when soldasvacant = 'Y' then 'Yes' 
		else soldasvacant end
from nashvillehousingmarket


Alter table [dbo].[NashvilleHousingMarket]
add Sold_As_Vacant nvarchar(6);


update [dbo].[NashvilleHousingMarket]
set Sold_As_Vacant = case 
		when soldasvacant = 'N' then 'No' 
		when soldasvacant = 'Y' then 'Yes' 
		else soldasvacant end
from nashvillehousingmarket



---------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with rownumcte as
(Select *,
	row_number() over(
	partition by 
			parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference
			order by 
				uniqueid) as row_num
from nashvillehousingmarket)
--order by parcelid

select*
from rownumcte
where row_num > 1
order by propertyaddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


alter table NashvilleHousingMarket
drop column
	owneraddress,
	taxdistrict,
	propertyaddress,
	saledate

select* from 
nashvillehousingmarket

---------------------------------------------------------------------------------------------------------
-- Change Res Land to Residential Land

Select
	distinct(landuse)
from nashvillehousingmarket
order by landuse desc


create view Land_Use as
select
	case 
		when landuse = 'vacant res land' then 'VACANT RESIDENTIAL LAND'
		when landuse = 'vacant resiential land' then 'VACANT RESIDENTIAL LAND'
		else landuse end as LandUse
from nashvillehousingmarket
group by landuse
order by Landuse desc;



alter table nashvillehousingmarket
add Land_Use nvarchar(50)


update nashvillehousingmarket
set Land_Use = 
	case 
		when landuse = 'vacant res land' then 'VACANT RESIDENTIAL LAND'
		when landuse = 'vacant resiential land' then 'VACANT RESIDENTIAL LAND'
		else landuse end --as LandUse
from nashvillehousingmarket


