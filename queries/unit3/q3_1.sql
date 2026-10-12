-- SET search_path TO q3;

-- Project Assignment 3: Interrogating the Data
-- Task 3.1: Establish what the rental marketplace data contains
-- Target database: ex603_data, loaded from rental.sql


-- 1 - 3.1a Available properties at or below the assignment's rent threshold —
--      which properties anchor the audit?
-- Requirement: SELECT, WHERE, ORDER BY, LIMIT.

SELECT property_id, monthly_rent, city, listing_code
FROM properties
WHERE is_available
AND monthly_rent <= 2000
ORDER BY monthly_rent
LIMIT 10;

/* result
7,600.05,Saigon,UQ-1007
6,600.05,Haiphong,UQ-1006
14,651.07,Saigon,UQ-1014
15,1342.76,Hue,UQ-1015
10,1344.82,Hanoi,UQ-1010
11,1900.28,Haiphong,UQ-1011
8,1954.33,Saigon,UQ-1008

in plain english this filters properties that are available with a monthly rent less or equal to 2000
 */

-- 2 - 3.1b Viewing statuses — what distinct status values occur in the data?
-- Requirement: DISTINCT.

SELECT distinct(viewing_status)
FROM viewings
ORDER BY viewing_status;

/* result

attended
cancelled
disputed

disputed is an interesting status
finds distinct viewing statuses in the viewings table
 */

-- 3 - 3.1c Numeric range — which viewings fall within a meaningful numeric range?
-- Requirement: numeric range filter.

SELECT viewing_id, duration_min
FROM viewings
WHERE duration_min BETWEEN 5 AND 15
ORDER BY duration_min DESC;

/*
finds all viewings whose duration min was between 5 and 15 mins
 */

-- 3 - 3.1d Explicit value list — which viewings have one of the selected values?
-- Requirement: IN.

select *
from viewings
where interest_score in (1, 2)
order by interest_score
limit 10;

/*
 finds interest scores that are either 1 or 2
 */

-- 4 - 3.1e Property name pattern — which properties match a text pattern?
-- Requirement: LIKE.

SELECT property_label
FROM properties
WHERE property_label like '%1_';

/*
Property_10
Property_11
Property_12
Property_13
Property_14
Property_15

all property labels that end between 10-19
*/

-- 4 - 3.1f Missing reasons — which viewings do not have a reason recorded?
-- Requirement: NULL handling and COALESCE.

select
    viewing_status,
    coalesce(no_show_reason, 'not applicable') as no_show_reason
from viewings
where no_show_reason IS NULL;

/*
    replaces all null no_show_reasons with 'not applicable'
*/


-- 5 - 3.1g Plain-language business measure — how can the viewing results be made
--      understandable to someone who does not write SQL?
-- Requirement: calculated/computed column and CASE where appropriate.

SELECT
    CASE
        WHEN interest_score <= 1 THEN 'uninterested'
        WHEN interest_score <= 1.25 THEN 'mildly interested'
        WHEN interest_score <= 2 THEN 'interested'
        WHEN interest_score > 2 THEN 'very interested'
    END AS interest_category
FROM viewings;

/*
 categorizes viewings with an interest score into 1 of four buckets
 */
