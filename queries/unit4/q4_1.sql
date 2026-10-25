-- SET search_path TO q3;

-- Assignment 4.1: platform metrics and producer comparisons.
-- Database: ex603_data; reference tables: q3 (queries/unit3/rental.sql).
-- Metric: duration_min. Failure: no_show_reason = 'Renter no show'.
-- Region: properties.city (the property's location, not the booking city).

-- 4.1A Requirement: whole-event-table aggregates and distinct actors.
-- Question: How much viewing activity occurred, and what was the failure rate?
SELECT COUNT(*) AS events, COUNT(duration_min) AS measured_events,
       SUM(duration_min) AS total_min, ROUND(AVG(duration_min), 2) AS avg_min,
       MIN(duration_min) AS min_min, MAX(duration_min) AS max_min,
       COUNT(DISTINCT renter_id) AS renters,
       SUM(CASE WHEN no_show_reason = 'Renter no show' THEN 1 ELSE 0 END) AS failures,
       ROUND(100.0 * SUM(CASE WHEN no_show_reason = 'Renter no show'
                             THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS failure_pct
FROM viewings;

-- 4.1B Requirement: event count and average metric for every producer, by volume.
-- Question: Which properties have the most viewings and how do their results vary?
-- Include properties with no viewings; their averages and rates are undefined.
SELECT p.property_id, COUNT(v.viewing_id) AS events,
       ROUND(AVG(v.duration_min), 2) AS avg_min,
       SUM(CASE WHEN v.no_show_reason = 'Renter no show' THEN 1 ELSE 0 END) AS failures,
       ROUND(100.0 * SUM(CASE WHEN v.no_show_reason = 'Renter no show'
                             THEN 1 ELSE 0 END) / NULLIF(COUNT(v.viewing_id), 0), 2) AS failure_pct
FROM properties AS p
LEFT JOIN viewings AS v ON v.property_id = p.property_id
GROUP BY p.property_id
ORDER BY events DESC, p.property_id;

-- 4.1C Requirement: use HAVING to retain producers meeting a volume threshold.
-- Question: Which properties have at least 15 viewings for a less volatile comparison?
-- Fifteen is an exploratory screen, not a guarantee of statistical reliability.
SELECT property_id, COUNT(*) AS events, ROUND(AVG(duration_min), 2) AS avg_min,
       SUM(CASE WHEN no_show_reason = 'Renter no show' THEN 1 ELSE 0 END) AS failures,
       ROUND(100.0 * SUM(CASE WHEN no_show_reason = 'Renter no show'
                             THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_pct
FROM viewings
GROUP BY property_id
HAVING COUNT(*) >= 15
ORDER BY failure_pct DESC, events DESC, property_id;

-- 4.1D Requirement: group by two dimensions, including region.
-- Question: How do event volume, duration and failures vary by property city and status?
-- Each observed (region, viewing_status) combination has one row.
SELECT p.city AS region, v.viewing_status, COUNT(*) AS events,
       ROUND(AVG(v.duration_min), 2) AS avg_min,
       SUM(CASE WHEN v.no_show_reason = 'Renter no show' THEN 1 ELSE 0 END) AS failures,
       ROUND(100.0 * SUM(CASE WHEN v.no_show_reason = 'Renter no show'
                             THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_pct
FROM viewings AS v
JOIN properties AS p ON p.property_id = v.property_id
GROUP BY p.city, v.viewing_status
ORDER BY region, v.viewing_status;
