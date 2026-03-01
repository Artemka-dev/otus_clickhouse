CREATE TABLE IF NOT EXISTS nyc_taxi.trips_small_D ON CLUSTER ruma AS nyc_taxi.trips_small ENGINE = Distributed('{cluster}', nyc_taxi, trips_small, rand())

ALTER TABLE nyc_taxi.trips_small ON CLUSTER ruma ADD COLUMN date DateTime DEFAULT now();
ALTER TABLE nyc_taxi.trips_small ON CLUSTER ruma MODIFY TTL date + INTERVAL 7 DAYS;
