-- =================================================================
-- EX 603 Assignment 2 — schema.sql
-- Theme: rental marketplace
-- Author: Bryant Boggs
-- Target: PostgreSQL 14+
-- =================================================================

drop table if exists amenity;
drop table if exists renter_viewing;
drop table if exists viewing;
drop table if exists property;
drop table if exists renter;

create table renter(
    renter_id int generated always as identity primary key,
    display_name varchar(25) unique not null,
    referring_renter_id int,
    constraint fk_referring_renter_id foreign key (referring_renter_id) references renter on delete set null
);

create table property(
    property_id int generated always as identity primary key,
    display_name varchar(25) not null,
    active_listing bool not null,
    monthly_rent numeric(10,2) not null,
    constraint ck_no_negative_monthly_rent check ( monthly_rent > 0 )
);

create table viewing(
    viewing_id int generated always as identity primary key,
    property_id int not null,
    duration_min int not null,
    viewing_at timestamp not null,
    constraint ck_no_negative_duration check (duration_min > 0),
    constraint fk_property_id foreign key (property_id) references property on delete cascade
);

create table renter_viewing(
    renter_id int not null,
    viewing_id int not null,
    constraint pk_renter_viewing primary key (renter_id, viewing_id),
    constraint fk_renter_id foreign key (renter_id) references renter on delete cascade,
    constraint fk_viewing_id foreign key (viewing_id) references viewing on delete cascade
);

create table amenity(
    property_id int not null,
    name varchar(50) not null,
    constraint pk_amenity primary key (property_id, name),
    constraint fk_property_multi_value foreign key (property_id) references property on delete cascade
);
