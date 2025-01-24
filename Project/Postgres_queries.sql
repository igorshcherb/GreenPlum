-- 01. Последовательное сканирование
explain analyze select * from flights;

Seq Scan on flights  (cost=0.00..4772.67 rows=214867 width=63) (actual time=0.185..42.513 rows=214867 loops=1)
Planning Time: 2.947 ms
Execution Time: 45.491 ms

-- 02. Сканирование индекса
explain analyze select * from bookings where book_ref = 'CDE08B';

Index Scan using bookings_pkey on bookings  (cost=0.43..8.45 rows=1 width=21) (actual time=0.488..0.488 rows=1 loops=1)
  Index Cond: (book_ref = 'CDE08B'::bpchar)
Planning Time: 8.805 ms
Execution Time: 0.508 ms

-- 03. Поиск по диапазону
explain analyze select * from bookings where book_ref > '000900' and book_ref < '000939';

Index Scan using bookings_pkey on bookings  (cost=0.43..8.45 rows=1 width=21) (actual time=0.129..0.130 rows=5 loops=1)
  Index Cond: ((book_ref > '000900'::bpchar) AND (book_ref < '000939'::bpchar))
Planning Time: 1.992 ms
Execution Time: 0.139 ms

-- 04. Поиск отдельных значений
explain analyze select * from bookings where book_ref in ('000906','000909','000917','000930','000938');

Index Scan using bookings_pkey on bookings  (cost=0.43..26.24 rows=5 width=21) (actual time=0.021..0.021 rows=5 loops=1)
  Index Cond: (book_ref = ANY ('{000906,000909,000917,000930,000938}'::bpchar[]))
Planning Time: 0.133 ms
Execution Time: 0.031 ms

-- 05. Сканирование по битовой карте
create index on bookings(book_date);
create index on bookings(total_amount);

explain analyze select * from bookings where total_amount < 5000;

Bitmap Heap Scan on bookings  (cost=95.00..9929.12 rows=4977 width=21) (actual time=0.269..10.092 rows=1471 loops=1)
  Recheck Cond: (total_amount < '5000'::numeric)
  Heap Blocks: exact=1398
  ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..93.76 rows=4977 width=0) (actual time=0.148..0.148 rows=1471 loops=1)
        Index Cond: (total_amount < '5000'::numeric)
Planning Time: 1.044 ms
Execution Time: 10.130 ms

-- 06. Объединение битовых карт
explain analyze select * from bookings where total_amount < 5000 or total_amount > 500000;

Bitmap Heap Scan on bookings  (cost=315.86..14750.55 rows=16350 width=21) (actual time=1.824..40.199 rows=9636 loops=1)
  Recheck Cond: ((total_amount < '5000'::numeric) OR (total_amount > '500000'::numeric))
  Heap Blocks: exact=6838
  ->  BitmapOr  (cost=315.86..315.86 rows=16377 width=0) (actual time=1.351..1.352 rows=0 loops=1)
        ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..93.76 rows=4977 width=0) (actual time=0.138..0.138 rows=1471 loops=1)
              Index Cond: (total_amount < '5000'::numeric)
        ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..213.93 rows=11400 width=0) (actual time=1.212..1.212 rows=8165 loops=1)
              Index Cond: (total_amount > '500000'::numeric)
Planning Time: 0.380 ms
Execution Time: 40.453 ms

-- 07. Объединение битовых карт по разным индексам
explain analyze select * from bookings where total_amount < 5000 OR book_date = bookings.now() - INTERVAL '1 day';

Bitmap Heap Scan on bookings  (cost=100.72..9965.76 rows=4982 width=21) (actual time=0.240..1.263 rows=1474 loops=1)
  Recheck Cond: ((total_amount < '5000'::numeric) OR (book_date = ('2017-08-15 18:00:00+03'::timestamp with time zone - '1 day'::interval)))
  Heap Blocks: exact=1401
  ->  BitmapOr  (cost=100.72..100.72 rows=4982 width=0) (actual time=0.150..0.150 rows=0 loops=1)
        ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..93.76 rows=4977 width=0) (actual time=0.118..0.118 rows=1471 loops=1)
              Index Cond: (total_amount < '5000'::numeric)
        ->  Bitmap Index Scan on bookings_book_date_idx  (cost=0.00..4.47 rows=5 width=0) (actual time=0.031..0.031 rows=3 loops=1)
              Index Cond: (book_date = ('2017-08-15 18:00:00+03'::timestamp with time zone - '1 day'::interval))
Planning Time: 0.302 ms
Execution Time: 1.290 ms

-- 08. Объединение битовых карт с перепроверкой (Recheck Cond)
explain analyze select count(*) from bookings where total_amount < 5000 and book_date > '2017-07-15 18:00:00+03'::timestamp;

Aggregate  (cost=4018.91..4018.92 rows=1 width=8) (actual time=7.178..7.179 rows=1 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=2576.39..4017.87 rows=419 width=0) (actual time=7.164..7.171 rows=129 loops=1)
        Recheck Cond: ((total_amount < '5000'::numeric) AND (book_date > '2017-07-15 18:00:00'::timestamp without time zone))
        Heap Blocks: exact=129
        ->  BitmapAnd  (cost=2576.39..2576.39 rows=419 width=0) (actual time=7.144..7.144 rows=0 loops=1)
              ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..93.76 rows=4977 width=0) (actual time=0.115..0.116 rows=1471 loops=1)
                    Index Cond: (total_amount < '5000'::numeric)
              ->  Bitmap Index Scan on bookings_book_date_idx  (cost=0.00..2482.17 rows=177832 width=0) (actual time=6.903..6.903 rows=178142 loops=1)
                    Index Cond: (book_date > '2017-07-15 18:00:00'::timestamp without time zone)
Planning Time: 0.170 ms
Execution Time: 7.233 ms

-- 09. Сканирование только индекса
explain analyze select total_amount from bookings where total_amount > 200000;

Index Only Scan using bookings_total_amount_idx on bookings  (cost=0.43..4120.96 rows=138773 width=6) (actual time=3.958..11.770 rows=141535 loops=1)
  Index Cond: (total_amount > '200000'::numeric)
  Heap Fetches: 0
Planning Time: 0.074 ms
Execution Time: 13.713 ms

-- 10. Сканирование многоколоночного индекса
explain analyze select * from ticket_flights where ticket_no = '0005432000284' and flight_id = 187662;

Index Scan using ticket_flights_pkey on ticket_flights  (cost=0.56..8.58 rows=1 width=32) (actual time=0.873..0.876 rows=1 loops=1)
  Index Cond: ((ticket_no = '0005432000284'::bpchar) AND (flight_id = 187662))
Planning Time: 0.382 ms
Execution Time: 0.889 ms

-- 11. Параллельное последовательное сканирование
explain analyze select count(*) from bookings;

Finalize Aggregate  (cost=25483.58..25483.59 rows=1 width=8) (actual time=66.416..70.560 rows=1 loops=1)
  ->  Gather  (cost=25483.36..25483.57 rows=2 width=8) (actual time=66.184..70.556 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Partial Aggregate  (cost=24483.36..24483.37 rows=1 width=8) (actual time=41.849..41.849 rows=1 loops=3)
              ->  Parallel Seq Scan on bookings  (cost=0.00..22284.29 rows=879629 width=0) (actual time=0.020..27.353 rows=703703 loops=3)
Planning Time: 0.090 ms
Execution Time: 70.595 ms

-- 12. Параллельное сканирование индекса
explain analyze select sum(total_amount) from bookings where book_ref < '400000';

Finalize Aggregate  (cost=16874.81..16874.82 rows=1 width=32) (actual time=62.093..67.272 rows=1 loops=1)
  ->  Gather  (cost=16874.59..16874.80 rows=2 width=32) (actual time=61.843..67.263 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Partial Aggregate  (cost=15874.59..15874.60 rows=1 width=32) (actual time=42.371..42.371 rows=1 loops=3)
              ->  Parallel Index Scan using bookings_pkey on bookings  (cost=0.43..15324.82 rows=219907 width=6) (actual time=0.062..35.066 rows=175825 loops=3)
                    Index Cond: (book_ref < '400000'::bpchar)
Planning Time: 0.128 ms
Execution Time: 67.302 ms

-- 13. Параллельное сканирование только индекса
explain analyze select count(book_ref) from bookings where book_ref <= '400000';

Finalize Aggregate  (cost=13513.81..13513.82 rows=1 width=8) (actual time=131.309..134.209 rows=1 loops=1)
  ->  Gather  (cost=13513.60..13513.81 rows=2 width=8) (actual time=30.072..134.203 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Partial Aggregate  (cost=12513.60..12513.61 rows=1 width=8) (actual time=10.917..10.917 rows=1 loops=3)
              ->  Parallel Index Only Scan using bookings_pkey on bookings  (cost=0.43..11963.83 rows=219907 width=7) (actual time=0.037..6.879 rows=175825 loops=3)
                    Index Cond: (book_ref <= '400000'::bpchar)
                    Heap Fetches: 0
Planning Time: 0.105 ms
Execution Time: 134.235 ms

-- 14. Параллельное сканирование по битовой карте
explain analyze select count(*) from bookings where total_amount < 20000 and book_date > '2017-07-15 18:00:00+03'::timestamp;

Finalize Aggregate  (cost=18106.35..18106.36 rows=1 width=8) (actual time=60.220..64.862 rows=1 loops=1)
  ->  Gather  (cost=18106.13..18106.34 rows=2 width=8) (actual time=59.889..64.858 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Partial Aggregate  (cost=17106.13..17106.14 rows=1 width=8) (actual time=40.675..40.675 rows=1 loops=3)
              ->  Parallel Bitmap Heap Scan on bookings  (cost=2486.91..17086.36 rows=7907 width=0) (actual time=2.385..40.479 rows=6280 loops=3)
                    Recheck Cond: (book_date > '2017-07-15 18:00:00'::timestamp without time zone)
                    Filter: (total_amount < '20000'::numeric)
                    Rows Removed by Filter: 53100
                    Heap Blocks: exact=8322
                    ->  Bitmap Index Scan on bookings_book_date_idx  (cost=0.00..2482.17 rows=177832 width=0) (actual time=5.992..5.992 rows=178142 loops=1)
                          Index Cond: (book_date > '2017-07-15 18:00:00'::timestamp without time zone)
Planning Time: 0.156 ms
Execution Time: 64.897 ms

-- 15. Сортировка в оконных функциях
explain analyze select *, sum(total_amount) over (order by book_date) from bookings;

WindowAgg  (cost=0.74..130869.71 rows=2111110 width=53) (actual time=0.037..1676.154 rows=2111110 loops=1)
  ->  Index Scan using bookings_book_date_idx on bookings  (cost=0.43..99203.06 rows=2111110 width=21) (actual time=0.024..964.167 rows=2111110 loops=1)
Planning Time: 0.092 ms
Execution Time: 1715.510 ms

-- 16. Оконные функции, требующие разного порядка строк
explain analyze select *, sum(total_amount) over (order by book_date), count(*) over (order by book_ref) from bookings;

WindowAgg  (cost=422784.39..459728.73 rows=2111110 width=61) (actual time=1435.452..2277.898 rows=2111110 loops=1)
  ->  Sort  (cost=422784.30..428062.08 rows=2111110 width=29) (actual time=1435.430..1614.562 rows=2111110 loops=1)
        Sort Key: book_date
        Sort Method: external merge  Disk: 86840kB
        ->  WindowAgg  (cost=0.48..99992.73 rows=2111110 width=29) (actual time=0.015..660.577 rows=2111110 loops=1)
              ->  Index Scan using bookings_pkey on bookings  (cost=0.43..68326.08 rows=2111110 width=21) (actual time=0.009..179.186 rows=2111110 loops=1)
Planning Time: 0.062 ms
Execution Time: 2327.672 ms

-- 17. Применение группировки
explain analyze select fare_conditions from seats group by fare_conditions;

HashAggregate  (cost=24.74..24.77 rows=3 width=8) (actual time=0.587..0.591 rows=3 loops=1)
  Group Key: fare_conditions
  Batches: 1  Memory Usage: 24kB
  ->  Seq Scan on seats  (cost=0.00..21.39 rows=1339 width=8) (actual time=0.169..0.497 rows=1339 loops=1)
Planning Time: 3.776 ms
Execution Time: 2.365 ms

-- 18. Группировка сортировкой
explain analyze select ticket_no, count(ticket_no) from ticket_flights group by ticket_no;

GroupAggregate  (cost=0.56..360328.00 rows=2602930 width=22) (actual time=0.489..1412.900 rows=2949857 loops=1)
  Group Key: ticket_no
  ->  Index Only Scan using ticket_flights_pkey on ticket_flights  (cost=0.56..292338.09 rows=8392122 width=14) (actual time=0.481..757.100 rows=8391852 loops=1)
        Heap Fetches: 0
Planning Time: 0.113 ms
Execution Time: 1460.764 ms

-- 19. Комбинированная группировка
explain analyze select fare_conditions, ticket_no, amount, count(*) from ticket_flights
group by grouping sets (fare_conditions, ticket_no, amount);

MixedAggregate  (cost=1520583.60..3081161.02 rows=2603259 width=36) (actual time=5620.908..48787.941 rows=2950198 loops=1)
  Hash Key: amount
  Group Key: fare_conditions
  Sort Key: ticket_no
    Group Key: ticket_no
  Batches: 1  Memory Usage: 61kB
  ->  Sort  (cost=1520583.60..1541563.91 rows=8392122 width=28) (actual time=2503.118..3247.359 rows=8391852 loops=1)
        Sort Key: fare_conditions
        Sort Method: external merge  Disk: 315512kB
        ->  Seq Scan on ticket_flights  (cost=0.00..153881.22 rows=8392122 width=28) (actual time=0.097..654.073 rows=8391852 loops=1)
Planning Time: 0.055 ms
Execution Time: 48889.787 ms

-- 20. Группировка в параллельных планах
explain analyze select flight_id, count(*) from ticket_flights group by flight_id;

Finalize HashAggregate  (cost=141105.81..141910.13 rows=80432 width=12) (actual time=678.425..719.203 rows=150588 loops=1)
  Group Key: flight_id
  Batches: 5  Memory Usage: 8241kB  Disk Usage: 7800kB
  ->  Gather  (cost=123410.76..140301.49 rows=160864 width=12) (actual time=464.604..591.751 rows=435412 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Partial HashAggregate  (cost=122410.76..123215.09 rows=80432 width=12) (actual time=434.133..516.009 rows=145137 loops=3)
              Group Key: flight_id
              Batches: 5  Memory Usage: 8241kB  Disk Usage: 23320kB
              Worker 0:  Batches: 5  Memory Usage: 8241kB  Disk Usage: 28488kB
              Worker 1:  Batches: 5  Memory Usage: 8241kB  Disk Usage: 28432kB
              ->  Parallel Seq Scan on ticket_flights  (cost=0.00..104927.18 rows=3496718 width=4) (actual time=0.047..149.704 rows=2797284 loops=3)
Planning Time: 0.077 ms
Execution Time: 729.120 ms

-- 21. Соединение вложенным циклом
explain analyze select * from tickets t join ticket_flights tf on tf.ticket_no = t.ticket_no where t.ticket_no in ('0005432312163','0005432312164');

Nested Loop  (cost=0.99..46.12 rows=6 width=136) (actual time=0.389..0.451 rows=8 loops=1)
  ->  Index Scan using tickets_pkey on tickets t  (cost=0.43..12.90 rows=2 width=104) (actual time=0.351..0.352 rows=2 loops=1)
        Index Cond: (ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[]))
  ->  Index Scan using ticket_flights_pkey on ticket_flights tf  (cost=0.56..16.58 rows=3 width=32) (actual time=0.023..0.047 rows=4 loops=2)
        Index Cond: (ticket_no = t.ticket_no)
Planning Time: 3.902 ms
Execution Time: 0.467 ms

-- 22. Вложенный цикл для левого соединения
explain analyze select * from aircrafts a left join seats s on (a.aircraft_code = s.aircraft_code) where a.model like 'аэробус%';

Nested Loop Left Join  (cost=5.43..57.79 rows=149 width=67) (actual time=0.883..0.884 rows=0 loops=1)
  ->  Seq Scan on aircrafts_data ml  (cost=0.00..3.39 rows=1 width=52) (actual time=0.883..0.883 rows=0 loops=1)
        Filter: ((model ->> lang()) ~~ 'аэробус%'::text)
        Rows Removed by Filter: 9
  ->  Bitmap Heap Scan on seats s  (cost=5.43..15.29 rows=149 width=15) (never executed)
        Recheck Cond: (ml.aircraft_code = aircraft_code)
        ->  Bitmap Index Scan on seats_pkey  (cost=0.00..5.39 rows=149 width=0) (never executed)
              Index Cond: (aircraft_code = ml.aircraft_code)
Planning Time: 0.383 ms
Execution Time: 31.894 ms

-- 23. Вложенный цикл для антисоединения
explain analyze select * from aircrafts a where a.model like 'аэробус%' 
  and not exists (select * from seats s where s.aircraft_code = a.aircraft_code);

Nested Loop Anti Join  (cost=0.28..4.02 rows=1 width=52) (actual time=0.029..0.029 rows=0 loops=1)
  ->  Seq Scan on aircrafts_data ml  (cost=0.00..3.39 rows=1 width=52) (actual time=0.028..0.028 rows=0 loops=1)
        Filter: ((model ->> lang()) ~~ 'аэробус%'::text)
        Rows Removed by Filter: 9
  ->  Index Only Scan using seats_pkey on seats s  (cost=0.28..6.88 rows=149 width=4) (never executed)
        Index Cond: (aircraft_code = ml.aircraft_code)
        Heap Fetches: 0
Planning Time: 0.095 ms
Execution Time: 0.043 ms

-- 24. Вложенный цикл для полусоединения
explain analyze select * from aircrafts a where a.model like 'аэробус%'
  and exists (select * from seats s where s.aircraft_code = a.aircraft_code);

Nested Loop Semi Join  (cost=0.28..4.02 rows=1 width=52) (actual time=0.032..0.032 rows=0 loops=1)
  ->  Seq Scan on aircrafts_data ml  (cost=0.00..3.39 rows=1 width=52) (actual time=0.032..0.032 rows=0 loops=1)
        Filter: ((model ->> lang()) ~~ 'аэробус%'::text)
        Rows Removed by Filter: 9
  ->  Index Only Scan using seats_pkey on seats s  (cost=0.28..6.88 rows=149 width=4) (never executed)
        Index Cond: (aircraft_code = ml.aircraft_code)
        Heap Fetches: 0
Planning Time: 0.117 ms
Execution Time: 0.048 ms

-- 25. Мемоизация - кеширование повторяющихся данных внутреннего набора
explain analyze select * from flights f join aircrafts_data a on f.aircraft_code = a.aircraft_code where f.flight_no = 'PG0003';

Nested Loop  (cost=10.70..821.84 rows=275 width=115) (actual time=4.178..4.295 rows=113 loops=1)
  ->  Bitmap Heap Scan on flights f  (cost=10.55..813.62 rows=275 width=63) (actual time=4.142..4.239 rows=113 loops=1)
        Recheck Cond: (flight_no = 'PG0003'::bpchar)
        Heap Blocks: exact=2
        ->  Bitmap Index Scan on flights_flight_no_scheduled_departure_key  (cost=0.00..10.48 rows=275 width=0) (actual time=3.992..3.992 rows=113 loops=1)
              Index Cond: (flight_no = 'PG0003'::bpchar)
  ->  Memoize  (cost=0.15..0.21 rows=1 width=52) (actual time=0.000..0.000 rows=1 loops=113)
        Cache Key: f.aircraft_code
        Cache Mode: logical
        Hits: 112  Misses: 1  Evictions: 0  Overflows: 0  Memory Usage: 1kB
        ->  Index Scan using aircrafts_pkey on aircrafts_data a  (cost=0.14..0.20 rows=1 width=52) (actual time=0.025..0.025 rows=1 loops=1)
              Index Cond: (aircraft_code = f.aircraft_code)
Planning Time: 0.171 ms
Execution Time: 4.322 ms

-- 26. Вложенный цикл в параллельных планах
explain analyze select t.passenger_name from tickets t join ticket_flights tf on tf.ticket_no = t.ticket_no
  join flights f on f.flight_id = tf.flight_id where f.flight_id = 12345;

Nested Loop  (cost=1000.85..115048.09 rows=104 width=16) (actual time=97.104..157.785 rows=22 loops=1)
  ->  Index Only Scan using flights_pkey on flights f  (cost=0.42..4.44 rows=1 width=4) (actual time=4.526..4.528 rows=1 loops=1)
        Index Cond: (flight_id = 12345)
        Heap Fetches: 0
  ->  Gather  (cost=1000.43..115042.61 rows=104 width=20) (actual time=92.577..153.252 rows=22 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Nested Loop  (cost=0.43..114032.21 rows=43 width=20) (actual time=70.136..129.440 rows=7 loops=3)
              ->  Parallel Seq Scan on ticket_flights tf  (cost=0.00..113668.97 rows=43 width=18) (actual time=69.811..128.650 rows=7 loops=3)
                    Filter: (flight_id = 12345)
                    Rows Removed by Filter: 2797277
              ->  Index Scan using tickets_pkey on tickets t  (cost=0.43..8.45 rows=1 width=30) (actual time=0.106..0.106 rows=1 loops=22)
                    Index Cond: (ticket_no = tf.ticket_no)
Planning Time: 0.195 ms
Execution Time: 157.808 ms

-- 27. Функциональные зависимости предикатов (dependencies)
explain analyze select * from flights where flight_no = 'PG0007' and departure_airport = 'VKO';

Bitmap Heap Scan on flights  (cost=10.49..814.25 rows=14 width=63) (actual time=4.210..4.748 rows=396 loops=1)
  Recheck Cond: (flight_no = 'PG0007'::bpchar)
  Filter: (departure_airport = 'VKO'::bpchar)
  Heap Blocks: exact=12
  ->  Bitmap Index Scan on flights_flight_no_scheduled_departure_key  (cost=0.00..10.48 rows=275 width=0) (actual time=4.057..4.058 rows=396 loops=1)
        Index Cond: (flight_no = 'PG0007'::bpchar)
Planning Time: 0.103 ms
Execution Time: 4.775 ms

create statistics (dependencies) on flight_no, departure_airport from flights;
analyze flights;

Bitmap Heap Scan on flights  (cost=10.55..814.31 rows=275 width=63) (actual time=0.049..0.101 rows=396 loops=1)
  Recheck Cond: (flight_no = 'PG0007'::bpchar)
  Filter: (departure_airport = 'VKO'::bpchar)
  Heap Blocks: exact=12
  ->  Bitmap Index Scan on flights_flight_no_scheduled_departure_key  (cost=0.00..10.48 rows=275 width=0) (actual time=0.036..0.036 rows=396 loops=1)
        Index Cond: (flight_no = 'PG0007'::bpchar)
Planning Time: 1.167 ms
Execution Time: 0.123 ms

-- 28. Наиболее частые комбинации значений (mcv)
explain analyze select * from flights where departure_airport = 'LED' and aircraft_code = '321';
analyze flights;

Gather  (cost=1000.00..5598.39 rows=785 width=63) (actual time=0.409..33.842 rows=5148 loops=1)
  Workers Planned: 1
  Workers Launched: 1
  ->  Parallel Seq Scan on flights  (cost=0.00..4519.89 rows=462 width=63) (actual time=0.005..4.873 rows=2574 loops=2)
        Filter: ((departure_airport = 'LED'::bpchar) AND (aircraft_code = '321'::bpchar))
        Rows Removed by Filter: 104860
Planning Time: 0.064 ms
Execution Time: 33.928 ms

create statistics (mcv) on departure_airport, aircraft_code from flights;
analyze flights;

Seq Scan on flights  (cost=0.00..5847.00 rows=4949 width=63) (actual time=0.019..14.137 rows=5148 loops=1)
  Filter: ((departure_airport = 'LED'::bpchar) AND (aircraft_code = '321'::bpchar))
  Rows Removed by Filter: 209719
Planning Time: 0.101 ms
Execution Time: 14.217 ms

-- 29. Уникальные комбинации
explain analyze select distinct departure_airport, arrival_airport from flights;

HashAggregate  (cost=5847.01..5955.16 rows=10816 width=8) (actual time=26.281..26.333 rows=618 loops=1)
  Group Key: departure_airport, arrival_airport
  Batches: 1  Memory Usage: 433kB
  ->  Seq Scan on flights  (cost=0.00..4772.67 rows=214867 width=8) (actual time=0.008..5.606 rows=214867 loops=1)
Planning Time: 0.057 ms
Execution Time: 26.458 ms

create statistics on departure_airport, arrival_airport from flights;
analyze flights;

Unique  (cost=5554.72..5628.88 rows=618 width=8) (actual time=25.129..29.639 rows=618 loops=1)
  ->  Gather Merge  (cost=5554.72..5625.79 rows=618 width=8) (actual time=25.129..29.579 rows=704 loops=1)
        Workers Planned: 1
        Workers Launched: 1
        ->  Sort  (cost=4554.71..4556.26 rows=618 width=8) (actual time=13.359..13.365 rows=352 loops=2)
              Sort Key: departure_airport, arrival_airport
              Sort Method: quicksort  Memory: 39kB
              Worker 0:  Sort Method: quicksort  Memory: 27kB
              ->  HashAggregate  (cost=4519.88..4526.06 rows=618 width=8) (actual time=13.046..13.065 rows=352 loops=2)
                    Group Key: departure_airport, arrival_airport
                    Batches: 1  Memory Usage: 73kB
                    Worker 0:  Batches: 1  Memory Usage: 49kB
                    ->  Parallel Seq Scan on flights  (cost=0.00..3887.92 rows=126392 width=8) (actual time=0.005..2.893 rows=107434 loops=2)
Planning Time: 0.092 ms
Execution Time: 29.713 ms

-- 30. Статистика по выражению
explain analyze select * from flights where extract(month from scheduled_departure at time zone 'Europe/Moscow') = 1;

Gather  (cost=1000.00..5943.27 rows=1074 width=63) (actual time=0.436..36.086 rows=16831 loops=1)
  Workers Planned: 1
  Workers Launched: 1
  ->  Parallel Seq Scan on flights  (cost=0.00..4835.87 rows=632 width=63) (actual time=0.037..20.325 rows=8416 loops=2)
        Filter: (EXTRACT(month FROM (scheduled_departure AT TIME ZONE 'Europe/Moscow'::text)) = '1'::numeric)
        Rows Removed by Filter: 99018
Planning Time: 0.061 ms
Execution Time: 36.331 ms

create statistics on extract(month from scheduled_departure at time zone 'europe/moscow') from flights;
analyze flights;

Gather  (cost=1000.00..5943.27 rows=1074 width=63) (actual time=0.381..35.952 rows=16831 loops=1)
  Workers Planned: 1
  Workers Launched: 1
  ->  Parallel Seq Scan on flights  (cost=0.00..4835.87 rows=632 width=63) (actual time=0.031..19.941 rows=8416 loops=2)
        Filter: (EXTRACT(month FROM (scheduled_departure AT TIME ZONE 'Europe/Moscow'::text)) = '1'::numeric)
        Rows Removed by Filter: 99018
Planning Time: 2.482 ms
Execution Time: 36.206 ms

select * from pg_stats_ext;
select * from pg_stats_ext_exprs;
select * from pg_statistic_ext;
select * from pg_statistic_ext_data;

analyze flights;

-- 31. Узел Materialize

explain analyze select a1.city, a2.city from airports a1, airports a2 where a1.timezone = 'Europe/Moscow'
  and abs(a2.coordinates[1]) > 66.652; -- за полярным кругом

Nested Loop  (cost=0.00..805.90 rows=1540 width=64) (actual time=0.303..0.618 rows=176 loops=1)
  ->  Seq Scan on airports_data ml  (cost=0.00..4.30 rows=44 width=49) (actual time=0.169..0.175 rows=44 loops=1)
        Filter: (timezone = 'Europe/Moscow'::text)
        Rows Removed by Filter: 60
  ->  Materialize  (cost=0.00..4.74 rows=35 width=49) (actual time=0.000..0.004 rows=4 loops=44)
        ->  Seq Scan on airports_data ml_1  (cost=0.00..4.56 rows=35 width=49) (actual time=0.006..0.171 rows=4 loops=1)
              Filter: (abs(coordinates[1]) > '66.652'::double precision)
              Rows Removed by Filter: 100
Planning Time: 0.522 ms
Execution Time: 1.437 ms

-- 32. Материализация CTE
explain analyze
  with q as materialized (select f.flight_id, a.aircraft_code from flights f join aircrafts a on a.aircraft_code = f.aircraft_code) 
  select * from q join seats s on s.aircraft_code = q.aircraft_code where s.seat_no = '1A';

Hash Join  (cost=5628.35..10503.00 rows=9669 width=35) (actual time=0.077..72.641 rows=214867 loops=1)
  Hash Cond: (q.aircraft_code = s.aircraft_code)
  CTE q
    ->  Hash Join  (cost=1.20..5603.50 rows=214867 width=20) (actual time=0.032..29.226 rows=214867 loops=1)
          Hash Cond: (f.aircraft_code = ml.aircraft_code)
          ->  Seq Scan on flights f  (cost=0.00..4772.67 rows=214867 width=8) (actual time=0.008..6.127 rows=214867 loops=1)
          ->  Hash  (cost=1.09..1.09 rows=9 width=16) (actual time=0.007..0.008 rows=9 loops=1)
                Buckets: 1024  Batches: 1  Memory Usage: 9kB
                ->  Seq Scan on aircrafts_data ml  (cost=0.00..1.09 rows=9 width=16) (actual time=0.004..0.004 rows=9 loops=1)
  ->  CTE Scan on q  (cost=0.00..4297.34 rows=214867 width=20) (actual time=0.033..50.883 rows=214867 loops=1)
  ->  Hash  (cost=24.74..24.74 rows=9 width=15) (actual time=0.040..0.040 rows=9 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 9kB
        ->  Seq Scan on seats s  (cost=0.00..24.74 rows=9 width=15) (actual time=0.005..0.037 rows=9 loops=1)
              Filter: ((seat_no)::text = '1A'::text)
              Rows Removed by Filter: 1330
Planning Time: 0.147 ms
Execution Time: 77.298 ms

-- 33. Рекурсивные запросы
explain analyze
with recursive r(n, airport_code) as (
  select 1, a.airport_code
  from airports a
  union all
  select r.n+1, f.arrival_airport
  from r
  join flights f on f.departure_airport = r.airport_code
  where r.n < 2
  )
  select * from r;

CTE Scan on r  (cost=231263.79..305824.67 rows=3728044 width=20) (actual time=0.012..77.574 rows=214971 loops=1)
  CTE r
    ->  Recursive Union  (cost=0.00..231263.79 rows=3728044 width=8) (actual time=0.011..56.793 rows=214971 loops=1)
          ->  Seq Scan on airports_data ml  (cost=0.00..4.04 rows=104 width=8) (actual time=0.010..0.017 rows=104 loops=1)
          ->  Hash Join  (cost=27.74..19397.93 rows=372794 width=8) (actual time=4.281..20.879 rows=107434 loops=2)
                Hash Cond: (f.departure_airport = r_1.airport_code)
                ->  Seq Scan on flights f  (cost=0.00..4772.67 rows=214867 width=8) (actual time=0.003..6.224 rows=214867 loops=1)
                ->  Hash  (cost=23.40..23.40 rows=347 width=20) (actual time=4.272..4.272 rows=52 loops=2)
                      Buckets: 1024  Batches: 1  Memory Usage: 13kB
                      ->  WorkTable Scan on r r_1  (cost=0.00..23.40 rows=347 width=20) (actual time=4.267..4.269 rows=52 loops=2)
                            Filter: (n < 2)
                            Rows Removed by Filter: 107434
Planning Time: 0.112 ms
Execution Time: 82.810 ms

