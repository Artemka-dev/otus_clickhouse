# Создание таблиц

Для начала создаем две таблицы с разными PRIMARY KEY:

```sql
CREATE TABLE nyc_taxi.trips_small (
    trip_id             UInt32,
    pickup_datetime     DateTime,
    dropoff_datetime    DateTime,
    pickup_longitude    Nullable(Float64),
    pickup_latitude     Nullable(Float64),
    dropoff_longitude   Nullable(Float64),
    dropoff_latitude    Nullable(Float64),
    passenger_count     UInt8,
    trip_distance       Float32,
    fare_amount         Float32,
    extra               Float32,
    tip_amount          Float32,
    tolls_amount        Float32,
    total_amount        Float32,
    payment_type        Enum('CSH' = 1, 'CRE' = 2, 'NOC' = 3, 'DIS' = 4, 'UNK' = 5),
    pickup_ntaname      LowCardinality(String),
    dropoff_ntaname     LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (trip_id);


CREATE TABLE nyc_taxi.trips_small_PK (
    trip_id             UInt32,
    pickup_datetime     DateTime,
    dropoff_datetime    DateTime,
    pickup_longitude    Nullable(Float64),
    pickup_latitude     Nullable(Float64),
    dropoff_longitude   Nullable(Float64),
    dropoff_latitude    Nullable(Float64),
    passenger_count     UInt8,
    trip_distance       Float32,
    fare_amount         Float32,
    extra               Float32,
    tip_amount          Float32,
    tolls_amount        Float32,
    total_amount        Float32,
    payment_type        Enum('CSH' = 1, 'CRE' = 2, 'NOC' = 3, 'DIS' = 4, 'UNK' = 5),
    pickup_ntaname      LowCardinality(String),
    dropoff_ntaname     LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (total_amount);
```


# Сравнение двух запросов

```sql
select * from nyc_taxi.trips_small where total_amount < 5;
```

62783 rows in set. Elapsed: 0.083 sec. Processed 3.00 million rows, 217.99 MB (36.33 million rows/s., 2.64 GB/s.)
Peak memory usage: 60.51 MiB.

```sql
select * from nyc_taxi.trips_small_PK where total_amount < 5;
```

62783 rows in set. Elapsed: 0.022 sec. Processed 73.73 thousand rows, 4.89 MB (3.32 million rows/s., 220.11 MB/s.)
Peak memory usage: 12.39 MiB.


> Можно заметить, что выполнение второго запроса происходит быстрее, и при этом использование памяти и количество проанализированных строк гораздо меньше по сравнению с первым запросом


# Сравнение двух запросов с помощью EXPLAIN

```sql
EXPLAIN indexes=1 select * from nyc_taxi.trips_small where total_amount < 5;
```

Результат выполнения:

```text
05d7486f6a39 :) EXPLAIN indexes=1 select * from nyc_taxi.trips_small where total_amount < 5;

EXPLAIN indexes = 1
SELECT *
FROM nyc_taxi.trips_small
WHERE total_amount < 5

Query id: ccf4b683-a394-419f-8e5a-c3d87777a20d

   ┌─explain────────────────────────────────────────────────────────────┐
1. │ Expression ((Project names + Projection))                          │
2. │   Expression ((WHERE + Change column names to column identifiers)) │
3. │     ReadFromMergeTree (nyc_taxi.trips_small)                       │
4. │     Indexes:                                                       │
5. │       PrimaryKey                                                   │
6. │         Condition: true                                            │
7. │         Parts: 3/3                                                 │
8. │         Granules: 368/368                                          │
9. │       Ranges: 3                                                    │
   └────────────────────────────────────────────────────────────────────┘

9 rows in set. Elapsed: 0.007 sec. 

05d7486f6a39 :)
```


```sql
EXPLAIN indexes=1 select * from nyc_taxi.trips_small_PK where total_amount < 5;
```

```text
05d7486f6a39 :) EXPLAIN indexes=1 select * from nyc_taxi.trips_small_PK where total_amount < 5;

EXPLAIN indexes = 1
SELECT *
FROM nyc_taxi.trips_small_PK
WHERE total_amount < 5

Query id: 76708e03-29ba-4243-966e-fe96a5a98424

    ┌─explain────────────────────────────────────────────────────────────┐
 1. │ Expression ((Project names + Projection))                          │
 2. │   Expression ((WHERE + Change column names to column identifiers)) │
 3. │     ReadFromMergeTree (nyc_taxi.trips_small_PK)                    │
 4. │     Indexes:                                                       │
 5. │       PrimaryKey                                                   │
 6. │         Keys:                                                      │
 7. │           total_amount                                             │
 8. │         Condition: (total_amount in (-Inf, 5.))                    │
 9. │         Parts: 3/3                                                 │
10. │         Granules: 9/368                                            │
11. │         Search Algorithm: binary search                            │
12. │       Ranges: 3                                                    │
    └────────────────────────────────────────────────────────────────────┘

12 rows in set. Elapsed: 0.007 sec. 

05d7486f6a39 :)
```

> Можно заметить, что во втором случае используется index total_amount и при этом анализироваться будут 9 из 368 гранул, в отличие от второго запроса, где анализ будет производится по всей таблице
