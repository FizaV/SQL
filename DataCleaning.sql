SELECT TOP 1000 *
FROM PortfolioProject.dbo.NashvilleHousing


--DATE
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--POPULATE PROPERTY ADDRESS DATA
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

	--SELF JOIN
SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


Select * 
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL



--BREAKING ADDRESS INTO DIFFERENT COLUMNS(ADDRESS, CITY, STATE)

  --PROPERTY ADDRESS
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

--SELECT 
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)), CHARINDEX(',', PropertyAddress)
--FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) Street,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) City
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertyAddressStreet varchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertyAddressCity varchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


	--OWNER ADDRESS
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) Street,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) City,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) State
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerAddressStreet varchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerAddressCity varchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerAddressState varchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 


--CHANGE Y AND N TO Yes AND No in "Sold as Vacant" FIELD
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	 WHEN SoldAsVacant = 'N' THEN 'No' 
	 ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
						WHEN SoldAsVacant = 'N' THEN 'No' 
						ELSE SoldAsVacant
					END
FROM PortfolioProject.dbo.NashvilleHousing



--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY  ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
	ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate