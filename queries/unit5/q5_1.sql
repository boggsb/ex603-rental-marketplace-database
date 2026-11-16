-- 5.1A. Which renter scheduled each viewing, for which property, and when?
SELECT v.viewing_id, r.renter_name, p.property_label, v.scheduled_at
FROM q3.viewings v
INNER JOIN q3.renters r ON r.renter_id = v.renter_id
INNER JOIN q3.properties p ON p.property_id = v.property_id;

-- 5.1B. Which properties have a verified Gym amenity?
SELECT p.property_id, p.property_label, a.amenity_name, la.verified_on
FROM q3.properties p
JOIN q3.listing_amenities la USING (property_id)
JOIN q3.amenities a USING (amenity_id)
WHERE a.amenity_name = 'Gym'
ORDER BY p.property_id;

-- 5.1C. How do the flagged properties compare with other listings in their city?
WITH activity AS (
    SELECT property_id, count(*) AS bookings,
           count(*) FILTER (WHERE no_show_reason = 'Renter no show') AS no_shows
    FROM q3.viewings GROUP BY property_id
)
SELECT p.property_id AS flagged, p.city, f.bookings, f.no_shows,
       peer.property_id AS peer_id, coalesce(a.bookings, 0) AS peer_bookings,
       coalesce(a.no_shows, 0) AS peer_no_shows
FROM q3.properties p
LEFT JOIN q3.properties peer ON peer.city = p.city AND peer.property_id <> p.property_id
JOIN activity f ON f.property_id = p.property_id
LEFT JOIN activity a ON a.property_id = peer.property_id
WHERE p.property_id IN (2, 3)
ORDER BY flagged, peer_id;
