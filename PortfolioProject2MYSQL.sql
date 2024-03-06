SELECT * FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;
/*
cleaning data in SQL Queries
*/

SELECT * 
FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;

---------------------------------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT

SELECT STR_TO_DATE(SaleDate, '%M %e, %Y') AS FormattedSaleDate
FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;

SELECT CONCAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), ' 00:00:00.000') AS FormattedDateTime
FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;

Update PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
Add FormattedSaleDate Date ;

Update PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
SET FormattedSaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

UPDATE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');


--------------------------------------------------------------------------------------------------
-- POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`

ORDER BY ParcelID;


-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;


SELECT
  SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address
FROM
  PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;
  
  
  SELECT
  SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address1,
  SUBSTRING(PropertyAddress, CHAR_LENGTH(SUBSTRING_INDEX(PropertyAddress, ',', 1)) + 3) AS Address2
FROM
  PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;
  
  
  
  -- Add PropertySplitAddress column
  
ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
ADD PropertySplitAddress NVARCHAR(255);

-- Update PropertySplitAddress column with substring up to the first comma
UPDATE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

-- Add PropertySplitCity column

ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
ADD PropertySplitCity NVARCHAR(255);

-- Update PropertySplitCity column with substring after the first comma

UPDATE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHAR_LENGTH(SUBSTRING_INDEX(PropertyAddress, ',', 1)) + 3);

SELECT *
FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;

-----------------------------------------------------------------------------------------------
-- REMOVING DUPLICATE COLUMNS

ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
DROP COLUMN PropertySplitAddress;

ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
DROP COLUMN PropertySplitCity;

ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
DROP COLUMN FormattedSaleDate;


SELECT OwnerAddress
FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;

-----------------------------------------------------------------------------------------------------
-- SEPARATING CITY, STATE, ADDRESS FROM OWNERADDRESS
SELECT 
	SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1) AS AddressLine1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1) AS AddressLine2,
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1) AS AddressLine3
    FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;
    
    
    
    -- Add OwnerSplitAddress column
ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
ADD OwnerSplitAddress NVARCHAR(255);

-- Update OwnerSplitAddress with parsed address
UPDATE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1);

-- Add OwnerSplitCity column
ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
ADD OwnerSplitCity NVARCHAR(255);

-- Update OwnerSplitCity with parsed city
UPDATE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1);

-- Add OwnerSplitState column
ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
ADD OwnerSplitState NVARCHAR(255);

-- Update OwnerSplitState with parsed state
UPDATE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1);

---------------------------------------------------------------------------------------------------
-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
    END AS SoldAsVacantTranslated
FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`;

UPDATE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
SET SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
    END;
    
-------------------------------------------------------------------------------------------------------------------
    -- REMOVE DUPLICATES
    
    DELETE FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
    ) AS RowNumCTE
    WHERE row_num > 1
);


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID
) row_num

FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
)
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress; 

---------------------------------------------------------------------------------------------------------
-- DELETE UNUSED COLUMNS

ALTER TABLE PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

SELECT * FROM PortfolioProject2.`nashville housing data for data cleaning (reuploaded)`
    
    
    
    
    
    


    














