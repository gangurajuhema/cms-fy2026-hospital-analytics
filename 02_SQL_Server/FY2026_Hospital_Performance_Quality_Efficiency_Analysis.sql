

USE CMS_FY2026_HVBP;

--1. Validates the total number of records available in the cleaned TPS dataset.
SELECT 'TPS_cleaned' AS TABLE_NAME,
COUNT(*) AS TOTAL_ROWS
FROM dbo.TPS_CLEANED;


--2. validate record counts across the Safety,Engagement,Clinical and Efficiency Cleaned Tables
SELECT  'safety_cleaned', COUNT(*) AS COUNT
FROM dbo.safety_cleaned;

SELECT 'Engagement_cleaned',COUNT(*)
FROM dbo.Engagement_cleaned;

SELECT 'clinical_cleaned', COUNT(*)
FROM dbo.clinical_cleaned;

SELECT 'Efficiency_cleaned', count(*) 
from dbo.Efficiency_cleaned;


--3. Identify duplicate hospital records in the TPS table using Fiscal Year and Facility ID.
SELECT [FISCAL_YEAR],
       [FACILITY_ID],
       COUNT(*) AS DUPLICATE_COUNT
       FROM dbo.tps_cleaned
       GROUP BY 
       [FISCAL_YEAR],
       [FACILITY_ID]
       HAVING COUNT(*) > 1;


--4. Check missing Fiscal Year, Facility ID and Total Performance Score values in the TPS table       
SELECT COUNT(*) AS TOTAL_ROWS,
SUM(CASE WHEN [FISCAL_YEAR] IS NULL THEN 1 ELSE 0 END) AS missing_fiscal_year,
SUM(CASE WHEN [FACILITY_ID] IS NULL THEN 1 ELSE 0 END) AS Missing_facility_ID,
SUM(CASE WHEN [TOTAL_PERFORMANCE_SCORE] IS NULL THEN 1  ELSE 0 END) AS Missinng_TPS
FROM dbo.TPS_cleaned;

--5. Check missing Fiscal Year and Facility ID values in the Safety table.
SELECT COUNT(*) AS TOTAL_ROWS,
SUM(CASE WHEN [FISCAL_YEAR] IS NULL THEN 1 ELSE 0 END) AS MISSING_FISCAL_YEAR,
SUM(CASE WHEN [FACILITY_ID] IS NULL THEN 1 ELSE 0 END) AS MISSING_FACILITY_ID
FROM dbo.safety_cleaned;


--6. Identify duplicate hospital records in the Engagement table using Fiscal Year and Facility ID.
SELECT FISCAL_YEAR,
       [FACILITY_ID],
       COUNT(*) AS TOTAL_ROWS
       FROM dbo.Engagement_cleaned
       GROUP BY 
       FISCAL_YEAR,
       [FACILITY_ID]
       HAVING COUNT(*) > 1;


--7. Check missing Fiscal Year and Facility ID values in the Engagement table.
SELECT COUNT(*) AS TOTAL_ROWS,
SUM(CASE WHEN [FISCAL_YEAR] IS NULL THEN 1 ELSE 0 END) AS MISSING_FISCAL_YEAR,
SUM(CASE WHEN  [FACILITY_ID] IS NULL THEN 1 ELSE 0 END) AS MISSING_FACILITY_ID
FROM dbo.ENGAGEMENT_CLEANED;


--8. Identify Safety records missing from the TPS table and TPS records missing from the Safety table.
SELECT 'SAFETY_CLEANED' AS COMPARED_TABLE,
(SELECT COUNT(*) FROM dbo.safety_cleaned s
WHERE NOT EXISTS (
SELECT 1
FROM dbo.TPS_cleaned t
WHERE t.Fiscal_Year = s.Fiscal_Year
AND T.Facility_ID = s.Facility_ID)) AS Rows_not_in_TPS,
(SELECT COUNT(*) FROM dbo.TPS_cleaned t
WHERE NOT EXISTS (
SELECT 1
FROM dbo.safety_cleaned s
WHERE S.Fiscal_Year = T.Fiscal_Year AND
s.Facility_ID = t.Facility_ID)) AS TPS_Rows_in_table


--9.Compare hospital records between Engagement and TPS tables to identify unmatched records.
SELECT 'ENGAGEMENT_CLEANED'
(SELECT COUNT(*)
FROM dbo.Engagement_cleaned e
WHERE NOT EXISTS (
SELECT 1
FROM dbo.TPS_cleaned t
WHERE t.Fiscal_Year = e.Fiscal_Year AND
t.Facility_ID =  e.Facility_ID));
(SELECT COUNT(*)
FROM dbo.TPS_cleaned T
WHERE NOT EXISTS (
SELECT 1
FROM dbo.Engagement_cleaned e
WHERE e.Fiscal_Year = t.Fiscal_Year
AND e.Facility_ID = t.Facility_ID))


--10. Identify Efficiency records missing from the TPS table and TPS records missing from the Efficiency table.
SELECT 'EFFICIENCY_CLEANED',
(SELECT  COUNT(*)
FROM dbo.Efficiency_cleaned e
WHERE NOT EXISTS (
SELECT 1
FROM dbo.TPS_cleaned t
WHERE t.Fiscal_Year = e.Fiscal_Year
AND t.Facility_ID = e.Facility_ID)),
(SELECT COUNT(*) 
FROM dbo.TPS_cleaned t
WHERE NOT EXISTS (
SELECT 1
FROM dbo.Efficiency_cleaned e
WHERE E.Fiscal_Year = T.Fiscal_Year 
AND E.Facility_ID = T.Facility_ID));


--11. Retrieve column names, data types and nullability information for the TPS table.
SELECT COLUMN_NAME,
       DATA_TYPE,
       IS_NULLABLE
       FROM INFORMATION_SCHEMA.COLUMNS
       WHERE TABLE_NAME = 'TPS_CLEANED'
       ORDER BY ORDINAL_POSITION;



--12. Validate the minimum and maximum TPS values and identify scores outside the expected 0–100 range.
SELECT 
MIN([TOTAL_PERFORMANCE_SCORE]) as minimum_tps,
MAX([TOTAL_PERFORMANCE_SCORE]) AS MAXIMUM_TPS,
SUM(CASE
        WHEN [TOTAL_PERFORMANCE_SCORE] < 0 OR [TOTAL_PERFORMANCE_SCORE] > 100 THEN 1 ELSE 0 END) AS SCORES_OUTSIDE_0_TO_100
        FROM dbo.TPS_cleaned;


--13. Locate database tables containing TPS in their names.
 SELECT TABLE_SCHEMA,TABLE_NAME
 FROM INFORMATION_SCHEMA.TABLES
 WHERE TABLE_TYPE = 'BASE TABLE'
 AND TABLE_NAME LIKE '%TPS%';


 --14. Calculate the total hospital count and overall TPS average, minimum and maximum.
 SELECT COUNT(*) AS TOTAL_ROWS,
 COUNT([TOTAL_PERFORMANCE_SCORE]) AS HOSPITALS_WITH_TPS,
 AVG([TOTAL_PERFORMANCE_sCORE]) AS AVG_TPS,
 MIN([TOTAL_PERFORMANCE_SCORE]) AS MIN_TPS,
 MAX([TOTAL_PERFORMANCE_SCORE]) AS MAX_TPS
 FROM dbo.TPS_cleaned;

 --15. Classify hospitals into TPS performance bands and calculate the hospital count in each band.
SELECT 
CASE 
WHEN [TOTAL_PERFORMANCE_SCORE] <=25 THEN '0-25'
WHEN [TOTAL_PERFORMANCE_SCORE] <=50 THEN 'ABOVE 25-50'
WHEN [TOTAL_PERFORMANCE_SCORE] <=75 THEN 'ABOVE 50-75'
WHEN [TOTAL_PERFORMANCE_SCORE] <=100 THEN 'ABOVE 75-100' ELSE 'OUTSIDE_RANGE' END AS TPS_Performance_Band,
COUNT(*)  AS hopsital_count
FROM dbo.TPS_Cleaned
GROUP BY 
CASE 
WHEN [TOTAL_PERFORMANCE_SCORE] <=25 THEN '0-25'
WHEN [TOTAL_PERFORMANCE_SCORE] <=50 THEN 'ABOVE 25-50'
WHEN [TOTAL_PERFORMANCE_SCORE] <=75 THEN 'ABOVE 50-75'
WHEN [TOTAL_PERFORMANCE_SCORE] <=100 THEN 'ABOVE 75-100' ELSE 'OUTSIDE_RANGE' END 
ORDER BY MIN([TOTAL_PERFORMANCE_SCORE]);


--16. Identify the ten states with the highest number of hospitals and calculate their average TPS.
SELECT TOP 10
STATE,
COUNT(*) AS HOSPITAL_COUNT,
AVG([TOTAL_PERFORMANCE_sCORE]) AS AVG_TPS
FROM dbo.TPS_cleaned
GROUP BY STATE
ORDER BY Hospital_count DESC;


--17. Identify the ten states with the highest average TPS.
SELECT TOP 10
STATE,
COUNT(*) AS HOSPITAL_COUNT,
AVG([TOTAL_PERFORMANCE_SCORE]) AS AVG_TPS
FROM dbo.TPS_cleaned
GROUP BY STATE
ORDER BY AVG_TPS DESC;


--18. Retrieve the ordered column positions, names and data types of the TPS table.
SELECT ORDINAL_POSITION,
       COLUMN_NAME,
       DATA_TYPE
       FROM INFORMATION_SCHEMA.COLUMNS
       WHERE TABLE_SCHEMA = 'dbo'
       AND TABLE_NAME = 'TPS_Cleaned'
       ORDER BY ORDINAL_POSITION;


--19. Calculate hospital count and average, maximum and minimum weighted Clinical, Engagement,Safety, Efficiency And Cost Reduction Outcomes scores.
SELECT 
'CLINICAL_OUTCOMES' AS DOMAIN,
COUNT(WEIGHTED_SCORE) AS HOSPITALS_WITH_SCORE,
CAST(AVG(WEIGHTED_SCORE) AS DECIMAL(10,2)) AS AVG_SCORE,
CAST(MAX(WEIGHTED_SCORE) AS DECIMAL(10,2)) AS MAXIMUM_SCORE,
CAST(MIN(WEIGHTED_SCORE) AS DECIMAL(10,2)) AS MINIMUM_SCORE
FROM (
SELECT Weighted_Normalized_clinical_outcomes_Domain_score as Weighted_Score
from dbo.TPS_cleaned) as Clinical

SELECT 'PERSON_AND_COMMUNITY_ENGAGEMENT',
COUNT(WEIGHTED_SCORE),
CAST(AVG(WEIGHTED_SCORE) AS DECIMAL(10,2)),
CAST(MAX(WEIGHTED_SCORE) AS DECIMAL(10,2)),
CAST(MIN(WEIGHTED_SCORE) AS DECIMAL(10,2))
FROM(
SELECT Weighted_Person_And_Community_Engagement_Domain_Score as weighted_Score
from dbo.TPS_cleaned) as Engagement

SELECT 'SAFETY',
COUNT(WEIGHTED_SCORE),
CAST(AVG(WEIGHTED_SCORE) AS DECIMAL(10,2)),
CAST(MIN(weighted_Score) AS DECIMAL(10,2)),
CAST(MAX(WEIGHTED_SCORE) AS DECIMAL(10,2))
FROM(
SELECT weighted_Safety_domain_score as weighted_Score
FROM dbo.TPS_Cleaned) AS SAFETY

SELECT 'EFFICIENCY_AND_COST_REDUCTION',
COUNT(WEIGHTED_SCORE),
CAST(AVG(WEIGHTED_SCORE) AS DECIMAL(10,2)),
CAST(MIN(WEIGHTED_SCORE) AS DECIMAL(10,2)),
CAST(MAX(WEIGHTED_sCORE) AS DECIMAL(10,2))
FROM  (
SELECT weighted_efficiency_and_cost_reduction_domain_score AS Weighted_score 
FROM dbo.TPS_cleaned
) as Efficiency;


--20.Measure score availability and missing weighted scores across all four performance domains
SELECT COUNT(*) AS TOTAL_HOSPITALS,
COUNT(WEIGHTED_NORMALIZED_CLINICAL_OUTCOMES_DOMAIN_SCORE) AS CLINICAL_SCORES_AVAILABLE,
COUNT(*) -
COUNT(WEIGHTED_NORMALIZED_CLINICAL_OUTCOMES_DOMAIN_sCORE) AS CLINICAL_SCORE_MISSING,

COUNT(weighted_person_and_community_engagement_domain_score) as engagement_scores_available,
count(*) - 
count(weighted_person_and_community_engagement_domain_score) as engagement_Score_missing,

COUNT(weighted_safety_domain_score) as safety_scores_available,
count(*) - 
count(weighted_safety_domain_score) as safety_scores_missing,

COUNT(weighted_efficiency_and_cost_reduction_domain_score) as efficiency_scores_available,
count(*) - 
count(weighted_efficiency_and_cost_reduction_domain_score) as efficiency_scores_missing
from dbo.TPS_cleaned;


--21.Retrieve the installed SQL Server version and build information.
SELECT @@VERSION AS SQL_SERVER_VERSION;


--22. Calculate Pearson Correlations Between TPS and each Weighted quality - domain Score.
WITH Domainscores AS
( 
SELECT TOTAL_PERFORMANCE_scORE AS TPS,

weighted_normalized_clinical_outcomes_domain_score as clinical,

weighted_person_and_community_engagement_domain_Score AS engagement,

weighted_safety_domain_score as safety,

weighted_efficiency_and_cost_reduction_domain_Score as efficiency
 
from dbo.TPS_cleaned
),
correlationInputs as
(
select 
'clinical_outcomes' as Domain,
TPS,
Clinical as DomainScore
from Domainscores
where TPS is not null and clinical is not null

union all

SELECT 
'PERSON_AND_COMMUNITY_ENGAGEMENT',TPS,Engagement
from DomainScores
where TPS is not null and Engagement is not null

union all

select 'safety',TPS,Safety
from DomainScores
where TPS is not null and safety is not null

union all

select 'efficiency_cost_reduction',TPS,Efficiency
from DomainScores
where TPS is not null and efficiency is not null
),
means as
(
select 
domain,
count(*) as hospitalscompared,
avg(TPS) as meantps,
AVG(DomainScore) as meandomain
from correlationInputs
group by Domain
),
CorrelationParts as
(
select 
c.domain,
c.tps,
c.DomainScore,
m.hospitalscompared,
m.meantps,
m.meandomain
from correlationInputs c
join means m
on c.domain = m.domain
)
select 
domain,
max(hospitalscompared) as hospitalscompared,
cast(sum((tps - meantps) * (DomainScore - MeanDomain))
/
nullif(sqrt(sum(power(tps - meanTPS,2)) *
sum(power(DomainScore - MeanDomain,2))
),
0
)
as decimal(10,4)
) as pearson_correlation
from correlationparts
group by domain
order by pearson_correlation desc;

--23. Comapre average Weighted Domain Scores between Hospitals above and or below the overall TPS threshols of 30.88
WITH HospitalGroups AS
( 
SELECT 
CASE 
WHEN Total_Performance_Score  > 30.88 THEN 'HIGHER_TPS' ELSE 'LOWER_OR_EQUAL_TPS'
END AS  PERFORMANCE_GROUP,

weighted_normalized_clinical_outcomes_domain_score AS CLINICAL,

weighted_person_and_community_engagement_domain_score  AS Engagement,

weighted_safety_domain_score AS Safety,

weighted_efficiency_and_cost_reduction_domain_score As Efficiency

FROM dbo.TPS_cleaned
WHERE Total_Performance_Score IS NOT NULL
)
SELECT PERFORMANCE_GROUP,
COUNT(*) AS HOSPITAL_COUNT,
CAST(AVG(Clinical) as decimal(10,2))
AS AVG_CLINICAL_SCORE,
CAST(AVG(Engagement) as decimal(10,2)) AS AVG_Engagement_Score,
CAST(AVG(SAFETY) AS DECIMAL (10,2)) AS AVG_Safety_Score,
CAST(AVG(Efficiency) as decimal(10,2)) as AVG_Efficiency_score
FROM HospitalGroups
Group by PERFORMANCE_GROUP
order by PERFORMANCE_GROUP;

--24. Compare average TPS across states with at least 30 hospitals 
SELECT 
STATE,
COUNT(*) AS Hospital_count,
CAST(AVG(Total_Performance_Score) AS DECIMAL(10,2)) AS Avg_TPS
FROM dbo.TPS_cleaned
WHERE Total_Performance_Score IS NOT NULL
GROUP BY STATE
HAVING COUNT(*) >=30
ORDER BY Avg_TPS DESC;
 
--25.Compare state - level Avg TPS and weighted Efficiency Scores for ststes with at least 30 hospitals
SELECT 
STATE,
COUNT(*) AS Hospital_Count,
CAST(AVG(TOtal_Performance_SCore) AS DECIMAL(10,2)) AS  Avg_TPS,
CAST(AVG(Weighted_Efficiency_And_Cost_reduction_domain_score) AS DECIMAL(10,2)) AS AVG_EFFICIENCY_SCORE
FROM dbo.TPS_Cleaned
WHERE Total_Performance_Score IS NOT NULL
GROUP BY STATE
HAVING COUNT(*) >=30
ORDER BY Avg_TPS DESC;

--26.Calculate the pearson correlation between state - level Avg TPS and average weighted Efficiency Scores
WITH Stateaverages AS
(
SELECT 
STATE,
AVG(Total_Performance_Score) AS x,
AVG(Weighted_Efficiency_And_cost_Reduction_Domain_Score) AS y
FROM dbo.TPS_cleaned
WHERE Total_Performance_Score IS NOT NULL
GROUP BY STATE
HAVING  COUNT(*) >=30
),
CorrelationParts AS
(
SELECT 
COUNT(*) AS n,
SUM(x*y) AS sumXY,
SUM(x) AS sumX,
SUM(y) AS sumY,
SUM(x*x) AS SumX2,
SUM(y*y)AS sumY2
FROM Stateaverages
)
SELECT 
CAST((n*sumXY - sumX * sumY)
/
NULLIF(SQRT((n*sumX2 - sumX * sumX)
*
(n*sumY2 - sumY * sumY)
),
0
) AS DECIMAL(10,4)
) AS State_Average_Correlation
FROM correlationparts;

--27. Calculate the difference between State - level Average TPS and average weighted efficinecy  Scores
SELECT 
STATE,
COUNT(*) AS Hospital_count,
CAST(AVG(Total_Performance_Score) AS DECIMAL(10,2)) AS Avg_TPS,
CAST(AVG(weighted_Efficiency_And_Cost_Reduction_Domain_Score)
 AS DECIMAL(10,2)) AS Avg_Efficiency,
CAST(AVG(Total_Performance_Score) 
-
AVG(Weighted_Efficiency_And_Cost_Reduction_Domain_Score)
AS DECIMAL(10,2)) AS Score_Gap
FROM dbo.TPS_cleaned
WHERE Total_Performance_Score IS NOT NULL
GROUP BY STATE
HAVING COUNT(*) >=30
ORDER BY Score_Gap DESC;

--28.Identify states with atleast 30 hospitals that have the lowest average weighted efficiency scores
SELECT 
STATE,
COUNT(*) AS Hospital_count,
CAST(AVG(Weighted_Efficiency_And_Cost_Reduction_Domain_Score) AS DECIMAL(10,2)) AS Avg_Efficiency
FROM dbo.TPS_cleaned
WHERE
Weighted_Efficiency_And_Cost_Reduction_Domain_Score IS NOT NULL
GROUP BY STATE
HAVING COUNT(*) >=30
ORDER BY Avg_Efficiency ASC;

--29.Calculate Hospital count, score availability, missing values and descriptive statistics for weighted safety scores
SELECT 
COUNT(*) AS Total_Hospitals,
COUNT(Weighted_Safety_Domain_Score) AS Available_Scores,
COUNT(*) - COUNT(Weighted_Safety_Domain_Score) AS MISSING_SCORES,
CAST(AVG(Weighted_Safety_Domain_Score) AS DECIMAL(10,2)) AS Avg_Safety_Score,
CAST(MIN(Weighted_Safety_Domain_Score) AS DECIMAL(10,2)) AS MIN_sAFETY_SCORE,
CAST(MAX(Weighted_Safety_Domain_Score) AS DECIMAL(10,2)) AS MAX_SAFETY_sCORE
FROM dbo.TPS_cleaned;

--30.Calculate Hospital count, score availability, missing values and descriptive statistics for weighted Clinical outcomes Scores
SELECT 
COUNT(*) AS Total_Hospitals,
COUNT(Weighted_Normalized_Clinical_Outcomes_Domain_Score) AS Available_Scores,
COUNT(*) -
COUNT(Weighted_Normalized_Clinical_Outcomes_Domain_Score) AS MISSING_sCORES,
CAST(AVG(Weighted_Normalized_Clinical_outcomes_Domain_Score) AS DECIMAL(10,2)) AS Avg_clinical_Score,
CAST(MIN(Weighted_Normalized_Clinical_outcomes_Domain_Score) AS DECIMAL(10,2)) AS MIN_CLINICAL_SCORE,
CAST(MAX(Weighted_Normalized_Clinical_outcomes_Domain_Score) AS DECIMAL(10,2)) AS MAX_CLINICAL_SCORE
FROM dbo.TPS_cleaned;

--31. Calculate Hospital count, score availability, missing values and descriptive statistics for weighted Engagement Scores
SELECT 
COUNT(*) AS Total_Hospitals,
COUNT(Weighted_Person_And_community_Engagement_Domain_Score) AS Available_Scores,
COUNT(*) -
COUNT(Weighted_Person_And_community_Engagement_Domain_Score) AS Missing_Scores,
CAST(AVG(Weighted_Person_And_community_Engagement_Domain_Score) AS DECIMAL(10,2)) AS AVG_SCORE,
CAST(MIN(Weighted_Person_And_community_Engagement_Domain_Score) AS DECIMAL (10,2)) AS MIN_SCORE,
CAST(MAX(Weighted_Person_And_community_Engagement_Domain_Score) AS DECIMAL (10,2)) AS MAX_SCORE
FROM dbo.TPS_cleaned;

--32. Identify TPS table columns containg the term Engagement
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TPS_CLEANED'
AND COLUMN_NAME LIKE '%ENGAGEMENT%';

--33. Comapre weightedd Engagement and clinical outcomes score avialbility and average score
SELECT 
COUNT(*) AS Total_Hospitals,
COUNT(Weighted_Person_And_community_Engagement_Domain_Score) AS Available_Scores,
COUNT(*) -
COUNT(Weighted_Person_And_community_Engagement_Domain_Score) AS Missing_Scores,
CAST(AVG(Weighted_Person_And_community_Engagement_Domain_Score) AS DECIMAL(10,2)) AS AVG_SCORE,
COUNT(Weighted_Normalized_Clinical_Outcomes_Domain_Score) AS Clinical_Available,
COUNT(*) -
COUNT(Weighted_Normalized_Clinical_Outcomes_Domain_Score) AS Clinical_Missing,
CAST(AVG(Weighted_Normalized_Clinical_Outcomes_Domain_Score) AS DECIMAL(10,2)) AS AVG_clinical
FROM dbo.TPS_cleaned;

--34.Validate the total number of records, distinct fiscal years and unique facility ID in the TPS table 
SELECT 
COUNT(*) AS TOTAL_ROWS,
COUNT(DISTINCT FISCAL_YEAR) AS FISCAL_YEARS,
COUNT(DISTINCT FACILITY_ID) AS UNIQUE_FACILITY_IDS
FROM dbo.TPS_cleaned;

--35. Identify Engagement table columns related to HCAHPS base and consistency scores
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ENGAGEMENT_CLEANED'
AND (COLUMN_NAME LIKE '%BASE%SCORE%' OR COLUMN_NAME LIKE 
'%CONSISTENCY%SCORE%')

--36. Analyse the availabiltiy, missinng values, avg, min and max of HCAHPS base and consistency Scores
SELECT 
COUNT(*) AS TOTAL_ROWS,
COUNT(Hcahps_Base_Score) AS Base_Available,
COUNT(*) -
COUNT(Hcahps_Base_Score) AS BASE_MISSING,
CAST(AVG(Hcahps_Base_Score) AS DECIMAL(10,2)) AS Average_BAse_Score,
MIN(Hcahps_Base_Score) AS MIN_BASE_SCORE,
MAX(Hcahps_Base_Score) AS MAX_BASE_SCORE,

COUNT(Hcahps_Consistency_Score) AS  CONSISTENCY_AVAILABLE,
COUNT(*) -
COUNT(Hcahps_Consistency_Score) AS CONSISTENCY_MISSING,
CAST(AVG(Hcahps_Consistency_Score) AS DECIMAL(10,2)) AS  AVG_CONSISTENCY_sCORE,
MIN(Hcahps_Consistency_Score) AS MINIMUM_CONSISTENCY_SCORE,
MAX(Hcahps_Consistency_Score) AS MAXIMUM_cONSISTENCY_SCORE
FROM dbo.Engagement_cleaned;


--37. The distribution of hospitals across Weighted Safety ranges and calculate their percentage of total
WITH safetyGroups AS
(
SELECT 
CASE WHEN Weighted_Safety_Domain_Score < 5 THEN '0 TO <5'
WHEN Weighted_Safety_Domain_Score < 10 THEN '5 TO <10'
WHEN Weighted_Safety_Domain_Score < 20 THEN '10 TO <20' ELSE '20 TO 33.33'
END AS Safety_score_Range
FROM dbo.TPS_cleaned
WHERE weighted_Safety_Domain_Score IS NOT NULL
)
SELECT 
Safety_Score_Range,
COUNT(*) AS Hospital_Count,
CAST(100.0 * COUNT(*) / SUM(COUNT(*))
OVER() AS DECIMAL(5,2)
) AS PERCENTAGE_OF_HOSPITALS
FROM safetyGroups
GROUP BY Safety_score_range
ORDER BY CASE Safety_Score_range
WHEN '0 TO <5' THEN 1
WHEN '5 TO <10' THEN 2
WHEN '10 TO <20' THEN 3
ELSE 4
END;


--38. Retrieves the column names and datatypes of the clinical outcomes table
SELECT COLUMN_NAME,
DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CLINICAL_CLEANED'
ORDER BY ORDINAL_POSITION;


--39. Compltete hospital data avilability and avg performance rates across six clinical outcomes measures.
SELECT '30-DAY AMI MORTALITY' AS CLINICAL_MEASURE,
COUNT(MORT_30_AMI_Performance_Rate) AS AVAILABLE_HOSPITALS,
AVG(MORT_30_AMI_Performance_Rate) AS Avg_Performance_Rate
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY Heart Failure Mortality',
COUNT(MORT_30_HF_Performance_Rate),
AVG(MORT_30_HF_Performance_Rate)
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY Pneumonia Mortality',
COUNT(MORT_30_PN_Performance_Rate),
AVG(MORT_30_PN_Performance_Rate)
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY COPD Mortality',
COUNT(MORT_30_COPD_Performance_Rate),
AVG(MORT_30_COPD_Performance_Rate)
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY CABG Mortality',
COUNT(MORT_30_CABG_Performance_Rate),
AVG(MORT_30_CABG_Performance_Rate)
FROM dbo.clinical_cleaned

UNION ALL

SELECT 'Hip/Knee Complications',
COUNT(COMP_HIP_KNEE_Performance_Rate),
AVG(COMP_HIP_KNEE_Performance_Rate)
FROM dbo.clinical_cleaned;

--40. THe min, max and avg performance rates across six clinical outcomes measures
SELECT '30-DAY AMI MORTALITY' AS CLINICAL_MEASURE,
COUNT(MORT_30_AMI_Performance_Rate) AS AVAILABLE_HOSPITALS,
AVG(MORT_30_AMI_Performance_Rate) AS Avg_Performance_Rate,
MIN(MORT_30_AMI_Performance_Rate) AS Min_Performance_Rate,
MAX(MORT_30_AMI_Performance_Rate) AS Max_Performance_Rate
FROM dbo.clinical_cleaned

UNION ALL

SELECT 
'30-DAY Heart Failure Mortality',
COUNT(MORT_30_HF_Performance_Rate),
AVG(MORT_30_HF_Performance_Rate),
MIN(MORT_30_HF_Performance_Rate),
MAX(MORT_30_HF_Performance_Rate)
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY Pneumonia Mortality',
COUNT(MORT_30_PN_Performance_Rate),
AVG(MORT_30_PN_Performance_Rate),
MIN(MORT_30_PN_Performance_Rate),
MAX(MORT_30_PN_Performance_Rate)
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY COPD Mortality',
COUNT(MORT_30_COPD_Performance_Rate),
AVG(MORT_30_COPD_Performance_Rate),
MIN(MORT_30_COPD_Performance_Rate),
MAX(MORT_30_COPD_Performance_Rate)
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY CABG Mortality',
COUNT(MORT_30_CABG_Performance_Rate),
AVG(MORT_30_CABG_Performance_Rate),
MIN(MORT_30_CABG_Performance_Rate),
MAX(MORT_30_CABG_Performance_Rate)
FROM dbo.clinical_cleaned

UNION ALL

SELECT 'Hip/Knee Complications',
COUNT(COMP_HIP_KNEE_Performance_Rate),
AVG(COMP_HIP_KNEE_Performance_Rate),
MIN(COMP_HIP_KNEE_Performance_Rate),
MAX(COMP_HIP_KNEE_Performance_Rate)
FROM dbo.clinical_cleaned;

--41. Insepect sample benchmark, baseline and performance- rate values across the six clinical outcome measures.
SELECT TOP (5)
MORT_30_AMI_Benchmark,
MORT_30_AMI_Baseline_Rate,
MORT_30_AMI_Performance_Rate,
MORT_30_HF_Benchmark,
MORT_30_HF_Baseline_Rate,
MORT_30_HF_Performance_Rate,
MORT_30_PN_Benchmark,
MORT_30_PN_Baseline_Rate,
MORT_30_PN_Performance_Rate,
MORT_30_COPD_Benchmark,
MORT_30_COPD_Baseline_Rate,
MORT_30_COPD_Performance_Rate,
MORT_30_CABG_Benchmark,
MORT_30_CABG_Baseline_Rate,
MORT_30_CABG_Performance_Rate,
COMP_HIP_KNEE_Benchmark,
COMP_HIP_KNEE_Baseline_Rate,
COMP_HIP_KNEE_Performance_Rate
FROM dbo.clinical_cleaned;

--42. Compare hospital performance rates, achivement thresholds and CMS benchmarks across sux clinical measures
SELECT '30-DAY AMI Survival' AS Clinical_Measure,
COUNT(MORT_30_AMI_Performance_Rate) AS Available_Hospitals,
AVG(MORT_30_AMI_Performance_Rate) AS Avg_Rate,
MAX(MORT_30_AMI_Achievement_Threshold) AS Achivement_Threshold,
MAX(MORT_30_AMI_Benchmark) AS CMS_Benchmark
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY Heart Failure Survival',
COUNT(MORT_30_HF_Performance_Rate),
AVG(MORT_30_HF_Performance_Rate),
MAX(MORT_30_HF_Achievement_Threshold),
MAX(MORT_30_HF_Benchmark) 
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY Pneumonia Survival',
COUNT(MORT_30_PN_Performance_Rate),
AVG(MORT_30_PN_Performance_Rate),
MAX(MORT_30_PN_Achievement_Threshold),
MAX(MORT_30_PN_Benchmark)
FROM dbo.clinical_cleaned

UNION ALL

SELECT '30-DAY COPD Survival',
COUNT(MORT_30_COPD_Performance_Rate),
AVG(MORT_30_COPD_Performance_Rate),
MAX(MORT_30_COPD_Performance_Rate),
MAX(MORT_30_COPD_Benchmark)
FROM dbo.Clinical_Cleaned

UNION ALL

SELECT '30-DAY CABG Survival',
COUNT(MORT_30_CABG_Performance_Rate),
AVG(MORT_30_CABG_Performance_Rate),
MAX(MORT_30_CABG_Achievement_Threshold),
MAX(MORT_30_CABG_Benchmark)
FROM dbo.clinical_cleaned

UNION ALL

SELECT 'HIP/KNEE Complications',
COUNT(COMP_HIP_KNEE_Performance_Rate),
AVG(COMP_HIP_KNEE_Performance_Rate),
MAX(COMP_HIP_KNEE_Achievement_Threshold),
MAX(COMP_HIP_KNEE_Benchmark)
FROM dbo.clinical_cleaned;

--43. Calculate the percentage of Hospitals meeting CMS benchmarks across six clinical measures, with direction - adjusted criteria for complications
WITH MeasureResults AS
(
    SELECT
        'AMI Survival' AS Measure,
        MORT_30_AMI_Performance_Rate AS Performance_Rate,
        MORT_30_AMI_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'Heart Failure Survival' AS Measure,
        MORT_30_HF_Performance_Rate AS Performance_Rate,
        MORT_30_HF_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'Pneumonia Survival' AS Measure,
        MORT_30_PN_Performance_Rate AS Performance_Rate,
        MORT_30_PN_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'COPD Survival' AS Measure,
        MORT_30_COPD_Performance_Rate AS Performance_Rate,
        MORT_30_COPD_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'CABG Survival' AS Measure,
        MORT_30_CABG_Performance_Rate AS Performance_Rate,
        MORT_30_CABG_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'Hip/Knee Complications' AS Measure,
        COMP_HIP_KNEE_Performance_Rate AS Performance_Rate,
        COMP_HIP_KNEE_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned
)
SELECT
    Measure,
    COUNT(*) AS Available_Hospitals,
    SUM(
        CASE
            WHEN Measure = 'Hip/Knee Complications'
                 AND Performance_Rate <= Benchmark THEN 1
            WHEN Measure <> 'Hip/Knee Complications'
                 AND Performance_Rate >= Benchmark THEN 1
            ELSE 0
        END
    ) AS Hospitals_Meeting_Benchmark,  
    CAST(
        100.0 * SUM(
            CASE
                WHEN Measure = 'Hip/Knee Complications'
                     AND Performance_Rate <= Benchmark THEN 1
                WHEN Measure <> 'Hip/Knee Complications'
                     AND Performance_Rate >= Benchmark THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Percentage_Meeting_Benchmark
FROM MeasureResults
WHERE Performance_Rate IS NOT NULL
GROUP BY Measure
ORDER BY Measure;

--44. Comapre avg clinical performance rates against CMS benchmarks using directiob - adjusted performance gaps.
WITH MeasureResults AS
(
    SELECT
        'AMI Survival' AS Measure,
        MORT_30_AMI_Performance_Rate AS Performance_Rate,
        MORT_30_AMI_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'Heart Failure Survival' AS Measure,
        MORT_30_HF_Performance_Rate AS Performance_Rate,
        MORT_30_HF_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'Pneumonia Survival' AS Measure,
        MORT_30_PN_Performance_Rate AS Performance_Rate,
        MORT_30_PN_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'COPD Survival' AS Measure,
        MORT_30_COPD_Performance_Rate AS Performance_Rate,
        MORT_30_COPD_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'CABG Survival' AS Measure,
        MORT_30_CABG_Performance_Rate AS Performance_Rate,
        MORT_30_CABG_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned

    UNION ALL

    SELECT
        'Hip/Knee Complications' AS Measure,
        COMP_HIP_KNEE_Performance_Rate AS Performance_Rate,
        COMP_HIP_KNEE_Benchmark AS Benchmark
    FROM dbo.Clinical_Cleaned
)
SELECT
    Measure,
    COUNT(*) AS Available_Hospitals,
    AVG(Performance_Rate) AS Avg_Rate,
    MAX(Benchmark) AS Benchmark,
    AVG(
        CASE
            WHEN Measure = 'HIP/KNEE Complications' THEN Benchmark - Performance_rate  
            ELSE Performance_rate - Benchmark END) AS Direction_Adjusted_Gap
            FROM MeasureResults
WHERE Performance_Rate IS NOT NULL
GROUP BY Measure
ORDER BY Direction_Adjusted_Gap Desc;

--45. Analyse the avialbaility, avg,min,max values of HCAHPS base and consistency Scores.
SELECT 
COUNT(Hcahps_Base_Score) AS Base_Score_Available,
AVG(Hcahps_Base_Score) AS AVG_Score_Available,
MIN(Hcahps_Base_Score) AS MIN_Score_Available,
MAX(Hcahps_Base_Score) AS MAX_Score_Available,

COUNT(Hcahps_Consistency_Score) AS Consistency_Score_Available,
AVG(Hcahps_Consistency_Score) AS AVG_Score_Available,
MIN(Hcahps_Consistency_Score) AS MIN_Score_Available,
MAX(Hcahps_Consistency_Score) AS MAX_Score_Available
FROM dbo.Engagement_cleaned;

--46. Calculate the pearson correlation between HCAHPS base and consistency  score 
WITH ScoreBands AS
(
    SELECT
        CASE
            WHEN Hcahps_Base_Score < 20 THEN 1
            WHEN Hcahps_Base_Score < 40 THEN 2
            WHEN Hcahps_Base_Score < 60 THEN 3
            ELSE 4
        END AS Band_Order
    FROM dbo.Engagement_Cleaned
    WHERE Hcahps_Base_Score IS NOT NULL
)
SELECT
    CASE Band_Order
        WHEN 1 THEN 'Below 20'
        WHEN 2 THEN '20 to below 40'
        WHEN 3 THEN '40 to below 60'
        WHEN 4 THEN '60 to 80'
    END AS Base_Score_Band,
    COUNT(*) AS Hospital_Count,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage
FROM ScoreBands
GROUP BY Band_Order
ORDER BY Band_Order;

--47. HCAHPS base Score vs Consistency Score Correlation
SELECT
    COUNT(*) AS Hospitals_Compared,
    CAST(
        (
            COUNT(*) * SUM(
                CAST(Hcahps_Base_Score AS FLOAT)
                * CAST(Hcahps_Consistency_Score AS FLOAT)
            )
            - SUM(CAST(Hcahps_Base_Score AS FLOAT))
              * SUM(CAST(Hcahps_Consistency_Score AS FLOAT))
        )
        /
        NULLIF(
            SQRT(
                (
                    COUNT(*) * SUM(
                        CAST(Hcahps_Base_Score AS FLOAT)
                        * CAST(Hcahps_Base_Score AS FLOAT)
                    )
                    - POWER(
                        SUM(CAST(Hcahps_Base_Score AS FLOAT)), 2
                    )
                )
                *
                (
                    COUNT(*) * SUM(
                        CAST(Hcahps_Consistency_Score AS FLOAT)
                        * CAST(Hcahps_Consistency_Score AS FLOAT)
                    )
                    - POWER(
                        SUM(CAST(Hcahps_Consistency_Score AS FLOAT)), 2
                    )
                )
            ),
            0
        )
        AS DECIMAL(10,4)
    ) AS Correlation
FROM dbo.Engagement_Cleaned
WHERE Hcahps_Base_Score IS NOT NULL
  AND Hcahps_Consistency_Score IS NOT NULL;


--49. Identify Efficiency - related columns in TPS_Cleaned
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='TPS_CLEANED'
AND COLUMN_NAME LIKE '%EFFICIENCY%';


--50. weighted Efficiency Score Band Distribution
WITH Efficiencybands AS
( 
SELECT CASE WHEN weighted_Efficiency_And_Cost_Reduction_Domain_Score < 5 THEN 1
 WHEN weighted_Efficiency_And_Cost_Reduction_Domain_Score < 10 THEN 2
 WHEN weighted_Efficiency_And_Cost_Reduction_Domain_Score < 15 THEN 3
 WHEN weighted_Efficiency_And_Cost_Reduction_Domain_Score < 20 THEN 4
 WHEN weighted_Efficiency_And_Cost_Reduction_Domain_Score < 25 THEN 5
ELSE 6
END Band_Order
FROM dbo.TPS_cleaned
WHERE weighted_Efficiency_And_Cost_reduction_Domain_Score IS NOT NULL
)
SELECT 
CASE Band_Order
WHEN 1 THEN '0 TO BELOW 5'
WHEN 2 THEN '5 TO BELOW 10'
WHEN 3 THEN '10 TO BELOW 15'
WHEN 4 THEN '15 TO BELOW 20'
WHEN 5 THEN '20 TO BELOW 25'
WHEN 6 THEN '25 TO ABOVE'
END AS Efficiency_Score_Band,
COUNT(*) AS Hospital_Count,
CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage
FROM Efficiencybands
GROUP BY Band_Order
ORDER BY Band_Order;

--51. Weighted efficiency Score Summary 
SELECT 
COUNT(weighted_Efficiency_And_Cost_reduction_Domain_Score) AS Hospitals_With_Scores,
AVG(weighted_Efficiency_And_Cost_reduction_Domain_Score) AS AVG_Efficiency_Score,
STDEV(weighted_Efficiency_And_Cost_reduction_Domain_Score) AS STD_Deviation
FROM dbo.TPS_cleaned;


--52. Weighted Safety vs Clinical Outcomes
WITH Validscores AS
(
SELECT weighted_Safety_domain_Score AS Safety,
weighted_Normalized_Clinical_Outcomes_Domain_Score AS clinical
FROM dbo.TPS_cleaned
WHERE weighted_Safety_domain_Score IS NOT NULL
AND
weighted_Normalized_Clinical_Outcomes_Domain_Score IS NOT NULL
),
Formulaparts AS
(
SELECT
COUNT(*) AS N,
SUM(Safety) AS Sumsafety,
SUM(Clinical) AS Sumclinical,
SUM(Safety * Clinical) AS Sumsafetyclinical,
SUM(Safety * Safety) AS Sumsafetysquared,
SUM(Clinical * Clinical) AS Sumclinicalsuqared
FROM Validscores
)
SELECT 
N AS Hospitals_Compared,
CAST(( N * sumsafetyclinical - Sumsafety * SUmclinical) 
/ 
NULLIF(SQRT((N * Sumsafetysquared - Sumsafety * Sumsafety)
*
(N * Sumclinicalsuqared - Sumclinical * sumclinical)),0) AS DECIMAL (10,4)) AS Safety_Clinical_Correlation
FROM Formulaparts;

--53. Missing state - Records - Weighted Domain Score Analysis
SELECT 
STATE,
COUNT(*) AS Hospital_Count,
AVG(weighted_normalized_clinical_outcomes_Domain_score) AS Avg_Clinical_score,
AVG(weighted_person_and_community_engagement_Domain_score) AS AVG_engagement_score,
AVG(weighted_efficiency_And_cost_reduction_domain_score) AS Avg_Efficiency_Score,
AVG(weighted_Safety_domain_score) AS Avg_safety_score
FROM dbo.TPS_Cleaned
WHERE STATE IS NULL
GROUP BY STATE
HAVING COUNT(*) >=30
ORDER BY AVG_Efficiency_Score DESC;

--54. State Data Availablitiy Summary 
SELECT 
COUNT(*) AS Total_Rows,
COUNT(STATE) AS ROWS_WITH_STATE,
COUNT(DISTINCT STATE) AS DISTINCT_STATES
FROM dbo.TPS_Cleaned;

--55. Identify weighted Quality - Domain columns
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TPS_CLEANED'
AND
(
COLUMN_NAME LIKE '%Clinical%outcomes%'
OR COLUMN_NAME LIKE '%Engagement%'
OR COLUMN_NAME LIKE '%Safety%'
OR COLUMN_NAME LIKE '%Efficiency%'
)
ORDER BY COLUMN_NAME;

--56. Hospital Count by State
SELECT 
STATE,
COUNT(*) AS Hospital_Count
FROM dbo.TPS_cleaned
WHERE STATE IS NOT NULL
GROUP BY STATE
HAVING COUNT(*) >=30
ORDER BY Hospital_Count DESC;


--57. Sample of hospital Weighted Domain Scores
SELECT TOP 10
    State,
    Weighted_Normalized_Clinical_Outcomes_Domain_Score,
    Weighted_Person_And_Community_Engagement_Domain_Score,
    Weighted_Safety_Domain_Score,
    Weighted_Efficiency_And_Cost_Reduction_Domain_Score
FROM dbo.TPS_Cleaned;


--58. State - wise avg Weighted Efficiency Score
SELECT 
STATE,
COUNT(*) AS Hospital_Count,
AVG(weighted_Efficiency_And_Cost_Reduction_Domain_Score) AS Avg_Efficiency_Score
FROM dbo.TPS_Cleaned
WHERE STATE IS NOT NULL
GROUP BY STATE
HAVING COUNT(*) >=30
ORDER BY Avg_Efficiency_Score DESC;

--59. State - wise clinical outcomes and Efficiency compariosn
SELECT
    State,
    COUNT(*) AS Hospital_Count,
    AVG(Weighted_Normalized_Clinical_Outcomes_Domain_Score)
        AS Avg_Clinical_Score,
    AVG(Weighted_Efficiency_And_Cost_Reduction_Domain_Score)
        AS Avg_Efficiency_Score
FROM dbo.TPS_Cleaned
WHERE State IS NOT NULL
GROUP BY State
HAVING COUNT(*) >= 30
ORDER BY Avg_Efficiency_Score DESC;

--60. State - wise Comaprison of all 4 weighted Domains
SELECT
    State,
    COUNT(*) AS Hospital_Count,
    AVG(Weighted_Normalized_Clinical_Outcomes_Domain_Score)
        AS Avg_Clinical_Score,
    AVG(Weighted_Person_And_Community_Engagement_Domain_Score)
        AS Avg_Engagement_Score,
    AVG(Weighted_Safety_Domain_Score)
        AS Avg_Safety_Score,
    AVG(Weighted_Efficiency_And_Cost_Reduction_Domain_Score)
        AS Avg_Efficiency_Score
FROM dbo.TPS_Cleaned
WHERE State IS NOT NULL
GROUP BY State
HAVING COUNT(*) >= 30
ORDER BY Avg_Efficiency_Score DESC;

--61. Dynamic missing - value analysis - TPS_cleaned
DECLARE @sql NVARCHAR(MAX);

SELECT @sql =
    STRING_AGG(
        CAST(
            'SELECT ' +
            '''' + c.name + ''' AS Column_Name, ' +
            'COUNT(*) AS Total_Rows, ' +
            'SUM(CASE WHEN ' + QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) AS Missing_Count, ' +
            'CAST(100.0 * SUM(CASE WHEN ' +
            QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) ' +
            'AS DECIMAL(6,2)) AS Missing_Percentage ' +
            'FROM dbo.TPS_Cleaned'
            AS NVARCHAR(MAX)
        ),
        ' UNION ALL '
    )
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID('dbo.TPS_Cleaned');

SET @sql = @sql +
    ' ORDER BY Missing_Count DESC, Column_Name;';

EXEC sp_executesql @sql;


--62. Dynamic Missing - value Analysis - clinical_Cleaned
DECLARE @sql NVARCHAR(MAX);

SELECT @sql =
    STRING_AGG(
        CAST(
            'SELECT ' +
            '''' + c.name + ''' AS Column_Name, ' +
            'COUNT(*) AS Total_Rows, ' +
            'SUM(CASE WHEN ' + QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) AS Missing_Count, ' +
            'CAST(100.0 * SUM(CASE WHEN ' +
            QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) ' +
            'AS DECIMAL(6,2)) AS Missing_Percentage ' +
            'FROM dbo.Clinical_Cleaned'
            AS NVARCHAR(MAX)
        ),
        ' UNION ALL '
    )
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID('dbo.Clinical_Cleaned');

SET @sql = @sql +
    ' ORDER BY Missing_Count DESC, Column_Name;';

EXEC sp_executesql @sql;

--63. Dynamic Missing - value Analysis - Safety_Cleaned
DECLARE @sql NVARCHAR(MAX);

SELECT @sql =
    STRING_AGG(
        CAST(
            'SELECT ' +
            '''' + c.name + ''' AS Column_Name, ' +
            'COUNT(*) AS Total_Rows, ' +
            'SUM(CASE WHEN ' + QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) AS Missing_Count, ' +
            'CAST(100.0 * SUM(CASE WHEN ' +
            QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) ' +
            'AS DECIMAL(6,2)) AS Missing_Percentage ' +
            'FROM dbo.Safety_Cleaned'
            AS NVARCHAR(MAX)
        ),
        ' UNION ALL '
    )
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID('dbo.Safety_Cleaned');

SET @sql = @sql +
    ' ORDER BY Missing_Count DESC, Column_Name;';

EXEC sp_executesql @sql;


--64. Column Count across Cleaned Datasets
SELECT 
TABLE_NAME,
COUNT(*) AS COLUMN_COUNT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN('safety_Cleaned',
'Engagement_Cleaned',
'Efficiency_Cleaned'
)
GROUP BY  TABLE_NAME
ORDER BY TABLE_NAME;

--65. Column names and position in safety and engagement Datasets
SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'Safety_Cleaned',
    'Engagement_Cleaned'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;


--66. Dynamic missing - value Analysis - Engagement_Cleaned
DECLARE @sql NVARCHAR(MAX);

SELECT @sql =
    STRING_AGG(
        CAST(
            'SELECT ' +
            '''' + c.name + ''' AS Column_Name, ' +
            'COUNT(*) AS Total_Rows, ' +
            'SUM(CASE WHEN ' + QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) AS Missing_Count, ' +
            'CAST(100.0 * SUM(CASE WHEN ' +
            QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) ' +
            'AS DECIMAL(6,2)) AS Missing_Percentage ' +
            'FROM dbo.Engagement_Cleaned'
            AS NVARCHAR(MAX)
        ),
        ' UNION ALL '
    )
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID('dbo.Engagement_Cleaned');

SET @sql = @sql +
    ' ORDER BY Missing_Count DESC, Column_Name;';

EXEC sp_executesql @sql;


--67. Dynamic missing - value Analysis - Efficiency_Cleaned
DECLARE @sql NVARCHAR(MAX);

SELECT @sql =
    STRING_AGG(
        CAST(
            'SELECT ' +
            '''' + c.name + ''' AS Column_Name, ' +
            'COUNT(*) AS Total_Rows, ' +
            'SUM(CASE WHEN ' + QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) AS Missing_Count, ' +
            'CAST(100.0 * SUM(CASE WHEN ' +
            QUOTENAME(c.name) +
            ' IS NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) ' +
            'AS DECIMAL(6,2)) AS Missing_Percentage ' +
            'FROM dbo.Efficiency_Cleaned'
            AS NVARCHAR(MAX)
        ),
        ' UNION ALL '
    )
FROM sys.columns AS c
WHERE c.object_id = OBJECT_ID('dbo.Efficiency_Cleaned');

SET @sql = @sql +
    ' ORDER BY Missing_Count DESC, Column_Name;';

EXEC sp_executesql @sql;


--68. TPS Interquartile Range and oulier Boundaries
WITH Quartiles AS
(
SELECT DISTINCT
PERCENTILE_CONT(0.25)
WITHIN GROUP(ORDER BY Total_Performance_Score)
OVER() AS Q1,
PERCENTILE_CONT(0.75) 
WITHIN GROUP(ORDER BY Total_Performance_score)
OVER () AS Q3
FROM dbo.TPS_cleaned
WHERE Total_Performance_score IS NOT NULL
)
SELECT 
Q1,
Q3,
Q3 - Q1 AS IQR,
Q1 - 1.5 * (Q3 - Q1) AS LOWER_BOUNDARY,
Q3 + 1.5 *(Q3 - Q1) AS UPPER_BOUNDARY
FROM Quartiles;


--69. count of potentially low and high TPS Outliers
WITH Quartiles AS
(
SELECT DISTINCT
PERCENTILE_CONT(0.25) 
WITHIN GROUP(ORDER BY 
Total_Performance_Score) OVER () AS Q1,
PERCENTILE_CONT(0.75)
WITHIN GROUP(ORDER BY 
Total_Performance_Score) OVER () AS Q3
FROM dbo.TPS_Cleaned
WHERE Total_Performance_Score IS NOT NULL
),
Boundaries AS
(
SELECT Q1 - 1.5 * (Q3 -Q1) AS Lower_Boundary,
Q3 + 1.5 * (Q3 - Q1) AS Upper_Boundary
FROM Quartiles)
SELECT COUNT(*) AS Total_Hospitals,
SUM(CASE 
WHEN T.Total_Performance_Score < B.Lower_Boundary THEN 1 ELSE 0
END) AS Potential_Low_Outliers,
SUM(CASE WHEN T.Total_Performance_Score > B.Upper_Boundary THEN 1 ELSE 0
END) AS Potential_High_Outliers
FROM dbo.TPS_Cleaned  AS T
CROSS JOIN Boundaries AS B
WHERE T.Total_Performance_Score IS NOT NULL;


--70. Identify hospitals with potentially High TPS Outlier
WITH Quartiles AS 
( 
SELECT DISTINCT 
PERCENTILE_CONT(0.25)
WITHIN GROUP (ORDER BY Total_PErformance_Score) OVER() AS Q1,
PERCENTILE_CONT(0.75)
WITHIN GROUP (ORDER BY Total_Performance_Score) OVER() AS Q3
FROM dbo.TPS_cleaned
WHERE Total_Performance_Score IS NOT NULL
),
Boundaries AS
(
SELECT 
Q3 + 1.5 * (Q3 - Q1) AS Upper_Boundary
FROM Quartiles
)
SELECT 
T.FACILITY_ID,
T.FACILITY_NAME,
T.STATE,
T.Total_Performance_Score
FROM dbo.TPS_cleaned AS T

CROSS JOIN Boundaries AS B
WHERE T.Total_Performance_Score > B.Upper_Boundary
ORDER BY T.Total_Performance_Score DESC;


--71. Weighted Domain performance of High - TPS outliers Hospitals
WITH Quartiles AS
(
    SELECT DISTINCT
        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY Total_Performance_Score)
        OVER () AS Q1,
        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY Total_Performance_Score)
        OVER () AS Q3
    FROM dbo.TPS_Cleaned
    WHERE Total_Performance_Score IS NOT NULL
),
Boundaries AS
(
    SELECT Q3 + 1.5 * (Q3 - Q1) AS Upper_Boundary
    FROM Quartiles
),
DomainAverages AS
(
    SELECT
        AVG(Weighted_Normalized_Clinical_Outcomes_Domain_Score)
            AS Avg_Clinical,
        AVG(Weighted_Person_And_Community_Engagement_Domain_Score)
            AS Avg_Engagement,
        AVG(Weighted_Safety_Domain_Score)
            AS Avg_Safety,
        AVG(Weighted_Efficiency_And_Cost_Reduction_Domain_Score)
            AS Avg_Efficiency
    FROM dbo.TPS_Cleaned
)
SELECT
    T.Facility_ID,
    T.Facility_Name,
    T.State,
    T.Total_Performance_Score,

    T.Weighted_Normalized_Clinical_Outcomes_Domain_Score
        AS Clinical_Score,
    T.Weighted_Person_And_Community_Engagement_Domain_Score
        AS Engagement_Score,
    T.Weighted_Safety_Domain_Score
        AS Safety_Score,
    T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score
        AS Efficiency_Score,

    CASE WHEN T.Weighted_Normalized_Clinical_Outcomes_Domain_Score
        < A.Avg_Clinical THEN 'Below Average' ELSE 'At/Above Average'
    END AS Clinical_Comparison,

    CASE WHEN T.Weighted_Person_And_Community_Engagement_Domain_Score
        < A.Avg_Engagement THEN 'Below Average' ELSE 'At/Above Average'
    END AS Engagement_Comparison,

    CASE WHEN T.Weighted_Safety_Domain_Score
        < A.Avg_Safety THEN 'Below Average' ELSE 'At/Above Average'
    END AS Safety_Comparison,

    CASE WHEN T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score
        < A.Avg_Efficiency THEN 'Below Average' ELSE 'At/Above Average'
    END AS Efficiency_Comparison

FROM dbo.TPS_Cleaned AS T
CROSS JOIN Boundaries AS B
CROSS JOIN DomainAverages AS A
WHERE T.Total_Performance_Score > B.Upper_Boundary
ORDER BY T.Total_Performance_Score DESC;


--72. High - TPS Outlier Hospital Domain Comparison 
WITH Quartiles AS
(
    SELECT DISTINCT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY Total_Performance_Score)
            OVER () AS Q1,
        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY Total_Performance_Score)
            OVER () AS Q3
    FROM dbo.TPS_Cleaned
    WHERE Total_Performance_Score IS NOT NULL
),
Boundaries AS
(
    SELECT Q3 + 1.5 * (Q3 - Q1) AS Upper_Boundary
    FROM Quartiles
),
DomainAverages AS
(
    SELECT
        AVG(Weighted_Normalized_Clinical_Outcomes_Domain_Score)
            AS Avg_Clinical,
        AVG(Weighted_Person_And_Community_Engagement_Domain_Score)
            AS Avg_Engagement,
        AVG(Weighted_Safety_Domain_Score)
            AS Avg_Safety,
        AVG(Weighted_Efficiency_And_Cost_Reduction_Domain_Score)
            AS Avg_Efficiency
    FROM dbo.TPS_Cleaned
),
OutlierHospitals AS
(
    SELECT T.*
    FROM dbo.TPS_Cleaned AS T
    CROSS JOIN Boundaries AS B
    WHERE T.Total_Performance_Score > B.Upper_Boundary
)
SELECT
    T.Facility_ID,
    T.Facility_Name,
    T.State,
    T.Total_Performance_Score,

    T.Weighted_Normalized_Clinical_Outcomes_Domain_Score
        AS Clinical_Score,
    CASE
        WHEN T.Weighted_Normalized_Clinical_Outcomes_Domain_Score IS NULL
            THEN 'Missing'
        WHEN T.Weighted_Normalized_Clinical_Outcomes_Domain_Score < A.Avg_Clinical
            THEN 'Below Average'
        ELSE 'At/Above Average'
    END AS Clinical_Comparison,

    T.Weighted_Person_And_Community_Engagement_Domain_Score
        AS Engagement_Score,
    CASE
        WHEN T.Weighted_Person_And_Community_Engagement_Domain_Score IS NULL
            THEN 'Missing'
        WHEN T.Weighted_Person_And_Community_Engagement_Domain_Score < A.Avg_Engagement
            THEN 'Below Average'
        ELSE 'At/Above Average'
    END AS Engagement_Comparison,

    T.Weighted_Safety_Domain_Score AS Safety_Score,
    CASE
        WHEN T.Weighted_Safety_Domain_Score IS NULL
            THEN 'Missing'
        WHEN T.Weighted_Safety_Domain_Score < A.Avg_Safety
            THEN 'Below Average'
        ELSE 'At/Above Average'
    END AS Safety_Comparison,

    T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score
        AS Efficiency_Score,
    CASE
        WHEN T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score IS NULL
            THEN 'Missing'
        WHEN T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score < A.Avg_Efficiency
            THEN 'Below Average'
        ELSE 'At/Above Average'
    END AS Efficiency_Comparison

FROM OutlierHospitals AS T
CROSS JOIN DomainAverages AS A
ORDER BY T.Total_Performance_Score DESC;


--73. Aggregrate Domain performnace of High - TPS Outlier Hospitals
WITH Quartiles AS
(
SELECT DISTINCT
PERCENTILE_CONT(0.25)
WITHIN GROUP (ORDER BY Total_PErformance_Score) OVER () AS Q1,
PERCENTILE_CONT(0.75)
WITHIN GROUP (ORDER BY TOtal_Performance_Score) OVER () AS Q3
FROM dbo.TPS_cleaned
WHERE Total_Performance_Score IS NOT NULL
),
Boundaries AS
(
SELECT Q3 + 1.5 *(Q3 - Q1) AS Upper_Boundary
FROM Quartiles
),
Domainaverages AS
(
SELECT 
AVG(weighted_Normalized_clinical_outcomes_domain_Score) AS Avg_clinical,
AVG(weighted_person_and_Community_engagement_domain_Score) AS Avg_Engagement,
AVG(weighted_safety_domain_Score) AS Avg_Safety,
AVG(weighted_efficiency_and_cost_Reduction_domain_score) AS Avg_efficiency
FROM dbo.TPS_cleaned
),
outlierhospitals AS
(
SELECT T.*
FROM dbo.TPS_cleaned AS T
CROSS JOIN Boundaries AS B
WHERE T.Total_Performance_Score > B.Upper_Boundary 
)
SELECT 
COUNT(*) AS
high_tps_outlier_hospitals,
SUM(CASE
        WHEN T.Weighted_Normalized_Clinical_Outcomes_Domain_Score
             < A.Avg_Clinical THEN 1 ELSE 0
    END) AS Clinical_Below_Average_Count,

    SUM(CASE
        WHEN T.Weighted_Normalized_Clinical_Outcomes_Domain_Score
             >= A.Avg_Clinical THEN 1 ELSE 0
    END) AS Clinical_At_Or_Above_Average_Count,

    SUM(CASE
        WHEN T.Weighted_Normalized_Clinical_Outcomes_Domain_Score
             IS NULL THEN 1 ELSE 0
    END) AS Clinical_Missing_Count,

    SUM(CASE
        WHEN T.Weighted_Person_And_Community_Engagement_Domain_Score
             < A.Avg_Engagement THEN 1 ELSE 0
    END) AS Engagement_Below_Average_Count,

    SUM(CASE
        WHEN T.Weighted_Person_And_Community_Engagement_Domain_Score
             >= A.Avg_Engagement THEN 1 ELSE 0
    END) AS Engagement_At_Or_Above_Average_Count,

    SUM(CASE
        WHEN T.Weighted_Person_And_Community_Engagement_Domain_Score
             IS NULL THEN 1 ELSE 0
    END) AS Engagement_Missing_Count,

    SUM(CASE
        WHEN T.Weighted_Safety_Domain_Score
             < A.Avg_Safety THEN 1 ELSE 0
    END) AS Safety_Below_Average_Count,

    SUM(CASE
        WHEN T.Weighted_Safety_Domain_Score
             >= A.Avg_Safety THEN 1 ELSE 0
    END) AS Safety_At_Or_Above_Average_Count,

    SUM(CASE
        WHEN T.Weighted_Safety_Domain_Score
             IS NULL THEN 1 ELSE 0
    END) AS Safety_Missing_Count,

    SUM(CASE
        WHEN T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score
             < A.Avg_Efficiency THEN 1 ELSE 0
    END) AS Efficiency_Below_Average_Count,

    SUM(CASE
        WHEN T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score
             >= A.Avg_Efficiency THEN 1 ELSE 0
    END) AS Efficiency_At_Or_Above_Average_Count,

    SUM(CASE
        WHEN T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score
             IS NULL THEN 1 ELSE 0
    END) AS Efficiency_Missing_Count

FROM OutlierHospitals AS T
CROSS JOIN DomainAverages AS A;


--74. Hospital - level Weighted Domain Score range
WITH Hospitaldomainscores AS 
(
SELECT 
FACILITY_ID,
FACILITY_NAME,
STATE,
Total_Performance_Score,
MAX(D.Domain_Score) AS Highest_Domain_Score,
MIN(D.Domain_Score) AS Lowest_Domain_Score
FROM dbo.TPS_cleaned AS T
CROSS APPLY
(
VALUES
(T.Weighted_Normalized_Clinical_Outcomes_Domain_Score),
(T.Weighted_Person_And_Community_Engagement_Domain_Score),
(T.Weighted_Safety_Domain_Score),
(T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score)) AS D(Domain_Score)
WHERE 
T.Weighted_Normalized_Clinical_Outcomes_Domain_Score IS NOT NULL
AND
T.Weighted_Person_And_Community_Engagement_Domain_Score IS NOT NULL
AND
T.Weighted_Safety_Domain_Score IS NOT NULL
AND
T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score IS NOT NULL
GROUP BY Facility_ID,
         Facility_Name,
         state,
         Total_Performance_Score
         )

         SELECT 
         Facility_ID,
         Facility_Name,
         state,
         Total_Performance_Score,
         Highest_Domain_Score,
         Lowest_Domain_Score,
         Highest_Domain_Score - 
         Lowest_Domain_Score AS Domain_Score_Range
         FROM Hospitaldomainscores
         ORDER BY Domain_Score_Range DESC;


--75. Distribution of Hospitals by domain Score variation
WITH Hospitaldomainscores AS 
(
SELECT 
T.FACILITY_ID,
T.FACILITY_NAME,
MAX(D.Domain_Score) AS Highest_Domain_Score,
MIN(D.Domain_Score) AS Lowest_Domain_Score
FROM dbo.TPS_cleaned AS T
CROSS APPLY
(
VALUES
(T.Weighted_Normalized_Clinical_Outcomes_Domain_Score),
(T.Weighted_Person_And_Community_Engagement_Domain_Score),
(T.Weighted_Safety_Domain_Score),
(T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score)) AS D(Domain_Score)
WHERE 
T.Weighted_Normalized_Clinical_Outcomes_Domain_Score IS NOT NULL
AND
T.Weighted_Person_And_Community_Engagement_Domain_Score IS NOT NULL
AND
T.Weighted_Safety_Domain_Score IS NOT NULL
AND
T.Weighted_Efficiency_And_Cost_Reduction_Domain_Score IS NOT NULL
GROUP BY T.Facility_ID,
         T.Facility_Name
        ),
        HospitalRanges AS 
        (
         SELECT 
         Facility_ID,
         Highest_Domain_Score - 
         Lowest_Domain_Score AS Domain_Score_Range
         FROM Hospitaldomainscores
       )
       SELECT 
       CASE 
       WHEN Domain_Score_Range <=5 THEN '0 TO 5'
       WHEN Domain_Score_Range <=10 THEN 'Above 5 TO 10'
       WHEN Domain_Score_Range <=15 THEN 'Above 10 TO 15'
       WHEN Domain_Score_Range <=20 THEN 'Above 15 TO 20'
       ELSE 'Above 20'
       END AS Variation_Band,
       COUNT(*) AS hospital_Count,
       CAST(100.0 * COUNT(*) / SUM(cOUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage
       FROM HospitalRanges
       GROUP BY 
       CASE 
       WHEN Domain_Score_Range <=5 THEN '0 TO 5'
       WHEN Domain_Score_Range <=10 THEN 'Above 5 TO 10'
       WHEN Domain_Score_Range <=15 THEN 'Above 10 TO 15'
       WHEN Domain_Score_Range <=20 THEN 'Above 15 TO 20'
       ELSE 'Above 20'
       END 
       ORDER BY MIN(Domain_Score_Range);


 
WITH Hospitaldomains AS 
(
SELECT 
Facility_ID,
weighted_normalized_clinical_outcomes_domain_score AS Clinical,
weighted_person_and_community_engagement_domain_Score AS Engagement,
weighted_safety_domain_score AS Safety,
weighted_efficiency_and_cost_reduction_domain_score AS Efficiency
FROM dbo.TPS_cleaned
WHERE 
weighted_normalized_clinical_outcomes_domain_score IS NOT NULL
AND
weighted_person_and_community_engagement_domain_Score IS NOT NULL
AND
Weighted_Safety_Domain_Score IS NOT NULL
AND
weighted_efficiency_and_cost_reduction_domain_score IS NOT NULL
),
LowestDomain AS
(
SELECT 
Facility_ID,
Clinical,
Engagement,
Safety,
Efficiency,
(SELECT MIN(V.Domain_Score)
FROM (VALUES
(Clinical),
(Engagement),
(Safety),
(Efficiency)) 
AS V(Domain_Score)) AS Lowest_Score
FROM HospitalDomains
),
Domaincounts AS
(
SELECT 'Clinical Outcomes' AS Domain_Name,
COUNT(*) AS Hospital_with_lowest_Score
FROM LowestDomain
WHERE Clinical = Lowest_Score

 UNION ALL

 SELECT 'Engagement',
 COUNT(*)
 FROM LowestDomain
 WHERE Engagement = Lowest_Score

 UNION ALL

 SELECT 'Safety',
 COUNT(*)
 FROM LowestDomain
 WHERE Safety = Lowest_Score

 UNION ALL

 SELECT 'Efficiency',
 COUNT(*)
 FROM LowestDomain
 WHERE Efficiency = Lowest_Score
 )
 SELECT 
 Domain_Name,
 Hospital_With_Lowest_Score
 FROM Domaincounts
 ORDER BY  Hospital_With_Lowest_Score;


























 










                                    

