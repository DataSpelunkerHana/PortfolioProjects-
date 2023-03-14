# DATA CLEANING USING SQL 

USE portfolioproject;

SELECT 
    *
FROM
    nashvillehousing;

SELECT 
    saledate
FROM
    nashvillehousing;


# 1 STANDARDIZE DATE FORMAT


SELECT 
    STR_TO_DATE(saledate, '%M %d,%Y') as saledateconverted
FROM
    NashvilleHousing;
    
ALTER TABLE NashvilleHousing
ADD saledateconverted date;


UPDATE NashvilleHousing 
SET 
    saledateconverted = STR_TO_DATE(saledate, '%M %d,%Y');

--------------------------------------------------------------

# 2 POPULATE PROPERTY ADDRESS DATA

SELECT 
    *
FROM
    nashvillehousing
WHERE
    propertyaddress is null;
    
    
SELECT 
    *
FROM
    nashvillehousing
order by parcelid;
    
    
SELECT 
    a.parcelid,
    a.propertyaddress,
    b.parcelid,
    b.propertyaddress,
    ifnull(a.propertyaddress,b.propertyaddress)
FROM
    nashvillehousing a
        JOIN
    nashvillehousing b ON a.parcelid = b.parcelid
        AND a.uniqueid <> b.uniqueid
WHERE
    a.propertyaddress IS NULL;


    
UPDATE nashvillehousing a
        JOIN
nashvillehousing b ON a.parcelid = b.parcelid
        AND a.uniqueid <> b.uniqueid 
SET 
    a.propertyaddress = IFNULL(a.propertyaddress, b.propertyaddress)
WHERE
    a.propertyaddress IS NULL;
    
--------------------------------------------------------------

# 3 BREAKING OUT ADDRESS INTO INDIVIDUAL COULUMNNS (ADDRESS, CITY, STATE)

SELECT 
    propertyaddress
FROM
    nashvillehousing;
    
SELECT 
    SUBSTRING(propertyaddress,
        1,
        LOCATE(',', propertyaddress) - 1) AS address,
    SUBSTRING(propertyaddress,
        LOCATE(',', propertyaddress) + 1,
        length(propertyaddress)) AS address
FROM
    nashvillehousing;


/* ADDING NEW COLUMNS TO UPDATE THE ADDRESS AND CITY COLUMNS IN PROPERTYADDRESS */


ALTER TABLE NashvilleHousing
ADD propertysplitaddress varchar(255);


UPDATE NashvilleHousing 
SET 
    propertysplitaddress = SUBSTRING(propertyaddress,
        1,
        LOCATE(',', propertyaddress) - 1);
    

ALTER TABLE NashvilleHousing
ADD propertysplitcity varchar(255);


UPDATE NashvilleHousing 
SET 
    propertysplitcity = SUBSTRING(propertyaddress,
        LOCATE(',', propertyaddress) + 1,
        length(propertyaddress));
        
SELECT 
    *
FROM
    nashvillehousing;
    
--------------------------------------------------------------

# 3  ADDING NEW COLUMNS TO UPDATE THE ADDRESS, CITY AND STATE COLUMNS FOR OWNERADDRESS 
    
SELECT 
    owneraddress
FROM
    nashvillehousing;
    

    SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', 1) AS address1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) AS address2,
    SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -1), ',', -1) AS address3
FROM
    nashvillehousing;
    
    
ALTER TABLE NashvilleHousing
ADD ownersplitaddress varchar(255);


UPDATE NashvilleHousing 
SET 
    ownersplitaddress = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',',1);


ALTER TABLE NashvilleHousing
ADD ownersplitcity varchar(255);


UPDATE NashvilleHousing 
SET 
    ownersplitcity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1);
        

ALTER TABLE NashvilleHousing
ADD ownersplitstate varchar(255);


UPDATE NashvilleHousing 
SET 
    ownersplitstate = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', -1), ',', -1);
    
SELECT 
    *
FROM
    nashvillehousing;
    
--------------------------------------------------------------

# 4 CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN 'SOLDASVACANT' FIELD

SELECT DISTINCT
    (soldasvacant), COUNT(soldasvacant)
FROM
    nashvillehousing
GROUP BY soldasvacant
ORDER BY 2;


SELECT 
    soldasvacant,
    CASE
        WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END
FROM
    nashvillehousing;
    
    
UPDATE nashvillehousing 
SET 
    soldasvacant = CASE
        WHEN soldasvacant = 'Y' THEN 'Yes'
        WHEN soldasvacant = 'N' THEN 'No'
        ELSE soldasvacant
    END;
    
    
--------------------------------------------------------------
# 5 REMOVE DUPLICATE ROWS 

WITH RowNumCTE AS (
SELECT *, 
row_number() OVER( 
PARTITION BY 
	parcelid, 
    propertyaddress, 
    saleprice, 
    saledate, 
    legalreference
	ORDER BY uniqueid
	)row_num
 FROM nashvillehousing
 )
 SELECT * FROM RowNumCTE WHERE row_num > 1 
 ORDER BY propertyaddress;
 
 
 
WITH RowNumCTE AS (
SELECT *, 
row_number() OVER( 
PARTITION BY 
	parcelid, 
    propertyaddress, 
    saleprice, 
    saledate, 
    legalreference
	ORDER BY uniqueid
	) as row_num
 FROM nashvillehousing
 )
 DELETE FROM RowNumCTE WHERE row_num > 1 ;
# ORDER BY propertyaddress;
# THE ABOVE QUERY TO DELETE DUPLICATE VALUES DOESN'T WORK ON MYSQL.

# USE THIS QUERY TO DELETE DUPLICATE VALUES IN MYSQL

delete FROM nashvillehousing 
  where uniqueid in(
  select * from (
select *,row_number() over 
(partition by 
	parcelid, 
    propertyaddress, 
    saleprice, 
    saledate, 
    legalreference
    order by uniqueid
    ) as rn
    from ne ) x
    where x.rn > 1)
    ;
    
    
--------------------------------------------------------------
# REMOVE UNUSED COLUMNS

SELECT 
    *
FROM
    nashvillehousing;
    
alter table nashvillehousing 
drop column PropertyAddress, 
drop column OwnerAddress, 
drop column TaxDistrict,
drop column SaleDate;

---------------------------------------------------------------
