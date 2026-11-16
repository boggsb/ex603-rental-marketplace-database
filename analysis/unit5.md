# Unit 5 — Rental marketplace joins

## 5.1 — Who and what sits behind a viewing?

A booking desk could use the three-table report to look up a viewing by its ID and see the renter’s name, property label and scheduled time. The timestamp describes the appointment even when the renter missed it. The report returned all 200 viewings.

I selected **Gym** to test whether the two properties flagged in Unit 4 share an amenity. Both do, along with properties 5, 10 and 11. The junction table records one verified property–amenity pair per row. A property can have several amenities, and many properties can offer the same amenity. Without those pairs, a catalog of amenity names alone could not establish which listings offer a gym.

Property_02 was the only Danang listing, so the self join found no same-city comparison (its peer ID is blank). Property_03 had 2 renter no-shows in 13 bookings (15.38%). Its Haiphong peers had 1 in 21 (property 6, 4.76%) and 1 in 16 (property 11, 6.25%). Property 11 also has a gym. Lower volume makes each missed appointment weigh more heavily in property 3’s rate, but it also recorded more misses than either peer. The data does not establish that the city, gym or booking volume caused a renter to miss an appointment.

## 5.2 — Which listings disappear from an activity report?

The left join retained **15 properties**. The inner join retained **13**, excluding **14 and 15** because neither ID appears in viewings. Counting distinct property IDs prevents repeat bookings from inflating that difference. Counting viewing IDs gives each unmatched listing zero bookings.

Reversing table order and using a right join produced the same property counts. Comparing the underlying property/viewing pairs with EXCEPT ALL in both directions returned zero differences, including duplicates. The full join returned 202 rows: 200 bookings and two listings without bookings. It could also expose a booking with no matching listing. Here the required property foreign key prevents that case.

NOT EXISTS tests each listing for the absence of a matching booking. EXCEPT subtracts the distinct booked IDs from the set of listing IDs. Both returned exactly 14 and 15.

Both listings are marked available. Zero recorded bookings could reflect low demand, limited visibility, missing appointment slots or a recording issue. The data does not distinguish those explanations. An inner-join dashboard would hide both listings and could make leadership believe every listing had attracted a renter. Show zero-booking listings separately, verify their visibility and appointment slots with the managers, and monitor time to first booking.

## 5.3 — Candidate pairs and query performance

There are 15 properties and 5 catalog amenities. Crossing them returned 75 rows, exactly 15 × 5. An amenity audit could use all 75 pairs as a checklist, then look up which pairs are verified. In a report claiming to list verified amenities, the same 75 rows would signal a missing join condition: only 25 property–amenity pairs are recorded.

### Execution plan and reflection

PostgreSQL chose two hash joins. It scans 200 viewings, looks up each renter in a hash table built from 30 renters, then looks up each property in a hash table built from 15 listings. It estimates 200 rows after each join. The report requests every booking, and both lookup tables are small enough to scan cheaply. Although the lookup IDs have primary-key indexes, scanning each table once avoids repeated index probes.

As booking history grows, reading the whole viewings table and returning every appointment will take more work. Understanding the plan helps distinguish that cost from a slow lookup. If the desk usually needs one day of appointments, an index on scheduled_at and a date filter could reduce the matching rows enough for nested loops with primary-key lookups to cost less. If the lookup tables grow beyond the memory available for hashing, PostgreSQL may process hashes in batches. For a large join where both inputs can already be read in join-key order, a merge join may then be competitive. These are predictions. The costs below are planner estimates, not elapsed times.

Full EXPLAIN output from the supplied data after ANALYZE:

```text
 Hash Join  (cost=3.01..9.29 rows=200 width=38)
   Hash Cond: (v.property_id = p.property_id)
   ->  Hash Join  (cost=1.68..7.28 rows=200 width=30)
         Hash Cond: (v.renter_id = r.renter_id)
         ->  Seq Scan on viewings v  (cost=0.00..5.00 rows=200 width=24)
         ->  Hash  (cost=1.30..1.30 rows=30 width=14)
               ->  Seq Scan on renters r  (cost=0.00..1.30 rows=30 width=14)
   ->  Hash  (cost=1.15..1.15 rows=15 width=16)
         ->  Seq Scan on properties p  (cost=0.00..1.15 rows=15 width=16)
```
