/* 

Cleaning Nashvill Housing  Data in SQL Queries 
 
*/
 
 -- Global Look To our Data 
 Select * 
From [Portfolio Project]..NashvillHousing
order by 1

-- Convvert Date
Select SaleDate,CONVERT(date,SaleDate)
From [Portfolio Project]..NashvillHousing

Update NashvillHousing
Set SaleDate= CONVERT(date,SaleDate)


ALTER TABLE NashvillHousing
Add SaleDateConverted Date;

Update NashvillHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDate,SaleDates
From [Portfolio Project]..NashvillHousing


--Changing the addresses that was Null to a value where PareclID was the same
Select *
From [Portfolio Project]..NashvillHousing
where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..NashvillHousing a
JOIN [Portfolio Project]..NashvillHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project]..NashvillHousing a
JOIN [Portfolio Project]..NashvillHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
    
--Breaking up The address into INDIVIDUAL @
Select PropertyAddress
From [Portfolio Project]..NashvillHousing
 
 SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as city

From [Portfolio Project]..NashvillHousing
--After spliting city from @ we add new  column named PropertySplitAddress that contain only addresses

ALTER TABLE [Portfolio Project]..NashvillHousing
Add PropertySplitAddress nvarchar(255);

Update [Portfolio Project]..NashvillHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- After spliting city from @ we add new  column named PropertySplitCity that contain only cities
ALTER TABLE [Portfolio Project]..NashvillHousing
Add PropertySplitCity Nvarchar(255);

Update [Portfolio Project]..NashvillHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))
-- Check
Select *
from [Portfolio Project]..NashvillHousing


-- Split Owner address into (address , city, state)

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project]..NashvillHousing

ALTER TABLE [Portfolio Project]..NashvillHousing
Add OwnerSplitAddress nvarchar(255);

Update [Portfolio Project]..NashvillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Portfolio Project]..NashvillHousing
Add OwnerSplitCity nvarchar(255);

Update [Portfolio Project]..NashvillHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Portfolio Project]..NashvillHousing
Add OwnerSplitState nvarchar(255);
Update [Portfolio Project]..NashvillHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--  Replace the word Y by yes and N by No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvillHousing
Group by SoldAsVacant
order by 2

 Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Project]..NashvillHousing

Update [Portfolio Project]..NashvillHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


	   --Delete duplicate Data
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Project]..NashvillHousing
)


Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
from [Portfolio Project]..NashvillHousing


-- Delete useless Columns 


ALTER TABLE [Portfolio Project]..NashvillHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate,SaleDates