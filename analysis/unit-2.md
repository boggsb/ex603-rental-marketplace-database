# Constraints

## Foreign Key Constraints

The table below documents each foreign key relationship, the `ON DELETE` behavior selected for that relationship, and the reason for that choice.

| Foreign Key | ON DELETE Choice | Reason |
|---|---|---|
| `viewing.property_id → property.property_id` | `CASCADE` | If the property is deleted, all associated viewings should be removed as well. |
| `renter_viewing.renter_id → renter.renter_id` | `CASCADE` | If the renter is deleted, all associated renter-viewings should be removed as well. |
| `renter_viewing.viewing_id → viewing.viewing_id` | `CASCADE` | If the viewing is deleted, all associated renter-viewings should be removed as well. |
| `amenity.property_id → property.property_id` | `CASCADE` | If the property is deleted, all associated amenities should be removed as well. |

### Foreign Key Delete Behavior

#### `viewing.property_id → property.property_id`

**ON DELETE choice:** `CASCADE`

This constraint governs what happens when a `property` is removed from the platform.

The real-world event represented by this deletion is `the property no longer functions as a rental, it is purchased or moved off of the platform`.

When a `property` is deleted, `the property is no longer available for rent`. The selected `ON DELETE` behavior causes `viewings of the property to be removed as well`.

This behavior was chosen because `property viewings are removed because the aggregations should be across the current list of properties keeping duration of viewings for deleted properties would pollute the viewing metrics`.

Under an alternative such as `SET NULL`, `the viewings would continue to exist. in this case we would be maintaining a history of viewings without any detail of what was viewed and would not be able to draw any meaningful insights from the viewing data`.

---

#### `renter_viewing.renter_id → renter.renter_id`

**ON DELETE choice:** `CASCADE`

This constraint governs what happens when a `renter` is removed from the platform.

The real-world event represented by this deletion is `renter leaving the platform`.

When this occurs, `the renter's viewings are also removed from the join table`. The selected `ON DELETE` behavior causes `a cleanup of the join table and removal of any orphaned records`.

This behavior was chosen because `data in our junction table is meaningless without the one side. it holds the relationship between the two entities with one side gone there is no context`.

If `SET NULL` were used instead, `orphaned records would pollute the database`.

---

#### `renter_viewing.viewing_id → viewing.viewing_id`

**ON DELETE choice:** `CASCADE`

This constraint governs what happens when a `viewing` is removed from the platform.

The real-world event represented by this deletion is `a property was deleted and is cascaded to the viewing table`.

When this occurs, `the renter's viewings of the property are also removed from the join table`. The selected `ON DELETE` behavior causes `a cleanup of the join table and removal of any orphaned records`.

This behavior was chosen because `data in our junction table is meaningless without the one side. it holds the relationship between the two entities with one side gone there is no context`.

If `SET NULL` were used instead, `orphaned records would pollute the database`.

---

#### `amenity.property_id → property.property_id`

**ON DELETE choice:** `CASCADE`

This constraint governs what happens when an `property` is removed from the platform.

The real-world event represented by this deletion is `the property is no longer available on the platform`.

When this occurs, `the properties amenities are also removed from the amenity table`. The selected `ON DELETE` behavior causes `a cleanup of the multi-value table and removal of any orphaned records`.

This behavior was chosen because `it cleans up the dangeling amenities that are no longer associated with any property`.

If `SET NULL` were used instead, `orphaned records would pollute the database`.

---

## CHECK Constraints

The following `CHECK` constraints prevent invalid domain states from being stored in the database.

### `ck_no_negative_listing_price`

**Table:** `property`

**Constraint:**

```sql
CHECK (listing_price >= 0)
```

This constraint prevents the database from storing a record where `the listing price is negative`.

The invalid state could otherwise occur because numeric can store negative values.

---

### `ck_no_negative_duration`

**Table:** `viewing`

**Constraint:**

```sql
CHECK (duration_min >= 0)
```

This constraint prevents `negative duration of a viewing`.

The invalid state could otherwise occur because an integer can store negative values.

---
