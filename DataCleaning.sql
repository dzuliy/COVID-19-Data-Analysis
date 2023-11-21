/*
Cleaning data in SQL Queries
*/


Select*
From PortfolioProjectNewData.dbo.DataForCleaning


-- Standardize Date Format

Select SaleDate, Convert(date,SaleDate)
from PortfolioProjectNewData.dbo.DataForCleaning

Update DataForCleaning
Set SaleDate = Convert(date,Saledate)

--ALTER Table DataForCleaning add saledateconverted date; - Its dosent work

ALTER TABLE DataForCleaning ALTER COLUMN SaleDate DATE


-- Populate Property address data

Select *
From PortfolioProjectNewData.dbo.DataForCleaning
--where PropertyAddress is null 
Order by ParcelID

Select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProjectNewData.dbo.DataForCleaning a
Join PortfolioProjectNewData.dbo.DataForCleaning b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress,b.PropertyAddress)
From PortfolioProjectNewData.dbo.DataForCleaning a
Join PortfolioProjectNewData.dbo.DataForCleaning b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull (a.PropertyAddress,b.PropertyAddress)
From PortfolioProjectNewData.dbo.DataForCleaning a
Join PortfolioProjectNewData.dbo.DataForCleaning b
on a.ParcelID = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (address,City,State)

Select PropertyAddress
From PortfolioProjectNewData.dbo.DataForCleaning
--where PropertyAddress is null
--Order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress)) as Address

From PortfolioProjectNewData.dbo.DataForCleaning   

Update DataForCleaning
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PropertySplitAddress
add PropertySplitAddress Nvarchar(255);


Update DataForCleaning
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress))

ALTER TABLE PropertySplitCity add PropertySplitCity Nvarchar(255);

-- Change Y And N ti Yes and No in "Sold as Vacant" Field

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjectNewData.dbo.DataForCleaning
Group by SoldAsVacant
Order By 2


Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
From PortfolioProjectNewData.dbo.DataForCleaning

Update PortfolioProjectNewData.dbo.DataForCleaning
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END

-- Remove Dublicates

with RowNumCTE AS(
Select *,
Row_number() Over (
Partition by parcelID,
             propertyAddress,
			 saleprice,
			 saledate,
			 LegalReference
			 Order by
			   UniqueID
			   ) row_num 

From PortfolioProjectNewData.dbo.DataForCleaning
--order by parcelID
)
Delete 
From RowNumCTE
where row_num > 1
--order by propertyAddress

--check

with RowNumCTE AS(
Select *,
Row_number() Over (
Partition by parcelID,
             propertyAddress,
			 saleprice,
			 saledate,
			 LegalReference
			 Order by
			   UniqueID
			   ) row_num 

From PortfolioProjectNewData.dbo.DataForCleaning
--order by parcelID
)
Select * 
From RowNumCTE
where row_num > 1
order by propertyAddress

-- delete unused columns

Select *
From PortfolioProjectNewData.dbo.DataForCleaning

Alter table PortfolioProjectNewData.dbo.DataForCleaning
drop column TaxDistrict