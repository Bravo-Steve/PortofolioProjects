--Cleaning Data in SQL Queries

select* 
from dbo.NashvilleHousing 

--Standardize Date Format

select SaleDateConverted, CONVERT(date, SaleDate)
from dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,Saledate)

alter table nashvillehousing
add SaleDateConverted Date

update NashvilleHousing
set saleDateconverted = CONVERT(date,saledate)


--Populate Property Address data

select *
from dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress,
ISNULL(A.PropertyAddress,B.PropertyAddress)
from dbo.NashvilleHousing A
join dbo.NashvilleHousing B
    on A.ParcelID = B.ParcelID
	and A.UniqueID <> B.UniqueID
Where A.PropertyAddress is null 

update A
set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from dbo.NashvilleHousing A
join dbo.NashvilleHousing B
    on A.ParcelID = B.ParcelID
	and A.UniqueID <> B.UniqueID
Where A.PropertyAddress is null 


--Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, Charindex(',',PropertyAddress)-1) as Address
,SUBSTRING(propertyAddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) as Address
--,Charindex(',',PropertyAddress)
from dbo.NashvilleHousing 


alter table nashvillehousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',',PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar (255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))

select* 
from dbo.NashvilleHousing


select OwnerAddress 
from dbo.NashvilleHousing

select 
PARSENAME(Replace(owneraddress,',','.'),3)
,PARSENAME(Replace(owneraddress,',','.'),2)
,PARSENAME(Replace(owneraddress,',','.'),1)
from dbo.NashvilleHousing



alter table nashvillehousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(owneraddress,',','.'),3)


alter table nashvillehousing
add OwnerSplitCity nvarchar (255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(owneraddress,',','.'),2)


alter table nashvillehousing
add OwnerSplitState nvarchar (255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(owneraddress,',','.'),1)


select* 
from dbo.NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,Case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant =Case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from dbo.NashvilleHousing


--Remove Duplicates

with RowNumCTE as (
select *,
ROW_NUMBER()over(Partition by ParcelID,
                              PropertyAddress,
							  SalePrice,
							  SaleDate,
							  LegalReference
							  order by UniqueID) row_num
from dbo.NashvilleHousing
--order by ParcelID
)
--select*
--from RowNumCTE
--where row_num > 1 
--order by PropertyAddress

Delete
from RowNumCTE
where row_num > 1 
--order by PropertyAddress

