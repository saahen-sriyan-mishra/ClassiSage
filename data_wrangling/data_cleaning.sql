-- Step 0: Create the table structure (if not already done)
CREATE TABLE final_dataset (
    BlockId NVARCHAR(50) NOT NULL,
    Features NVARCHAR(MAX) NOT NULL,
    TimeInterval NVARCHAR(MAX) NOT NULL,
    Latency INT NOT NULL,
    Label NVARCHAR(50) NOT NULL,
    Type FLOAT NULL,
    E1 TINYINT NULL,
    E2 TINYINT NULL,
    E3 TINYINT NULL,
    E4 TINYINT NULL,
    E5 TINYINT NULL,
    E6 TINYINT NULL,
    E7 TINYINT NULL,
    E8 TINYINT NULL,
    E9 TINYINT NULL,
    E10 TINYINT NULL,
    E11 TINYINT NULL,
    E12 TINYINT NULL,
    E13 TINYINT NULL,
    E14 TINYINT NULL,
    E15 TINYINT NULL,
    E16 TINYINT NULL,
    E17 TINYINT NULL,
    E18 TINYINT NULL,
    E19 TINYINT NULL,
    E20 TINYINT NULL,
    E21 TINYINT NULL,
    E22 TINYINT NULL,
    E23 TINYINT NULL,
    E24 TINYINT NULL,
    E25 TINYINT NULL,
    E26 TINYINT NULL,
    E27 TINYINT NULL,
    E28 TINYINT NULL,
    E29 TINYINT NULL
);

-- Load data into the table (specific to SQL Server)
INSERT INTO final_dataset (BlockId, Features, TimeInterval, Latency, Label, Type, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16, E17, E18, E19, E20, E21, E22, E23, E24, E25, E26, E27, E28, E29)
SELECT *
FROM OPENROWSET(
    BULK 's3://<bucket_name>/final_dataset.csv',
    FORMAT = 'CSV',
    FIRSTROW = 2
) AS DataFile;

-- Display the contents of the final dataset
-- SELECT * FROM final_dataset;

-- Create a temporary table from final_dataset
SELECT * INTO #final_dataset_x
FROM final_dataset;

-- Alter the temporary table to drop unnecessary columns
ALTER TABLE #final_dataset_x
DROP COLUMN Features, TimeInterval;

-- BlockId needed for splitting

-- Create temp tables based on the Type column
SELECT * INTO #success_table
FROM #final_dataset_x
WHERE Type IS NULL;

SELECT * INTO #fail_table
FROM #final_dataset_x
WHERE Type IS NOT NULL;

-- Display the contents of the temp tables
-- SELECT * FROM #success_table;
-- SELECT * FROM #fail_table;

-- Drop the Type column from both temp tables
ALTER TABLE #success_table
DROP COLUMN Type;

ALTER TABLE #fail_table
DROP COLUMN Type;

-- Display the updated contents
-- SELECT * FROM #success_table;
-- SELECT * FROM #fail_table;

-- Split the success_table into 80% and 20% random samples
-- Extract 80% of random rows from #success_table into #80_success_table
SELECT *
INTO #80_success_table
FROM (
    SELECT *, NEWID() AS RandomOrder  -- Use NEWID() to randomize the order
    FROM #success_table
) AS Randomized
ORDER BY RandomOrder
OFFSET 0 ROWS 
FETCH NEXT CAST(ROUND(0.8 * (SELECT COUNT(*) FROM #success_table), 0) AS INT) ROWS ONLY;  -- Ensure it's an integer

-- Extract the remaining 20% of rows into #20_success_table
SELECT *
INTO #20_success_table
FROM #success_table
WHERE BlockId NOT IN (SELECT BlockId FROM #80_success_table);

-- Checking the contents of the tables
-- SELECT * FROM #80_success_table;
-- SELECT * FROM #20_success_table;

-- Split the fail_table into 80% and 20% random samples
-- Extract 80% of random rows from #fail_table into #80_fail_table
SELECT *
INTO #80_fail_table
FROM (
    SELECT *, NEWID() AS RandomOrder  -- Use NEWID() to randomize the order
    FROM #fail_table
) AS Randomized
ORDER BY RandomOrder
OFFSET 0 ROWS 
FETCH NEXT CAST(ROUND(0.8 * (SELECT COUNT(*) FROM #fail_table), 0) AS INT) ROWS ONLY;  -- Ensure it's an integer

-- Extract the remaining 20% of rows into #20_fail_table
SELECT *
INTO #20_fail_table
FROM #fail_table
WHERE BlockId NOT IN (SELECT BlockId FROM #80_fail_table);

-- Checking the contents of the tables
-- SELECT * FROM #80_fail_table;
-- SELECT * FROM #80_fail_table;

-- Step 9: Drop unwanted data columns
ALTER TABLE #80_success_table
DROP COLUMN RandomOrder;

ALTER TABLE #80_fail_table
DROP COLUMN RandomOrder;

-- Cleanup: Drop temporary tables
DROP TABLE #fail_table;
DROP TABLE #success_table;
DROP TABLE #final_dataset_x;  -- Dropping the original temp table for cleanup

-- Concatenate #80_success_table and #80_fail_table into #80_table
SELECT * INTO #80_table
FROM #80_success_table
UNION ALL
SELECT * FROM #80_fail_table;

-- Concatenate #20_success_table and #20_fail_table into #20_table
SELECT * INTO #20_table
FROM #20_success_table
UNION ALL
SELECT * FROM #20_fail_table;

-- Concatenate All
SELECT * INTO #table
FROM #80_table
UNION ALL
SELECT * FROM #20_table;

-- Create final_dataset from #table
-- Drop the existing final_dataset if it exists
IF OBJECT_ID('final_dataset', 'U') IS NOT NULL
    DROP TABLE final_dataset;

-- Create final_dataset from #table
SELECT * INTO final_dataset
FROM #table;


-- Drop all temporary tables
DROP TABLE #80_success_table;
DROP TABLE #20_success_table;
DROP TABLE #80_fail_table;
DROP TABLE #20_fail_table;
DROP TABLE #80_table;
DROP TABLE #20_table;

-- Drop the BlockId column from final_dataset
ALTER TABLE final_dataset
DROP COLUMN BlockId;

SELECT * FROM final_dataset;


-- UPLOADING
-- Export the final_dataset to an S3 bucket
DECLARE @bucketName NVARCHAR(256) = '<bucket-name>';
DECLARE @filePath NVARCHAR(256) = 'final_dataset_x.csv';  -- File path within the S3 bucket
DECLARE @query NVARCHAR(MAX);

-- Define the query that exports the data
SET @query = '
    SELECT * 
    FROM final_dataset';

-- Call the stored procedure to upload the data to S3
EXEC msdb.dbo.rds_upload_to_s3
    @bucket_name = @bucketName,
    @s3_prefix = @filePath,
    @query = @query,
    @overwrite_file = 1;  -- 1 to overwrite the file if it exists

-- NOTE    
-- Permissions: Make sure the IAM role attached to your RDS instance has the proper permissions (s3:PutObject) for the S3 bucket.
-- S3 Bucket Location: The S3 bucket must be in the same region as your RDS instance.
-- IAM Role Attachment: Ensure that the IAM role is correctly attached to the RDS instance using the AWS Management Console, AWS CLI, or SDK.