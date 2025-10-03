
--creating a table RAW_PHARMA_JSON_TABULAR ---- to get json data in tabular form ---

insert into RAW_PHARMA_JSON_TABULAR
select
f.value:"DRUG_ID"::string as DRUG_ID,
f.value:"DRUG_NAME"::string as DRUG_NAME,
f.value:"GENERIC_NAME"::string as GENERIC_NAME,
f.value:"MANUFACTURER"::string as MANUFACTURER,
f.value:"DOSAGE_FORM"::string as DOSAGE_FORM,
f.value:"STRENGTH_MG"::number(10, 2) as STRENGTH_MG,
f.value:"PRICE_INR"::number(10, 2) as PRICE_INR,
f.value:"APPROVAL_DATE"::date as APPROVAL_DATE,
f.value:"EXPIRY_DATE"::date as EXPIRY_DATE,
f.value:"BATCH_NUMBER"::string as BATCH_NUMBER,
f.value:"QUANTITY_IN_STOCK"::number as QUANTITY_IN_STOCK,
f.value:"THERAPEUTIC_AREA"::string as THERAPEUTIC_AREA,
f.value:"PRESCRIPTION_REQUIRED"::string as PRESCRIPTION_REQUIRED,
f.value:"ATC_CODE"::string as ATC_CODE,
f.value:"STORAGE_TEMP_C"::string as STORAGE_TEMP_C
from RAW_PHARMA_JSON,
lateral flatten (input =>  raw_pharma:"DRUGS")f;

select * from RAW_PHARMA_JSON_TABULAR