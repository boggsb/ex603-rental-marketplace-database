-- 5.3A. Does the number of candidate property/amenity pairs equal the product?
WITH sizes AS (
    SELECT (SELECT count(*) FROM q3.properties) AS properties,
           (SELECT count(*) FROM q3.amenities) AS amenities
)
SELECT properties, amenities, properties * amenities AS expected,
       (SELECT count(*) FROM q3.properties CROSS JOIN q3.amenities) AS actual
FROM sizes;

-- 5.3B. How does PostgreSQL plan the viewing report from 5.1A?
EXPLAIN
SELECT v.viewing_id, r.renter_name, p.property_label, v.scheduled_at
FROM q3.viewings v
INNER JOIN q3.renters r ON r.renter_id = v.renter_id
INNER JOIN q3.properties p ON p.property_id = v.property_id;
