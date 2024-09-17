select * 
from portfoliohousing..nashville

-- Standardize Date Format

select saledate, CONVERT(date, saledate)
from nashville

alter table nashville
alter column saledate date

-- Update Null Property Address 

select *
from nashville
where propertyaddress is null
order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from nashville a
join nashville b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from nashville a
join nashville b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

 -- Breaking Down Property Address - SUBSTRING
 
select propertyaddress
from nashville

select 
	substring(propertyaddress, 1, charindex(',',propertyaddress) -1),
	substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress))
from nashville

alter table nashville
add propertysplitaddress varchar(255)

alter table nashville
add propertysplitcity varchar(255)

update nashville
set propertysplitaddress = 	substring(propertyaddress, 1, charindex(',',propertyaddress) -1)

update nashville
set propertysplitcity = substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress))

-- Breaking Down Ownder Address - PARSENAME

select OwnerAddress
from nashville

select 
	parsename(replace(owneraddress, ',', '.'), 3),
	parsename(replace(owneraddress, ',', '.'), 2),
	parsename(replace(owneraddress, ',', '.'), 1)
from nashville

alter table nashville
add ownersplitaddress varchar(255)


alter table nashville
add ownersplitcity varchar(255)


alter table nashville
add ownersplitstate varchar(255)

update nashville
set ownersplitaddress = parsename(replace(owneraddress, ',', '.'), 3)

update nashville
set ownersplitcity = parsename(replace(owneraddress, ',', '.'), 2)

update nashville 
set ownersplitstate = parsename(replace(owneraddress, ',', '.'), 1)

-- Change Y and N to Yes and No in 'Sold as Vacant' Column

select distinct(soldasvacant), count(soldasvacant)
from nashville
group by soldasvacant
order by 2


select 
	soldasvacant,
	case 
		when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant
	end
from nashville 

update nashville
set soldasvacant = 
	case 
		when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant
	end

-- Remove Duplicates

with rownumCTE as (
select *,
	row_number() over (
	partition by 
		parcelid,
		propertyaddress,
		saleprice,
		saledate,
		legalreference
		order by 
		uniqueid
	) rownum
from nashville
)

select * --delete
from rownumCTE
where rownum > 1
--order by propertyaddress
 
 -- Drop Unused Columns 

select *
from nashville

alter table nashville
drop column propertyaddress, owneraddress, taxdirstrict