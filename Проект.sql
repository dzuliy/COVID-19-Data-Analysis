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


ALTER TABLE PropertySplitAddress ALTER COLUMN PropertyAddress Address


Update DataForCleaning
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , len(PropertyAddress))

ALTER TABLE PropertySplitCity add PropertySplitCity Nvarchar(255);

Select *
From PortfolioProjectNewData.dbo.DataForCleaning
-- Need to solve

Select OwnerAddress
From PortfolioProjectNewData.dbo.DataForCleaning

Select 
PARSENAME(Replace(OwnerAddress, ',', '.') , 3)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 1)

From PortfolioProjectNewData.dbo.DataForCleaning

ALTER TABLE PropertySplitAddress 
add OwnerSplitAddress Nvarchar(255);

Update DataForCleaning
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)


ALTER TABLE PropertySplitCity 
add OwnerSplitCity Nvarchar(255);

Update DataForCleaning
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2)


ALTER TABLE PropertySplitCity 
add OwnerSplitState Nvarchar(255);

Update DataForCleaning
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') , 1)


