-- SET search_path TO q3;

-- Project Assignment 3: Interrogating the Data
-- Task 3.2: Reproduce and repair the two dashboard-query bugs
-- Target database: ex603_data, loaded from rental.sql
--
-- Preserve the broken examples in this file. The point is to show the failure,
-- measure its effect, and then place the corrected form beside it.

-- 3.2A.1 Broken nullable-column filter — how many intended rows does an
--        inequality or negation predicate return?
-- Requirement: reproduce SQL three-valued-logic row loss.

SELECT count(*)
FROM viewings
WHERE no_show_reason <> 'Renter no show'; -- returns 22 rows

-- 3.2A.2 Silently omitted rows — how many NULL rows did the broken predicate
--        fail to include?
-- Requirement: count the rows omitted because the predicate is UNKNOWN.

SELECT count(*)
FROM viewings
WHERE no_show_reason IS null; -- returns 166

-- 3.2A.3 Table total — what is the complete comparison population?
-- Requirement: show the broken count, omitted count, and table total together.

SELECT (
        SELECT count(*)
        FROM viewings
        WHERE no_show_reason <> 'Renter no show'
    ) AS broken,
    (
        SELECT count(viewing_id)
        FROM viewings
        WHERE no_show_reason = 'Renter no show'
    ) AS count_no_show,
    (
        SELECT count(viewing_id)
        FROM viewings
        WHERE no_show_reason IS null
    ) AS count_silent,
    count(*) AS total
FROM viewings; -- 22 + 12 = 34, the query demonstrates that

-- != 'Renter no show' + = 'Renter no show' does not account for 200
-- we would expect != to be 188 and = to be 12


-- 3.2A.4 Repaired nullable-column filter — how many intended rows are returned
--        when missing values are handled explicitly?
-- Requirement: repair with IS NULL or COALESCE.

SELECT count(*)
FROM viewings
WHERE COALESCE(no_show_reason, 'not applicable') <> 'Renter no show'; -- returns expected 188

-- 3.2B.1 Broken SELECT-alias filter — what happens when WHERE refers to an
--        alias that has not been evaluated yet?
-- Requirement: define an alias in SELECT and reference it in WHERE.

-- SELECT viewing_id, EXTRACT(DOW FROM attended_at) AS day_of_week
-- FROM viewings
-- WHERE day_of_week = 2;
--
/*
[42703] ERROR: column "day_of_week" does not exist
  Position: 85
*/

-- 3.2B.2 Correct alias rewrite using the original expression — how can the
--        result be filtered without relying on the SELECT alias?

SELECT viewing_id, EXTRACT(DOW FROM attended_at) AS day_of_week
FROM viewings
WHERE EXTRACT(DOW from attended_at) = 2;

-- 3.2B.3 Correct alias rewrite using a CTE or subquery — how can the alias be
--        made into a column before the outer WHERE clause uses it?
-- Requirement: CTE or subquery.

SELECT *
FROM (
        SELECT viewing_id, EXTRACT(DOW FROM attended_at) AS day_of_week
        FROM viewings
    ) AS v
WHERE v.day_of_week = 2;
