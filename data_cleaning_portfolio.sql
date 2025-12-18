-- ===================================================
-- DATA CLEANING PROJECT: Nashville Housing Data
-- Author: Min Khant Zaw
-- Date: 18 December 2025
-- Tools: PostgreSQL 17, pgAdmin
-- ===================================================


-- Project Overview:
-- This project demonstrates data quality improvement techniques on a real estate dataset
-- containing 56,000+ property sales records in Nashville, TN (2013-2016).
--
-- Key Skills Demonstrated:
-- Identifying and handling missing values
-- Using self-joins to populate missing data
-- Detecting and removing duplicate records
-- Data Integrity Verification
-- ===================================================



-- Step 1: Load the raw data into a staging table
CREATE TABLE nashville_house_data (
"Parcel ID" VARCHAR,
"Land Use" VARCHAR,
"Property Address" VARCHAR,
"Suite/ Condo #" VARCHAR,
"Property City" VARCHAR,
"Sale Date" VARCHAR,
"Sale Price" VARCHAR,
"Legal Reference" VARCHAR,
"Sold As Vacant" VARCHAR,
"Multiple Parcels Involved in Sale" VARCHAR,
"Owner Name" VARCHAR,
"Address" VARCHAR,
"City" VARCHAR,
"State" VARCHAR,
"Acreage" VARCHAR,
"Tax District" VARCHAR,
"Neighborhood" VARCHAR,
"image" VARCHAR,
"Land Value" VARCHAR,
"Building Value" VARCHAR,
"Total Value" VARCHAR,
"Finished Area" VARCHAR,
"Foundation Type" VARCHAR,
"Year Built" VARCHAR,
"Exterior Wall" VARCHAR,
"Grade" VARCHAR,
"Bedrooms" VARCHAR,
"Full Bath" VARCHAR,
"Half Bath" VARCHAR
);
-- Note: Use pgAdmin's import feature to load data from CSV into nashville_house_data table

-- Step 2: Import Data from CSV
-- (This step is performed using pgAdmin's import feature)
-- Right-click on the nashville_house_data table > Import/Export > Select CSV file > Configure options > Import

-- Step 3:
SELECT * FROM nashville_house_data LIMIT 10;
-- Preview the first 10 records to understand the data structure
-- Checking for missing values in key columns
SELECT
COUNT(*) - COUNT ("Property Address") as missing_property_address,
COUNT(*) - COUNT ("Owner Name") as missing_owner_name,
COUNT(*) - COUNT ("Sale Date") as missing_sale_date
FROM nashville_house_data;
-- Result: Found 159 missing property addresses, 31375 missing owner names, and 0 missing sale dates

-- Step 4: Populate Missing Property Addresses
SELECT
a."Parcel ID",
a."Property Address" as missing_address,
b."Property Address" as found_address
FROM nashville_house_data a
JOIN nashville_house_data b
ON a."Parcel ID" = b."Parcel ID"
AND a."Property Address" is NULL
AND b."Property Address" is NOT NULL
LIMIT 5;
-- Previewing records with missing property addresses to find matches


-- Update missing property addresses using self-join

UPDATE nashville_house_data a
SET "Property Address" = b."Property Address"
FROM nashville_house_data b
WHERE a."Parcel ID" = b."Parcel ID"
AND a."Property Address" is NULL
AND b."Property Address" is NOT NULL;

-- Verify that missing property addresses have been populated
SELECT COUNT(*) - COUNT ("Property Address") as missing_property_address
FROM nashville_house_data WHERE "Property Address" IS NULL;
-- Result: 143 missing property addresses remain

-- Step 5: Remove Duplicate Records
-- Identify duplicates based on Parcel ID and Sale Date
SELECT "Parcel ID", "Sale Date", "Sale Price",
COUNT(*) as duplicate_count
FROM nashville_house_data
GROUP BY "Parcel ID", "Sale Date", "Sale Price"
Having COUNT(*) >1
ORDER BY duplicate_count DESC
Limit 10;
-- Previewing duplicate records
-- Remove duplicates, keeping the first occurrence
-- Count total duplicate rows
WITH duplicate as (
SELECT "Parcel ID", "Sale Date", "Sale Price",
COUNT(*) as cnt FROM nashville_house_data
GROUP BY "Parcel ID", "Sale Date", "Sale Price"
Having COUNT(*) >1
)
SELECT SUM(cnt-1) as total_duplicate_count
FROM duplicate;
-- Result: 168 duplicate records found

-- Delete duplicate rows, keeping only one copy of each sale
DELETE FROM nashville_house_data
WHERE ctid NOT IN(
SELECT MIN(ctid)
FROM nashville_house_data
GROUP BY "Parcel ID", "Sale Date", "Sale Price"
);
-- Verify duplicates have been removed
WITH duplicate as (
SELECT "Parcel ID", "Sale Date", "Sale Price",
COUNT(*) as cnt FROM nashville_house_data
GROUP BY "Parcel ID", "Sale Date", "Sale Price"
Having COUNT(*) >1
)
SELECT SUM(cnt-1) as total_duplicate_count
FROM duplicate;
-- Result: 0 duplicate records remain

-- Step 6: Final Data Integrity Check
SELECT "Parcel ID", "Sale Date", "Sale Price",
COUNT(*) as duplicate_count
FROM nashville_house_data
GROUP BY "Parcel ID", "Sale Date", "Sale Price"
HAVING COUNT(*) > 1;
-- Result: No duplicates found, data cleaning complete

-- Final record count after cleaning

SELECT
COUNT(*) as total_records,
COUNT("Property Address") as records_with_address,
COUNT(*) - COUNT("Property Address") as missing_address,
COUNT(DISTINCT "Parcel ID") as unique_properties
FROM nashville_house_data;
-- Result: 55632 total records, 55489 with addresses, 143 missing addresses, 52345 unique properties


-- ===================================================
-- FINAL RESULTS
-- ===================================================
-- Total Records: 55,632 (168 duplicates removed)
-- Records with Address: 55,489 (16 missing addresses populated)
-- Missing Addresses: 143 (no matching Parcel ID available)
-- Unique Properties: 52,345
-- Data Quality Improvement: 99.7% of records now have complete address information
-- ===================================================


