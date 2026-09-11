# Schema Definition

```sql
renter(
    renter_id INT PRIMARY KEY,
    display_name VARCHAR(255) UNIQUE NOT NULL,
)

property(
    property_id INT PRIMARY KEY,
    display_name VARCHAR(255) NOT NULL,
    active_listing BOOLEAN NOT NULL,
    listing_price INT NOT NULL,
)

viewing(
    viewing_id INT PRIMARY KEY,
    property_id INT NOT NULL,
    renter_id INT NOT NULL,
    duration_min INT NOT NULL,
    viewing_date TIMESTAMP NOT NULL,
)

amenity(
    amenity_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
)

amenity_property(
    amenity_id INT NOT NULL,
    property_id INT NOT NULL,
    PRIMARY KEY (amenity_id, property_id)
)
```
