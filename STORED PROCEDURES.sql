-- created store procdure for parameterized copy activity

CREATE OR REPLACE PROCEDURE copy_data(table_name STRING, stage_name STRING, file_type STRING, file_name STRING)
RETURNS STRING
LANGUAGE SQL
AS
BEGIN
    EXECUTE IMMEDIATE
    'COPY INTO ' || table_name ||
    ' FROM @' || stage_name || '/' || file_name ||' 
    FILE_FORMAT = (TYPE = '''|| file_type ||''')'||'ON_ERROR =''CONTINUE''';
    RETURN 'Copy completed successfully!';
    END;


--creating Stored Procedure to filter duplicates nulls and blanks and loading data to STG table 

CREATE OR REPLACE PROCEDURE SP_CLEAN_LOAD_PHARMA_DATA()
RETURNS STRING
LANGUAGE SQL
AS
BEGIN
   -- clear STG before loading (so it has only fresh clean data)
   TRUNCATE TABLE STG_PHARMA;
   -- Insert clean, deduplicated data into STG
   INSERT INTO STG_PHARMA
   SELECT
       DRUG_ID,
       DRUG_NAME,
       GENERIC_NAME,
       MANUFACTURER,
       DOSAGE_FORM,
       STRENGTH_MG,
       PRICE_INR,
       APPROVAL_DATE,
       EXPIRY_DATE,
       BATCH_NUMBER,
       QUANTITY_IN_STOCK,
       THERAPEUTIC_AREA,
       PRESCRIPTION_REQUIRED,
       ATC_CODE,
       STORAGE_TEMP_C
   FROM (
       SELECT
           *,
           ROW_NUMBER() OVER (PARTITION BY DRUG_ID ORDER BY APPROVAL_DATE DESC) AS RN
       FROM RAW_PHARMA_UNIONED
       WHERE DRUG_ID IS NOT NULL
         AND DRUG_NAME IS NOT NULL AND TRIM(DRUG_NAME) <> ''
         AND MANUFACTURER IS NOT NULL AND TRIM(MANUFACTURER) <> ''
   )
   WHERE RN = 1;
   RETURN 'Clean data loaded successfully into STG_PHARMA';
END;



--Creating STORED PROCEDURE to filter data from STG_PHARMA table and loading into GOLD_PHARMA

CREATE OR REPLACE PROCEDURE SP_LOAD_GOLD_PHARMA()
RETURNS STRING
LANGUAGE SQL
AS
BEGIN
     -- clear Gold before loading (so it has only fresh clean data)
    TRUNCATE TABLE GOLD_PHARMA;
     -- Insert only tablets from staging into gold
    INSERT INTO GOLD_PHARMA
    SELECT *
    FROM STG_PHARMA
    WHERE UPPER(DOSAGE_FORM) = 'TABLET';
 
    RETURN 'Data load into GOLD_PHARMA completed successfully.';
END;


