-- Defining the schema we will be working on 
USE ag_customerdata;


-- Calling and selecting all the fields of our dataset ( cleaned )

SELECT * 
FROM ambition_guru_final;

-- Learning more about the data table 

DESCRIBE ambition_guru_final;

-- everything looks fine now 

-- Understanding and gathering moreambition_guru_final insights
/* ================================================================================
1. Gathering different insights and analysis 
================================================================================
*/

-- Understanding the size and proportion of the various field sof the dataset 
-- Volume and size understanding of the data
SELECT 
	  COUNT(DISTINCT student_id) as total_students, -- to count the total number of unique students -> info about total unique system users
      COUNT(DISTINCT district) as total_districts,
      COUNT(DISTINCT country) as num_of_country,
      COUNT(DISTINCT package_name) as total_package_name,
      COUNT(DISTINCT subcription_type) as subcription_type
FROM ambition_guru_final;

-- Geographic understanding of the data 

-- Analyzing the top 5 performing districts by the proportion of count of students or customers
DROP VIEW IF EXISTS  Top5_districts;
CREATE VIEW  Top5_districts AS
SELECT 
	  district,
	  COUNT(district) as total_enrollments
FROM ambition_guru_final
GROUP BY district
ORDER BY total_enrollments DESC
LIMIT 5;
-- Here the largest district holding most number of students is unknown 
-- and the subscription type of the unknown parameter is the trial hence can mean the user could just skip the district part of the system

-- analyzing the unknown parameters 
SELECT 
    package_name, 
    subcription_type,
    COUNT(*) as unknown_count
FROM ambition_guru_final
WHERE district = 'Unknown'
GROUP BY package_name, subcription_type
ORDER BY unknown_count DESC;

-- Analyzing the least 5 performing districts by the proportion of count of students or customers 
DROP VIEW IF EXISTS  least5_districts;
CREATE VIEW  least5_districts AS
SELECT 
	  district,
	  COUNT(district) as total_enrollments
GROUP BY district
ORDER BY total_enrollments 
LIMIT 5;

-- Quality analysis of the given districts
SELECT 
    district,
    COUNT(DISTINCT student_id) as total_users,
    COUNT(subscribed_at) as total_subscriptions,
    -- Conversion Rate: What % actually subscribed?
    ROUND((COUNT(subscribed_at) * 100.0 / COUNT(DISTINCT student_id)), 2) as conversion_rate
FROM ambition_guru_final
WHERE district != 'Unknown'
GROUP BY district
HAVING total_users > 50 -- looking at the regions where there are more than 50 customers
ORDER BY conversion_rate 
LIMIT 10;


-- checking for the geographical proportions of the customer data that we have fetched 

SELECT 
	  CASE WHEN district IN ('Kathmandu','Bhaktapur','Lalitpur') THEN 'Inside Valley'
      ELSE 'Outside Valley'
      END AS region,
      COUNT(student_id) as total_students,
      COUNT(subscribed_at) as total_subscription
FROM ambition_guru_final
WHERE district != 'Unknown'
GROUP BY region;
-- insights gathered : no of students outside the valley > inside the valley 
      
      
SELECT 
    district, 
    package_name, 
    COUNT(*) as enrollments
FROM ambition_guru_final
WHERE district != 'Unknown'
GROUP BY district, package_name
ORDER BY enrollments DESC;
-- selection of the different districts according to the packages they sell

-- SELECT 
--     district, 
--     COUNT(student_id) as total_students,
--     AVG(DATEDIFF(subscribed_at, app_registered_date)) as decision_speed
-- FROM ambition_guru_final
-- WHERE district NOT IN ('Kathmandu', 'Lalitpur', 'Pokhara', 'Biratnagar') 
--   AND district != 'Unknown'
-- GROUP BY district
-- HAVING total_students > 100
-- ORDER BY total_students DESC;
WITH subs_type AS 
(
SELECT
	  subcription_type,
	  COUNT(subcription_type) as total_subscription_types
FROM ambition_guru_final
GROUP BY subcription_type
)
SELECT 
	  COUNT(*) as total_counts
FROM subs_type
GROUP BY total_subscription_types;
-- From the above query we can observe that most of the enrollments are based on trial based subscriptions
-- Selection of the package name that has largest or one of the largest number of customers ( students ) in that region 

SELECT 
	  district,
      package_name,
      COUNT(*) as total_enrollments
FROM ambition_guru_final
WHERE district != 'Unknown'
GROUP BY district, package_name
-- The groupby used above as a sub query helps us to access the total enrollments of diff districts -> diff package names from the dataset
HAVING total_enrollments > 500
ORDER BY total_enrollments DESC
LIMIT 10;
-- Hence we can observe that the top 10 districts that has the highest number of enrollemnts of students generally consists of SEE english medium as their subject 

-- Calculation of the different districts and the proportion of the free using users VS the paid users of that region 

-- SELECT COUNT(*) as total_counts
-- FROM ambition_guru_final;

CREATE VIEW vw_ExecutivePaymentSummary AS
SELECT 
    district,
    COUNT(student_id) AS total_enrollments,
    -- Assuming 1 = Paid, 0 = Unpaid from our dataset
    SUM(CASE WHEN subcription_type = 'Paid' THEN 1 ELSE 0 END) AS total_paid,
    SUM(CASE WHEN subcription_type = 'Scholarship' OR 'Free' OR 'Trial' THEN 1 ELSE 0 END) AS total_unpaid,
    CAST(SUM(CASE WHEN subcription_type = 'Paid' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(student_id) AS PaidPercentage
FROM ambition_guru_final
GROUP BY district;



SELECT 
    district,
    COUNT(student_id) AS total_enrollments,
    -- Corrected Paid Count
    SUM(CASE WHEN subcription_type = 'Paid' THEN 1 ELSE 0 END) AS total_paid,
    -- Corrected Unpaid Count using IN
    SUM(CASE WHEN subcription_type IN ('Scholarship', 'Free', 'Trial') THEN 1 ELSE 0 END) AS total_unpaid,
    -- Accurate Paid Percentage (avoiding division by zero)
    CAST(SUM(CASE WHEN subcription_type = 'Paid' THEN 1 ELSE 0 END) AS FLOAT) 
    / NULLIF(COUNT(student_id), 0) AS PaidPercentage
FROM ambition_guru_final
GROUP BY district
ORDER BY PaidPercentage DESC;
-- SELECT 
-- 		DISTINCT subcription_type 
-- FROM ambition_guru_final;

-- selection of all the datas that contains the information about the total paid enrollemnts and unpaid enrollments 

-- selection of the total paid and unpaid enrollments from our dataset

SELECT 
      SUM(CASE WHEN subcription_type = 'Paid' THEN 1 END) as Total_paid,
      SUM(CASE WHEN subcription_type IN ('Scholarship' ,'Free' ,'Trial')  THEN 1 END) as Total_unpaid
FROM ambition_guru_final;

-- 2nd phase : Deep dive into the data set 

SELECT * 
FROM ambition_guru_final;
-- generally the deep dive comprises of the valuation of the different revenues generated over the different year courses


-- WITH district_dob_empty AS 
-- (
-- SELECT 
-- 	  student_name,
--       district,
--       date_of_birth,
--       subcription_type
-- FROM ambition_guru_final
-- WHERE date_of_birth IS NULL
-- )

-- Different labeling of the age groups that we have 
-- 1 - 15 
-- 16 - 24 
-- 25 - 39 
-- 40 - 54 
-- 54 + 

/* ================================================================================
1. Deep Dive -> Proportions and Revenue Analysis
================================================================================
*/


-- Funnel expansions checks-> checking the proportions of the TRIAL to PAID category of the subscription types

-- selecting the required subscription types only from the given dataset

DROP VIEW IF EXISTS subs_type;
CREATE VIEW subs_type AS 
SELECT 
    subcription_type, 
    COUNT(student_id) AS total_count
FROM ambition_guru_final
WHERE subcription_type IN ('trial', 'paid')
GROUP BY subcription_type;


-- calculating the conversion rate for the paid users / total users
 
SELECT 
	  COUNT(student_id) as total_enrollments,
      COUNT(CASE WHEN 'subcription_type' = 'paid' THEN 1 END) as total_paid
      -- COUNT(CASE WHEN 'subcription_type' = 'paid' THEN 1 END ) * 100 / COUNT(student_id) as conversion_rate_percent
FROM ambition_guru_final;

SELECT 
	  subcription_type
FROM ambition_guru_final
WHERE subcription_type = 'paid';


SELECT 
    package_name,
    COUNT(student_id) AS total_enrollments,
    COUNT(CASE WHEN subcription_type = 'paid' THEN 1 END) AS paid_enrollments,
    ROUND(COUNT(CASE WHEN subcription_type = 'paid' THEN 1 END) * 100.0 / COUNT(student_id), 2) AS conversion_rate_percent
FROM ambition_guru_final
WHERE package_name <> 'CHECK' -- Removes the test data you identified
GROUP BY package_name
ORDER BY conversion_rate_percent DESC;

-- selecting only the top 5 packages -> as per their conversion rates
CREATE VIEW conversion_top5 AS 
SELECT 
    package_name,
    COUNT(student_id) AS total_enrollments,
    COUNT(CASE WHEN subcription_type = 'paid' THEN 1 END) AS paid_enrollments,
    ROUND(COUNT(CASE WHEN subcription_type = 'paid' THEN 1 END) * 100.0 / COUNT(student_id), 2) AS conversion_rate_percent
FROM ambition_guru_final
WHERE package_name <> 'CHECK' -- Removes the test data you identified
GROUP BY package_name
ORDER BY conversion_rate_percent DESC
LIMIT 5;

-- filtering for the different ages and the age groups of the students 

SELECT 
    AVG(
    FLOOR(DATEDIFF('2026-01-14', date_of_birth) / 365.25)) AS average_age
FROM ambition_guru_final
WHERE date_of_birth IS NOT NULL 
  AND date_of_birth > '1900-01-01';

-- Calculation of the retention rates of the students and the customers 

CREATE VIEW retention_rate AS
SELECT 
    COUNT(CASE WHEN subcription_type IN ('trial', 'free') THEN 1 END) AS total_free_users,
    COUNT(CASE WHEN subcription_type = 'paid' THEN 1 END) AS total_paid_users,
    ROUND(
        COUNT(CASE WHEN subcription_type = 'paid' THEN 1 END) * 100.0 / 
        COUNT(student_id), 
    2) AS retention_rate_percent
FROM ambition_guru_final
WHERE package_name <> 'CHECK'; 



SELECT 
    district, 
    COUNT(CASE WHEN subcription_type = 'paid' THEN 1 END) AS paid_students,
    COUNT(student_id) AS total_students,
    ROUND(COUNT(CASE WHEN subcription_type = 'paid' THEN 1 END) * 100.0 / COUNT(student_id), 2) AS conversion_density
FROM ambition_guru_final
GROUP BY district
HAVING total_students > 100 
ORDER BY conversion_density DESC;

-- enrollment intensity of the units 
CREATE VIEW enrollment_intensity AS
SELECT 
    COUNT(student_id) AS total_enrollments,
    COUNT(DISTINCT student_id) AS unique_students,
    -- Calculation: Total rows divided by unique IDs
    ROUND(
        COUNT(student_id) * 1.0 / COUNT(DISTINCT student_id),
    2) AS enrollment_intensity
FROM ambition_guru_final
WHERE package_name <> 'CHECK'; 


-- filtering for the different packages types
SELECT 
package_name FROM ambition_guru_final;

-- selection of top5 countries

SELECT 
	  country,
      COUNT(student_id) as total_students
FROM ambition_guru_final
GROUP BY country
HAVING total_students > 200
ORDER BY total_students DESC
LIMIT 5;

--
SELECT 
    CASE 
        WHEN package_name LIKE '%SEE%' OR package_name LIKE '%Grade 10%' OR package_name LIKE '%कक्षा १०%' 
            THEN 'SEE Exam Prep'
        WHEN package_name LIKE '%नेपाली%' OR package_name LIKE '%Nepali%' 
            THEN 'Nepali Package'
        WHEN package_name LIKE '%Math%' 
            THEN 'Maths Package'
        WHEN package_name LIKE '%शिक्षक सेवा%' OR package_name LIKE '%TSC%' 
            THEN 'TSC Prep'
        ELSE 'Other Courses'
    END AS package_group,
    COUNT(student_id) AS total_students
FROM ambition_guru_final
GROUP BY package_group
ORDER BY total_students DESC;

SELECT 
    CASE 
        WHEN rank <= 5 THEN district 
        ELSE 'Other Districts' 
    END AS district_group,
    SUM(paid_count) AS total_paid
FROM (
    SELECT 
        district, 
        COUNT(*) AS paid_count,
        RANK() OVER (ORDER BY COUNT(*) DESC) as rank
    FROM ambition_guru_final
    WHERE subcription_type = 'paid'
    GROUP BY district
) AS ranked_data
GROUP BY 1
ORDER BY total_paid DESC;