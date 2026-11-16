-- 5.2A1. How many viewings does each property have, including zero?
SELECT p.property_id, count(v.viewing_id) AS bookings
FROM q3.properties p LEFT JOIN q3.viewings v USING (property_id)
GROUP BY p.property_id ORDER BY p.property_id;

-- 5.2A2. Which properties appear when we require a matching viewing?
SELECT p.property_id, count(v.viewing_id) AS bookings
FROM q3.properties p INNER JOIN q3.viewings v USING (property_id)
GROUP BY p.property_id ORDER BY p.property_id;

-- 5.2A3. How many unique properties disappear when a match is required?
SELECT count(DISTINCT p.property_id) AS all_properties,
       count(DISTINCT v.property_id) AS matched,
       count(DISTINCT p.property_id) - count(DISTINCT v.property_id) AS excluded
FROM q3.properties p LEFT JOIN q3.viewings v USING (property_id);

-- 5.2B1. Does preserving properties on the right yield the same counts?
SELECT p.property_id, count(v.viewing_id) AS bookings
FROM q3.viewings v RIGHT JOIN q3.properties p USING (property_id)
GROUP BY p.property_id ORDER BY p.property_id;

-- 5.2B2. Do any property/viewing pairs differ in either direction?
WITH l AS (
    SELECT p.property_id, v.viewing_id FROM q3.properties p
    LEFT JOIN q3.viewings v USING (property_id)
), r AS (
    SELECT p.property_id, v.viewing_id FROM q3.viewings v
    RIGHT JOIN q3.properties p USING (property_id)
)
SELECT (SELECT count(*) FROM (TABLE l EXCEPT ALL TABLE r) d) AS left_only,
       (SELECT count(*) FROM (TABLE r EXCEPT ALL TABLE l) d) AS right_only;

-- 5.2B3. Which records match, and which exist on just one side?
SELECT coalesce(p.property_id, v.property_id) AS property_id,
       p.property_label, v.viewing_id
FROM q3.properties p FULL OUTER JOIN q3.viewings v USING (property_id)
ORDER BY v.viewing_id NULLS FIRST, property_id;

-- 5.2C1. Which properties have no corresponding viewing?
SELECT p.property_id FROM q3.properties p
WHERE NOT EXISTS (SELECT 1 FROM q3.viewings v WHERE v.property_id = p.property_id)
ORDER BY p.property_id;

-- 5.2C2. Which property IDs remain after removing those in viewings?
SELECT property_id FROM q3.properties
EXCEPT
SELECT property_id FROM q3.viewings
ORDER BY property_id;
