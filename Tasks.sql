---Tasks --
-- Task 1: Cleans and loads staging
CREATE OR REPLACE TASK TASK_CLEAN_LOAD_PHARMA
  WAREHOUSE = COMPUTE_WH              
  SCHEDULE = '1 minute'
AS
CALL SP_CLEAN_LOAD_PHARMA_DATA();

-- Task 2: Loads Gold Pharma, depends on Task 1
CREATE OR REPLACE TASK TASK_LOAD_GOLD_PHARMA
  WAREHOUSE = COMPUTE_WH
  AFTER TASK_CLEAN_LOAD_PHARMA
AS
CALL SP_LOAD_GOLD_PHARMA();

--- maunal run 
EXECUTE TASK TASK_LOAD_GOLD_PHARMA;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(TASK_NAME => 'TASK_LOAD_GOLD_PHARMA'))
ORDER BY SCHEDULED_TIME DESC;
  -- Optional: Filter by specific task name
--retrieve records for tasks run 
SELECT query_text, completed_time
FROM snowflake.account_usage.task_history
WHERE completed_time > DATEADD(hours, -1, CURRENT_TIMESTAMP());


show tasks;

Alter task TASK_CLEAN_LOAD_PHARMA resume;

Alter task TASK_LOAD_GOLD_PHARMA resume;