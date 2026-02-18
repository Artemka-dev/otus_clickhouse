-- Создание таблицы с расписанием
CREATE TABLE IF NOT EXISTS ya.schedule
(
    number String,
    route String,
    route_short Nullable(String),
    airline_name Nullable(String),
    airline_iata Nullable(String),
    aircraft_name Nullable(String),
    uid String,
    event String,
    yairport String,
    date String,
    ydate Date MATERIALIZED toDate(parseDateTime64BestEffort(date)),
    weekday UInt8 MATERIALIZED toDayOfWeek(ydate, 0)
)
ENGINE = ReplacingMergeTree
ORDER BY uid
PARTITION BY toYYYYMMDD(ydate);

-- Инкрементирование данных
SELECT
    CAST(
    	if(
    		s.dt = '1970-01-01',
    		today() - 14,
    		s.dt
    	) AS String) AS dt,
    a.iata, 
    a.airport
FROM ya.airports a
LEFT JOIN (
    SELECT 
        yairport,
        toDate(max(parseDateTime64BestEffort(date))) + INTERVAL 1 DAY AS dt
    FROM ya.schedule
    GROUP BY yairport
) s ON a.iata = s.yairport
ORDER BY a.iata;

-- Таблица с самолетами
CREATE TABLE IF NOT EXISTS ya.aircrafts
(
	aircraft_name String,
	pax_avg Int64
)
Engine = MergeTree
order by aircraft_name;
