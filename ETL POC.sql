create database pharma_db;
use pharma_db
show tables;

--creating connection between Azure and Snowflake using AZURE SAS token --

create or replace stage my_adls
URL = 'azure://adlsaidatapoc.blob.core.windows.net/pharmadatset12'
credentials = (AZURE_SAS_TOKEN ='sp=racwdlmeop&st=2025-09-17T08:54:04Z&se=2026-01-31T17:09:04Z&spr=https&sv=2024-11-04&sr=c&sig=U1zHvr32%2F015gCJ4Nyd3FBBKvsU7R1cUrPP8zmLaKEE%3D')

list @my_adls

-- Call the procedure with parameters
CALL copy_data('RAW_PHARMA','my_adls','CSV','pharma_dataset.csv');
CALL copy_data('RAW_PHARMA_JSON','my_adls','JSON','pharma_dataset.json');
--creating table RAW_PHARMA for CSV --

--#--copy activity for csv files --
--copy into RAW_PHARMA
     --from @my_adls/test/pharma_dataset.csv
     --file_format= (type = 'CSV')
     --ON_ERROR = CONTINUE
      
--DATA in RAW_PHARMA 
select * from RAW_PHARMA   

--copy activity for JSON files--
CREATE OR REPLACE TABLE RAW_PHARMA_JSON(
RAW_PHARMA VARIANT
);

--copy into RAW_PHARMA_JSON
     --from @my_adls/test/pharma_dataset.json
     --file_format= (type='JSON')
--   ON_ERROR = CONTINUE

--DATA in RAW_PHARMA_JSON 
select * from RAW_PHARMA_JSON

--creating a table RAW_PHARMA_JSON_TABULAR ---- to get json data in tabular form ---
select * from RAW_PHARMA_JSON_TABULAR

-- creating unioned table --
select * from  RAW_PHARMA_UNIONED
--created STG TABLE
--creating Stored Procedure to filter duplicates nulls and blanks and loading data to STG table 
--executing Stored Procedure
CALL SP_CLEAN_LOAD_PHARMA_DATA();
Select * from STG_PHARMA
--creating GOLD_PHARMA SCHEMA 
--Creating STORED PROCEDURE to filter data from STG_PHARMA table and loading into GOLD_PHARMA
--executing Stored procedure --
CALL SP_LOAD_GOLD_PHARMA();
SELECT * FROM GOLD_PHARMA;


