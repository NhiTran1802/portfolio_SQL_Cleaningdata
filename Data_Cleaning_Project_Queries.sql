/*
Cleaning data in SQL
Operate on a view to analysis (not raw data in database)
*/

-- Standardize Data Format

SELECT SaleDateNew, CONVERT(DATE, SaleDate)
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD SaleDateNew DATE 

UPDATE dbo.NashvilleHousing
SET SaleDateNew = CONVERT(DATE, SaleDate)

-------------------------------------------
-- Populate Property Address Data

SELECT ParcelID, PropertyAddress 
FROM dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT t1.ParcelID
, t1.PropertyAddress
, t2.ParcelID
, t2.PropertyAddress
, ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM dbo.NashvilleHousing t1
JOIN dbo.NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.UniqueID <> t2.UniqueID
WHERE t1.PropertyAddress IS null

UPDATE t1 
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM dbo.NashvilleHousing t1
JOIN dbo.NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.UniqueID <> t2.UniqueID
WHERE t1.PropertyAddress IS NULL

-------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

--- PropertyAddress
SELECT PropertyAddress
FROM dbo.NashvilleHousing

SELECT 
PropertyAddress
, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) Adress
, RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) City
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD Adress NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET Adress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE dbo.NashvilleHousing
ADD City NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET City = RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))

--- OwnerAdress
SELECT OwnerAddress
FROM dbo.NashvilleHousing

SELECT OwnerAddress
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD OwnerAdress NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET OwnerAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerState NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY (SoldAsVacant)
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

-------------------------------------------
-- Remove Duplicates

WITH table0 as
(SELECT *
, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) row_num
FROM dbo.NashvilleHousing)

DELETE
FROM table0
WHERE table0.row_num > 1

-------------------------------------------
-- Delete Unused Columns

SELECT * FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN TaxDistrict, SaleDate, PropertyAddress, OwnerAddress