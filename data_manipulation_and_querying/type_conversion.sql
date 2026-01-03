-- Select campaign_name, start_date, and convert start_date to 
-- DATE type from campaign_identifier table.
SELECT
    campaign_name,
    start_date,
    CAST(start_date AS DATE) AS campaign_start_date
FROM clique_bait.campaign_identifier;


-- for mssql
SELECT
    campaign_name,
    CAST(date AS START_DATE) AS start_date_converted
FROM clique_bait.campaign_identifier;


SELECT
    campaign_name,
    TRY_CONVERT(date, '2025-12-28') AS safe_date,
    TRY_CONVERT(int, '123') AS safe_int,
    TRY_PARSE('12/31/2025' AS DATE USING 'en-US') AS us_date,
    TRY_PARSE('31.12.2025' AS DATE USING 'de-DE') AS de_date;
