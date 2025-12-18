# SQL Data Cleaning Portfolio Project

## Overview
This project demonstrates data cleaning and quality improvement techniques using **PostgreSQL** on a real-world dataset containing 56,000+ Nashville housing sales records (2013-2016).

## Skills Demonstrated
- Data quality assessment
- NULL value handling with self-joins
- Duplicate detection and removal
- SQL query optimization
- Data integrity verification

## Tools Used
- **Database:** PostgreSQL 17
- **Interface:** pgAdmin 4
- **Language:** SQL

## Dataset
Nashville Housing Data (2013-2016)
- **Source:** Public real estate sales records
- **Size:** 56,636 records initially
- **Final Size:** 55,632 records (after cleaning)
- **Columns:** 29 fields including Parcel ID, Property Address, Sale Date, Sale Price, Owner information

---

## Data Cleaning Tasks

### 1. Populate Missing Property Addresses
**Problem:** 159 records had NULL property addresses

**Solution:** Used self-join to match Parcel IDs and copy addresses from other sales of the same property

UPDATE nashville_house_data a
SET "Property Address" = b."Property Address"
FROM nashville_house_data b
WHERE a."Parcel ID" = b."Parcel ID"
AND a."Property Address" IS NULL
AND b."Property Address" IS NOT NULL;

**Verification:**

SELECT COUNT(*)
FROM nashville_house_data
WHERE "Property Address" IS NULL;

**Result:** Successfully populated 16 missing addresses. 143 addresses remain NULL (no matching Parcel ID available in dataset).


### 2. Remove Duplicate Records
**Problem:** Multiple entries for the same property sale

**Step 1: Identify duplicates**

WITH duplicate AS (
SELECT "Parcel ID", "Sale Date", "Sale Price", COUNT() as cnt
FROM nashville_house_data
GROUP BY "Parcel ID", "Sale Date", "Sale Price"
HAVING COUNT() > 1
)
SELECT SUM(cnt - 1) as total_duplicate_count
FROM duplicate;

**Result:** Found 168 duplicate records

**Step 2: Remove duplicates**
DELETE FROM nashville_house_data
WHERE ctid NOT IN (
SELECT MIN(ctid)
FROM nashville_house_data
GROUP BY "Parcel ID", "Sale Date", "Sale Price"
);


**Result:** Successfully removed 168 duplicate records, keeping only unique sales

---

## Final Data Quality Summary

| Metric | Count |
|--------|-------|
| Total Records | 55,632 |
| Records with Address | 55,489 |
| Missing Addresses | 143 |
| Unique Properties | 52,345 |
| Data Completeness | 99.7% |

---

## Files in This Repository
- `nashville_data_cleaning.sql` - Complete SQL script with all cleaning queries
- `README.md` - Project documentation (this file)

## How to Use
1. Download the Nashville Housing dataset
2. Import into PostgreSQL database
3. Run the queries in `nashville_data_cleaning.sql`
4. Verify results using the verification queries at the end

---

## Author
**Min Khant Zaw**
Software Engineering Student | TAMK

**Technical Skills:** SQL, PostgreSQL, Tableau, Java, Spring Boot, Docker

## Connect With Me
- 💼 [LinkedIn](https://www.linkedin.com/in/minzaw)
- 💻 [GitHub](https://github.com/mkzaw25101999)
