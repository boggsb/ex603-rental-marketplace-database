# Constraints

```sql
ALTER TABLE viewing
ADD CONSTRAINT fk_viewing_renter
    FOREIGN KEY (renter_id)
    REFERENCES renter(renter_id)
    ON DELETE CASCADE
    ;

ALTER TABLE viewing
ADD CONSTRAINT fk_viewing_property
    FOREIGN KEY (property_id)
    REFERENCES property(property_id)
    ON DELETE CASCADE
    ;

ALTER TABLE amenity_property
ADD CONSTRAINT fk_amenity_property
    FOREIGN KEY (property_id)
    REFERENCES property(property_id)
    ON DELETE CASCADE
    ;

ALTER TABLE amenity_property
ADD CONSTRAINT fk_amenity_property
    FOREIGN KEY (amenity_id)
    REFERENCES amenity(amenity_id)
    ON DELETE CASCADE
    ;
```
