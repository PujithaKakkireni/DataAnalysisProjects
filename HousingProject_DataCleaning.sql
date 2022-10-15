
----------------------------------------------------------------------------------------------------------------
------------------------Creating a database name as housing project--------------------------------------
CREATE DATABASE housingproject;

-----------------------------Opening housing project-------------------------------------------------
USE housingproject;

-------------------------imported the data from a csv file---------------------------------------------

---------------------------checking the data in the table----------------------------------------------------
SELECT *
FROM dbo.NashvilleHousing;

SELECT TOP (1000)
    [UniqueID]
      , [ParcelID]
      , [LandUse]
      , [PropertyAddress]
      , [SaleDate]
      , [SalePrice]
      , [LegalReference]
      , [SoldAsVacant]
      , [OwnerName]
      , [OwnerAddress]
      , [Acreage]
      , [TaxDistrict]
      , [LandValue]
      , [BuildingValue]
      , [TotalValue]
      , [YearBuilt]
      , [Bedrooms]
      , [FullBath]
      , [HalfBath]
FROM [housingproject].[dbo].[NashvilleHousing];

-------------------------------------------------------------------------------------------------------------------
-------------------Data Cleaning---------------------

--------------Standardize Date Format ---------------------------------


select SaleDate
from dbo.NashvilleHousing;

select SaleDate, CONVERT(Date, SaleDate) as ConvertedSaleDate
from dbo.NashvilleHousing;

UPDATE  dbo.NashvilleHousing SET SaleDate = CONVERT(Date, SaleDate);

select SaleDate
from dbo.NashvilleHousing;

----Another way---

ALTER TABLE dbo.NashvilleHousing
ADD SaleDateUpdated Date;


UPDATE  dbo.NashvilleHousing SET SaleDateUpdated = CONVERT(Date, SaleDate);

select SaleDateUpdated
from dbo.NashvilleHousing;

-----------------------------------------------------------------------------------
---Populate Property Address Data --------

select propertyAddress
from dbo.NashvilleHousing

select *
from dbo.NashvilleHousing
--where propertyAddress IS NULL
order by ParcelID;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a join dbo.NashvilleHousing B
    ON a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

Update a set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a join dbo.NashvilleHousing B
    ON a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-----------------------------------------------------------------------------------------
------- Breaking out Address into Individual Columns (Address, City)------------------

SELECT PropertyAddress
from dbo.NashvilleHousing
--where PropertyAddress is null

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) Address,
    SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) City
from dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD PAddress nvarchar(500),
PropertyAddressCity NVARCHAR(500);

SELECT *
from dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing SET PAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
PropertyAddressCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

------------------------
Select OwnerAddress
from dbo.NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) OAddress,
    PARSENAME(REPLACE(OwnerAddress,',','.'),2) OwnerAddressCity,
    PARSENAME(REPLACE(OwnerAddress,',','.'),1) OwnerAddressState
from dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD OAddress nvarchar(500),
OwnerAddressCity NVARCHAR(500),
OwnerAddressState NVARCHAR(500);

Select *
from dbo.NashvilleHousing;

UPDATE dbo.NashvilleHousing SET OAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

-----------------------------------------------------------------------------------------------------------------------------
---------- Change Y and N to Yes and No in SoladAsVacant Column-------------------------------

select distinct SoldAsVacant
from dbo.NashvilleHousing;
/*Yes
Y
No
N*/

Select distinct SoldAsVacant, COUNT(SoldAsVacant)
from dbo.NashvilleHousing
GROUP BY SoldAsVacant;



Select SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


------------------------------------------------------------------------------------
----------Remove Duplicates

select *
from dbo.NashvilleHousing
;

WITH
    Cte_a
    AS

    (
        select *, ROW_NUMBER() OVER (PARTITION BY [ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath] ORDER BY UniqueID) as rownum
        from dbo.NashvilleHousing
    ) 
delete from Cte_a
where rownum > 1;

WITH
    Cte_a
    AS

    (
        select *, ROW_NUMBER() OVER (PARTITION BY [ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath] ORDER BY UniqueID) as rownum
        from dbo.NashvilleHousing
    )
select *
from Cte_a
where rownum > 1;

-------------------------------------------------------------------------------------------------------------------------------
------------- Deleted UnUsed Columns-------------------
---- Not the best practice to delete in DB instead do it in a View--------------------------


select *
from dbo.NashvilleHousing
;


ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress,SaleDate;



-----------------------------------------------------------------------------------------------