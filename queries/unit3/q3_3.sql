-- SET search_path TO q3;

-- Project Assignment 3: Interrogating the Data
-- Task 3.3: Hand the dashboard team a corrected query
-- Target database: ex603_data, loaded from rental.sql
--
-- TWO-STEP QUESTION:
-- Which currently available properties have never been involved in a viewing
-- recorded as a renter no-show?
--
-- Step 1 identifies the property IDs attached to viewings whose no-show reason
-- is 'Renter no show'. Step 2 returns available properties whose IDs are not in
-- that first result.


-- 3.3a NOT IN subquery — which available properties have no renter no-shows?
-- Requirement: subquery using IN or NOT IN.

SELECT property_id, property_label, city, monthly_rent
FROM properties
WHERE is_available = TRUE
AND property_id NOT IN (
    SELECT property_id
    FROM viewings
    WHERE no_show_reason = 'Renter no show'
)
ORDER BY property_id;

-- RESULT: Six available properties have no recorded renter no-shows:
-- property IDs 5, 8, 10, 13, 14, and 15.


-- 3.3b Common Table Expression — which available properties have no renter
--      no-shows when the first step is named with WITH?
-- Requirement: WITH.

WITH renter_no_show_properties AS (
    SELECT DISTINCT property_id
    FROM viewings
    WHERE no_show_reason = 'Renter no show'
)
SELECT p.property_id, p.property_label, p.city, p.monthly_rent
FROM properties AS p
WHERE p.is_available = TRUE
AND NOT EXISTS (
    SELECT 1
    FROM renter_no_show_properties AS n
    WHERE n.property_id = p.property_id
)
ORDER BY p.property_id;

-- RESULT: This form returns the same six properties as 3.3a.


-- 3.3c EXCEPT set operation — which available properties remain after removing
--      every property involved in a renter no-show?
-- Requirement: a third form distinct from the subquery and CTE forms.

SELECT p.property_id, p.property_label, p.city, p.monthly_rent
FROM properties AS p
WHERE p.is_available = TRUE

EXCEPT

SELECT p.property_id, p.property_label, p.city, p.monthly_rent
FROM properties AS p
JOIN viewings AS v
    ON v.property_id = p.property_id
WHERE p.is_available = TRUE
AND v.no_show_reason = 'Renter no show'
ORDER BY property_id;

-- RESULT: This form also returns property IDs 5, 8, 10, 13, 14, and 15.


-- 3.3d Result-set proof — do all three forms return exactly the same rows?
-- Requirement: compare row identity, not only row counts.
--
-- The differences CTE compares form A with forms B and C in both directions.
-- EXCEPT ALL preserves duplicate counts, so zero difference rows establishes
-- that the returned rows and their multiplicities match.

WITH renter_no_show_properties AS (
    SELECT DISTINCT property_id
    FROM viewings
    WHERE no_show_reason = 'Renter no show'
),
form_a AS (
    SELECT property_id, property_label, city, monthly_rent
    FROM properties
    WHERE is_available = TRUE
    AND property_id NOT IN (
        SELECT property_id
        FROM viewings
        WHERE no_show_reason = 'Renter no show'
    )
),
form_b AS (
    SELECT p.property_id, p.property_label, p.city, p.monthly_rent
    FROM properties AS p
    WHERE p.is_available = TRUE
    AND NOT EXISTS (
        SELECT 1
        FROM renter_no_show_properties AS n
        WHERE n.property_id = p.property_id
    )
),
form_c AS (
    SELECT p.property_id, p.property_label, p.city, p.monthly_rent
    FROM properties AS p
    WHERE p.is_available = TRUE

    EXCEPT

    SELECT p.property_id, p.property_label, p.city, p.monthly_rent
    FROM properties AS p
    JOIN viewings AS v
        ON v.property_id = p.property_id
    WHERE p.is_available = TRUE
    AND v.no_show_reason = 'Renter no show'
),
differences AS (
    SELECT 'A minus B' AS comparison, difference.*
    FROM (
        SELECT * FROM form_a
        EXCEPT ALL
        SELECT * FROM form_b
    ) AS difference

    UNION ALL

    SELECT 'B minus A' AS comparison, difference.*
    FROM (
        SELECT * FROM form_b
        EXCEPT ALL
        SELECT * FROM form_a
    ) AS difference

    UNION ALL

    SELECT 'A minus C' AS comparison, difference.*
    FROM (
        SELECT * FROM form_a
        EXCEPT ALL
        SELECT * FROM form_c
    ) AS difference

    UNION ALL

    SELECT 'C minus A' AS comparison, difference.*
    FROM (
        SELECT * FROM form_c
        EXCEPT ALL
        SELECT * FROM form_a
    ) AS difference
)
SELECT
    (SELECT count(*) FROM form_a) AS form_a_rows,
    (SELECT count(*) FROM form_b) AS form_b_rows,
    (SELECT count(*) FROM form_c) AS form_c_rows,
    count(*) AS differing_rows
FROM differences;

-- RESULT:
-- form_a_rows | form_b_rows | form_c_rows | differing_rows
--       6     |       6     |       6     |        0
--
-- Each form returns six rows, and the bidirectional row comparisons find no
-- differences. The three result sets are therefore identical for this data.


-- 3.3e Equivalence boundary — under what input condition could these forms
--      produce different results?
-- Requirement: name and explain one condition involving NULLs, duplicates, or
--              an empty intermediate result.
--
-- ANSWER: If viewings.property_id were nullable and a renter-no-show row had a
-- NULL property_id, the NOT IN predicate in form A would evaluate to UNKNOWN
-- for every property and return no rows. Forms B and C would still return the
-- properties that have no matching non-NULL property ID. The supplied schema
-- prevents this difference because viewings.property_id is defined NOT NULL.
