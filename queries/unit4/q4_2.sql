-- SET search_path TO q3;

-- Assignment 4.2: conditional aggregation, regional totals and a CTE baseline.
-- Database: ex603_data; failure: no_show_reason = 'Renter no show'.

-- 4.2A Requirement: CASE inside an aggregate; event and failure totals together.
-- Questions: How many viewings did each property have? How many were renter no-shows?
-- No WHERE filters out nonfailures. COUNT(viewing_id) preserves zero-event properties.
SELECT p.property_id, COUNT(v.viewing_id) AS events,
       SUM(CASE WHEN v.no_show_reason = 'Renter no show' THEN 1 ELSE 0 END) AS failures,
       ROUND(100.0 * SUM(CASE WHEN v.no_show_reason = 'Renter no show'
                             THEN 1 ELSE 0 END) / NULLIF(COUNT(v.viewing_id), 0), 2) AS failure_pct
FROM properties AS p
LEFT JOIN viewings AS v ON v.property_id = p.property_id
GROUP BY p.property_id
ORDER BY failures DESC, failure_pct DESC NULLS LAST, p.property_id;

-- 4.2B Requirement: ROLLUP showing regional subtotals and a platform grand total only.
-- Question: How many viewings and failures belong to each property region and the platform?
-- REGION SUBTOTAL rows summarize cities; PLATFORM GRAND TOTAL summarizes every viewing.
-- Rolling up only city avoids property/status detail rows. GROUPING distinguishes totals.
SELECT CASE WHEN GROUPING(p.city) = 1 THEN 'PLATFORM GRAND TOTAL'
            ELSE 'REGION SUBTOTAL' END AS row_type,
       CASE WHEN GROUPING(p.city) = 1 THEN 'ALL REGIONS' ELSE p.city END AS region,
       COUNT(*) AS events,
       SUM(CASE WHEN v.no_show_reason = 'Renter no show' THEN 1 ELSE 0 END) AS failures,
       ROUND(100.0 * SUM(CASE WHEN v.no_show_reason = 'Renter no show'
                             THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_pct
FROM viewings AS v
JOIN properties AS p ON p.property_id = v.property_id
GROUP BY ROLLUP(p.city)
ORDER BY GROUPING(p.city), p.city;

-- 4.2C Requirement: WITH produces an aggregate, then a second aggregate/filter uses it.
-- Question: What is the event-weighted failure baseline among properties with 15+ viewings?
-- Sum failures / sum events weights by exposure; AVG of property rates weights properties equally.
WITH producer_summary AS (
    SELECT property_id, COUNT(*) AS events,
           SUM(CASE WHEN no_show_reason = 'Renter no show' THEN 1 ELSE 0 END) AS failures
    FROM viewings
    GROUP BY property_id
)
SELECT COUNT(*) AS properties, SUM(events) AS events, SUM(failures) AS failures,
       ROUND(100.0 * SUM(failures) / NULLIF(SUM(events), 0), 2) AS weighted_failure_pct,
       ROUND(AVG(100.0 * failures / events), 2) AS mean_property_pct
FROM producer_summary
WHERE events >= 15;
