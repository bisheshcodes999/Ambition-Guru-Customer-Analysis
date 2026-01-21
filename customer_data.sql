-- Defining the schema to be used

use ag_customerdata;


DROP TABLE IF EXISTS staging_customers;

CREATE TABLE staging_customers (
    student_id TEXT,
    student_name TEXT,
    date_of_birth TEXT,
    district_name TEXT,
    country_name TEXT,
    app_registered_date TEXT,
    package_id TEXT,
    package_name TEXT,
    package_subscription_type TEXT,
    package_subscribed_date TEXT
) CHARACTER SET utf8mb4;

-- INFILE loading of the given data of the customers ( CSV )

-- LOAD DATA INFILE 'C:\Users\LEGION\OneDrive\Desktop\AG analysis\customer_data.csv' 
-- INTO TABLE staging_customers 
-- CHARACTER SET utf8mb4
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"' 
-- LINES TERMINATED BY '\n' 
-- IGNORE 1 ROWS;

-- SHOW VARIABLES LIKE "secure_file_priv";

SELECT * FROM staging_customers;
-- here the staging customers is just the lodaded customer dataset from the ETL stage 
SELECT package_name ambition_guru_final
FROM staging_customers 
WHERE package_name REGEXP '[^ -~]' 
LIMIT 20;

-- Creating a final table for the cleaned AG customer data: 

DESCRIBE staging_customers;


DROP TABLE IF EXISTS ambition_guru_final;
CREATE TABLE ambition_guru_final AS
SELECT 
    -- 1. Setting Student ID to INT dtype
    CAST(student_id AS UNSIGNED) AS student_id,
    
    -- 2. CLeaning the students name 
    TRIM(REGEXP_REPLACE(student_name, '[\\"\\(\\)_\\-]', '')) AS student_name,
    
    -- 3. Setting the date to the DOB standard (Y:M:D)
    DATE(STR_TO_DATE(date_of_birth, '%Y-%m-%d')) AS date_of_birth,
    
    -- 4. Setting district Name -> Handling NULLs and symbols
    COALESCE(NULLIF(TRIM(REGEXP_REPLACE(district_name, '[\\"\\(\\)_\\-]', '')), ''), 'Unknown') AS district,
    
    -- 5. Trimming country name
    TRIM(country_name) AS country,
    
    package_name,
    package_subscription_type AS subcription_type,
    
    -- 6. App Registered Date -> DATE format
    DATE(STR_TO_DATE(app_registered_date, '%Y-%m-%d %H:%i:%s')) AS app_registered_date,
    
    -- 7. Setting subscribe date -> standard DATE format 
    STR_TO_DATE(package_subscribed_date, '%Y-%m-%d %H:%i:%s') AS subscribed_at
    
FROM staging_customers
-- filters for selecting only the required and essential datas
WHERE 
	student_name NOT REGEXP 'test|demo|dummy|trial user'
    AND student_id != 0   
    AND student_name IS NOT NULL
    AND
    (
    DATE(STR_TO_DATE(date_of_birth, '%Y-%m-%d')) >= '1940-01-01' 
    AND DATE(STR_TO_DATE(date_of_birth, '%Y-%m-%d')) <= CURRENT_DATE
    OR date_of_birth IS NULL
    )
    AND (
        STR_TO_DATE(package_subscribed_date, '%Y-%m-%d %H:%i:%s') <= NOW()
        OR package_subscribed_date IS NULL
    );
    
-- After running this query only 3208842 records were imported in the next table as some of the dates were filtered from the staging customers data table 


-- selection of the data ie before the date 2000s
-- SELECT date_of_birth
-- FROM staging_customers
-- WHERE date_of_birth< 2000-00-00;


SELECT 
      subcription_type
FROM ambition_guru_final
WHERE subcription_type = 'paid';
