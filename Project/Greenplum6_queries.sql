set schema 'bookings';

-- Последовательное сканирование
explain analyze select * from flights;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..551.27 rows=214867 width=123) (actual time=49.356..646.979 rows=214867 loops=1)
  ->  Seq Scan on flights  (cost=0.00..436.40 rows=71623 width=123) (actual time=34.268..133.273 rows=71653 loops=1)
Planning time: 6.952 ms
  (slice0)    Executor memory: 1066K bytes.
  (slice1)    Executor memory: 1086K bytes avg x 3 workers, 1086K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 659.481 ms

-- Сканирование индекса
-- create unique index bookings_pkey on bookings.bookings using btree (book_ref);
-- SQL Error [0A000]: ERROR: append-only tables do not support unique indexes
create index bookings_pkey on bookings.bookings using btree (book_ref);

explain analyze select * from bookings where book_ref = 'CDE08B';

Gather Motion 1:1  (slice1; segments: 1)  (cost=0.00..387.96 rows=1 width=36) (actual time=2.248..2.249 rows=1 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..387.96 rows=1 width=36) (actual time=1.699..1.707 rows=1 loops=1)
        Recheck Cond: (book_ref = 'CDE08B'::bpchar)
        ->  Bitmap Index Scan on bookings_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.119..0.119 rows=1 loops=1)
              Index Cond: (book_ref = 'CDE08B'::bpchar)
Planning time: 5.312 ms
  (slice0)    Executor memory: 92K bytes.
  (slice1)    Executor memory: 380K bytes (seg2).  Work_mem: 9K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 2.413 ms

-- Поиск по диапазону
explain analyze select * from bookings where book_ref > '000900' and book_ref < '000939';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..526.36 rows=337778 width=36) (actual time=183.599..199.950 rows=5 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..481.04 rows=112593 width=36) (actual time=187.065..187.375 rows=3 loops=1)
        Filter: ((book_ref > '000900'::bpchar) AND (book_ref < '000939'::bpchar))
Planning time: 4.382 ms
  (slice0)    Executor memory: 75K bytes.
  (slice1)    Executor memory: 204K bytes avg x 3 workers, 204K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 201.104 ms

-- Поиск отдельных значений
explain analyze select * from bookings where book_ref in ('000906','000909','000917','000930','000938');

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..387.98 rows=6 width=36) (actual time=0.003..1.773 rows=5 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..387.97 rows=2 width=36) (actual time=0.579..0.583 rows=3 loops=1)
        Recheck Cond: (book_ref = ANY ('{000906,000909,000917,000930,000938}'::bpchar[]))
        ->  Bitmap Index Scan on bookings_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.525..0.525 rows=3 loops=1)
              Index Cond: (book_ref = ANY ('{000906,000909,000917,000930,000938}'::bpchar[]))
Planning time: 4.356 ms
  (slice0)    Executor memory: 93K bytes.
  (slice1)    Executor memory: 383K bytes avg x 3 workers, 383K bytes max (seg0).  Work_mem: 9K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 3.929 ms

-- Сканирование по битовой карте
create index on bookings(book_date);
create index on bookings(total_amount);

explain analyze select * from bookings where total_amount < 5000;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..397.36 rows=3686 width=36) (actual time=1.803..5.327 rows=1471 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..396.79 rows=1229 width=36) (actual time=0.230..3.690 rows=497 loops=1)
        Recheck Cond: (total_amount < '5000'::numeric)
        ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=0.191..0.191 rows=497 loops=1)
              Index Cond: (total_amount < '5000'::numeric)
Planning time: 12.134 ms
  (slice0)    Executor memory: 120K bytes.
  (slice1)    Executor memory: 910K bytes avg x 3 workers, 910K bytes max (seg0).  Work_mem: 177K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 6.514 ms

-- Объединение битовых карт
explain analyze select * from bookings where total_amount < 5000 or total_amount > 500000;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..461.56 rows=14277 width=36) (actual time=0.011..14.577 rows=9636 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..459.33 rows=4759 width=36) (actual time=1.740..8.297 rows=3255 loops=1)
        Recheck Cond: ((total_amount < '5000'::numeric) OR (total_amount > '500000'::numeric))
        ->  BitmapOr  (cost=0.00..0.00 rows=0 width=0) (actual time=0.364..0.364 rows=1 loops=1)
              ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=0.031..0.031 rows=497 loops=1)
                    Index Cond: (total_amount < '5000'::numeric)
              ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=0.284..0.284 rows=2758 loops=1)
                    Index Cond: (total_amount > '500000'::numeric)
Planning time: 12.252 ms
  (slice0)    Executor memory: 152K bytes.
  (slice1)    Executor memory: 1319K bytes avg x 3 workers, 1319K bytes max (seg0).  Work_mem: 177K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 22.809 ms

-- Объединение битовых карт по разным индексам
explain analyze select * from bookings where total_amount < 5000 OR book_date::timestamp with time zone = bookings.now() - INTERVAL '1 day';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..629.12 rows=846519 width=36) (actual time=51.697..382.719 rows=1474 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..515.55 rows=282173 width=36) (actual time=0.158..313.646 rows=498 loops=1)
        Filter: ((total_amount < '5000'::numeric) OR ((book_date)::timestamp with time zone = '2017-08-14 18:00:00+03'::timestamp with time zone))
Planning time: 7.807 ms
  (slice0)    Executor memory: 103K bytes.
  (slice1)    Executor memory: 252K bytes avg x 3 workers, 252K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 385.537 ms

-- Объединение битовых карт с перепроверкой (Recheck Cond)
explain analyze select count(*) from bookings where total_amount < 5000 and book_date::timestamp with time zone > '2017-07-15 18:00:00+03'::timestamp;

Aggregate  (cost=0.00..396.52 rows=1 width=8) (actual time=9.359..9.359 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..396.52 rows=1 width=8) (actual time=8.562..9.354 rows=3 loops=1)
        ->  Aggregate  (cost=0.00..396.52 rows=1 width=8) (actual time=3.638..3.639 rows=1 loops=1)
              ->  Bitmap Heap Scan on bookings  (cost=0.00..396.52 rows=874 width=1) (actual time=0.143..3.684 rows=54 loops=1)
                    Recheck Cond: (total_amount < '5000'::numeric)
                    Filter: ((book_date)::timestamp with time zone > '2017-07-15 18:00:00'::timestamp without time zone)
                    ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=0.033..0.033 rows=497 loops=1)
                          Index Cond: (total_amount < '5000'::numeric)
Planning time: 6.533 ms
  (slice0)    Executor memory: 92K bytes.
  (slice1)    Executor memory: 948K bytes avg x 3 workers, 948K bytes max (seg0).  Work_mem: 177K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 13.339 ms

-- Сканирование только индекса
explain analyze select total_amount from bookings where total_amount > 200000;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..477.18 rows=141023 width=6) (actual time=2.166..176.787 rows=141535 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..474.03 rows=47008 width=6) (actual time=0.037..144.100 rows=47209 loops=1)
        Filter: (total_amount > '200000'::numeric)
Planning time: 2.125 ms
  (slice0)    Executor memory: 103K bytes.
  (slice1)    Executor memory: 226K bytes avg x 3 workers, 226K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 183.675 ms

-- Сканирование многоколоночного индекса
explain analyze select * from ticket_flights where ticket_no = '0005432000284' and flight_id = 187662;

Gather Motion 1:1  (slice1; segments: 1)  (cost=0.00..685.83 rows=1 width=32) (actual time=605.883..605.884 rows=1 loops=1)
  ->  Seq Scan on ticket_flights  (cost=0.00..685.83 rows=1 width=32) (actual time=413.019..603.974 rows=1 loops=1)
        Filter: ((ticket_no = '0005432000284'::bpchar) AND (flight_id = 187662))
Planning time: 12.919 ms
  (slice0)    Executor memory: 75K bytes.
  (slice1)    Executor memory: 204K bytes (seg2).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 609.358 ms

-- Параллельное последовательное сканирование
explain analyze select count(*) from bookings;

Aggregate  (cost=0.00..451.66 rows=1 width=8) (actual time=286.273..286.273 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..451.66 rows=1 width=8) (actual time=211.581..286.266 rows=3 loops=1)
        ->  Aggregate  (cost=0.00..451.66 rows=1 width=8) (actual time=211.186..211.187 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..450.35 rows=703704 width=1) (actual time=0.029..36.459 rows=705433 loops=1)
Planning time: 2.103 ms
  (slice0)    Executor memory: 75K bytes.
  (slice1)    Executor memory: 202K bytes avg x 3 workers, 202K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 287.001 ms

-- Параллельное сканирование индекса
explain analyze select sum(total_amount) from bookings where book_ref < '400000';

Aggregate  (cost=0.00..480.50 rows=1 width=8) (actual time=197.542..197.542 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..480.50 rows=1 width=8) (actual time=134.856..197.527 rows=3 loops=1)
        ->  Aggregate  (cost=0.00..480.50 rows=1 width=8) (actual time=196.915..196.915 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..480.31 rows=281482 width=6) (actual time=0.389..182.489 rows=176113 loops=1)
                    Filter: (book_ref < '400000'::bpchar)
Planning time: 3.574 ms
  (slice0)    Executor memory: 106K bytes.
  (slice1)    Executor memory: 274K bytes avg x 3 workers, 274K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 198.112 ms

-- Параллельное сканирование только индекса
explain analyze select count(book_ref) from bookings where book_ref <= '400000';

Aggregate  (cost=0.00..477.39 rows=1 width=8) (actual time=205.166..205.166 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..477.39 rows=1 width=8) (actual time=153.534..205.159 rows=3 loops=1)
        ->  Aggregate  (cost=0.00..477.39 rows=1 width=8) (actual time=159.639..159.639 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..477.17 rows=281482 width=7) (actual time=0.044..144.201 rows=176113 loops=1)
                    Filter: (book_ref <= '400000'::bpchar)
Planning time: 3.196 ms
  (slice0)    Executor memory: 75K bytes.
  (slice1)    Executor memory: 234K bytes avg x 3 workers, 234K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 206.170 ms

-- Параллельное сканирование по битовой карте
explain analyze select count(*) from bookings where total_amount < 20000 and book_date::timestamp with time zone > '2017-07-15 18:00:00+03'::timestamp;

Aggregate  (cost=0.00..499.55 rows=1 width=8) (actual time=164.806..164.806 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..499.55 rows=1 width=8) (actual time=152.569..164.801 rows=3 loops=1)
        ->  Aggregate  (cost=0.00..499.55 rows=1 width=8) (actual time=155.310..155.310 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..499.55 rows=53585 width=1) (actual time=0.073..155.070 rows=6379 loops=1)
                    Filter: ((total_amount < '20000'::numeric) AND ((book_date)::timestamp with time zone > '2017-07-15 18:00:00'::timestamp without time zone))
Planning time: 5.583 ms
  (slice0)    Executor memory: 75K bytes.
  (slice1)    Executor memory: 266K bytes avg x 3 workers, 266K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 165.509 ms

-- Сортировка в оконных функциях
explain analyze select *, sum(total_amount) over (order by book_date) from bookings;

WindowAgg  (cost=0.00..3646.85 rows=703704 width=32) (actual time=3882.547..7583.311 rows=2111110 loops=1)
  Order By: book_date
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..3570.85 rows=2111110 width=36) (actual time=3882.534..6856.693 rows=2111110 loops=1)
        Merge Key: book_date
        ->  Sort  (cost=0.00..3287.62 rows=703704 width=36) (actual time=3704.895..3949.115 rows=705433 loops=1)
              Sort Key: book_date
              Sort Method:  external merge  Disk: 99104kB
              ->  Seq Scan on bookings  (cost=0.00..450.35 rows=703704 width=36) (actual time=0.030..47.393 rows=705433 loops=1)
Planning time: 1.867 ms
  (slice0)    Executor memory: 232K bytes.
* (slice1)    Executor memory: 74192K bytes avg x 3 workers, 74192K bytes max (seg0).  Work_mem: 73989K bytes max, 80750K bytes wanted.
Memory used:  128000kB
Memory wanted:  161698kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 7655.914 ms

-- Оконные функции, требующие разного порядка строк
explain analyze select *, sum(total_amount) over (order by book_date), count(*) over (order by book_ref) from bookings;

WindowAgg  (cost=0.00..11761.90 rows=703704 width=40) (actual time=15552.102..16722.627 rows=2111110 loops=1)
  Order By: book_ref
  ->  Sort  (cost=0.00..11694.35 rows=703704 width=32) (actual time=15552.091..16278.126 rows=2111110 loops=1)
        Sort Key: book_ref
        Sort Method:  external merge  Disk: 131232kB
        ->  WindowAgg  (cost=0.00..3646.85 rows=703704 width=32) (actual time=3935.967..8019.171 rows=2111110 loops=1)
              Order By: book_date
              ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..3570.85 rows=2111110 width=36) (actual time=3935.957..7095.723 rows=2111110 loops=1)
                    Merge Key: book_date
                    ->  Sort  (cost=0.00..3287.62 rows=703704 width=36) (actual time=3919.765..4194.611 rows=705433 loops=1)
                          Sort Key: book_date
                          Sort Method:  external merge  Disk: 99104kB
                          ->  Seq Scan on bookings  (cost=0.00..450.35 rows=703704 width=36) (actual time=0.039..35.284 rows=705433 loops=1)
Planning time: 1.734 ms
* (slice0)    Executor memory: 52337K bytes.  Work_mem: 52041K bytes max, 255408K bytes wanted.
* (slice1)    Executor memory: 52523K bytes avg x 3 workers, 52523K bytes max (seg0).  Work_mem: 52320K bytes max, 83455K bytes wanted.
Memory used:  128000kB
Memory wanted:  1021828kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 16810.499 ms

-- Применение группировки
explain analyze select fare_conditions from seats group by fare_conditions;

Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..431.07 rows=3 width=8) (actual time=9.863..9.864 rows=3 loops=1)
  ->  GroupAggregate  (cost=0.00..431.07 rows=1 width=8) (actual time=8.662..8.662 rows=2 loops=1)
        Group Key: fare_conditions
        ->  Sort  (cost=0.00..431.07 rows=1 width=8) (actual time=8.658..8.659 rows=6 loops=1)
              Sort Key: fare_conditions
              Sort Method:  quicksort  Memory: 99kB
              ->  Redistribute Motion 3:3  (slice1; segments: 3)  (cost=0.00..431.07 rows=1 width=8) (actual time=7.740..8.643 rows=6 loops=1)
                    Hash Key: fare_conditions
                    ->  HashAggregate  (cost=0.00..431.07 rows=1 width=8) (actual time=1.806..1.812 rows=3 loops=1)
                          Group Key: fare_conditions
                          Extra Text: (seg0)   Hash chain length 1.5 avg, 2 max, using 2 of 32 buckets; total 0 expansions.

                          ->  Seq Scan on seats  (cost=0.00..431.01 rows=447 width=8) (actual time=3.048..3.072 rows=457 loops=1)
Planning time: 7.260 ms
  (slice0)    Executor memory: 106K bytes.
  (slice1)    Executor memory: 260K bytes avg x 3 workers, 260K bytes max (seg0).
  (slice2)    Executor memory: 60K bytes avg x 3 workers, 60K bytes max (seg0).  Work_mem: 33K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 20.887 ms

-- Группировка сортировкой
-- create unique index ticket_flights_pkey on bookings.ticket_flights using btree (ticket_no, flight_id);
-- SQL Error [0A000]: ERROR: append-only tables do not support unique indexes
create index ticket_flights_pkey on bookings.ticket_flights using btree (ticket_no, flight_id);
analyze bookings.ticket_flights;
explain analyze select ticket_no, count(ticket_no) from ticket_flights group by ticket_no;

Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..1231.95 rows=2232246 width=22) (actual time=3664.277..5862.902 rows=2949857 loops=1)
  ->  HashAggregate  (cost=0.00..1048.94 rows=744082 width=22) (actual time=3665.278..3901.803 rows=984149 loops=1)
        Group Key: ticket_no
        Extra Text: (seg1)   Hash chain length 3.8 avg, 15 max, using 255900 of 262144 buckets; total 13 expansions.

        ->  Redistribute Motion 3:3  (slice1; segments: 3)  (cost=0.00..697.19 rows=2797284 width=14) (actual time=1.276..1797.067 rows=2799730 loops=1)
              Hash Key: ticket_no
              ->  Seq Scan on ticket_flights  (cost=0.00..501.77 rows=2797284 width=14) (actual time=0.052..262.677 rows=2799196 loops=1)
Planning time: 12.555 ms
  (slice0)    Executor memory: 103K bytes.
  (slice1)    Executor memory: 220K bytes avg x 3 workers, 220K bytes max (seg0).
  (slice2)    Executor memory: 65805K bytes avg x 3 workers, 65869K bytes max (seg1).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 5944.158 ms

-- Комбинированная группировка
explain analyze select fare_conditions, ticket_no, amount, count(*) from ticket_flights
  group by grouping sets (fare_conditions, ticket_no, amount);

Gather Motion 3:1  (slice4; segments: 3)  (cost=0.00..3633.18 rows=2232573 width=30) (actual time=6754.136..9424.559 rows=2950198 loops=1)
  ->  Sequence  (cost=0.00..3383.57 rows=744191 width=30) (actual time=1650.519..7331.892 rows=984270 loops=1)
        ->  Shared Scan (share slice:id 4:0)  (cost=0.00..650.25 rows=2797284 width=1) (actual time=880.980..968.579 rows=2799196 loops=1)
              ->  Materialize  (cost=0.00..650.25 rows=2797284 width=1) (actual time=0.000..941.137 rows=0 loops=1)
                    ->  Seq Scan on ticket_flights  (cost=0.00..501.77 rows=2797284 width=28) (actual time=0.022..183.412 rows=2799196 loops=1)
        ->  Append  (cost=0.00..2711.00 rows=744191 width=30) (actual time=212.680..5826.491 rows=984270 loops=1)
              ->  Result  (cost=0.00..822.52 rows=108 width=30) (actual time=212.679..212.700 rows=120 loops=1)
                    ->  HashAggregate  (cost=0.00..822.51 rows=108 width=14) (actual time=212.677..212.689 rows=120 loops=1)
                          Group Key: share0_ref2.amount
                          Extra Text: (seg1)   Hash chain length 3.8 avg, 9 max, using 32 of 32 buckets; total 0 expansions.

                          ->  Redistribute Motion 3:3  (slice1; segments: 3)  (cost=0.00..822.50 rows=108 width=14) (actual time=148.802..212.611 rows=359 loops=1)
                                Hash Key: share0_ref2.amount
                                ->  Result  (cost=0.00..822.49 rows=108 width=14) (actual time=662.566..662.607 rows=338 loops=1)
                                      ->  HashAggregate  (cost=0.00..822.49 rows=108 width=14) (actual time=662.565..662.592 rows=338 loops=1)
                                            Group Key: share0_ref2.amount
                                            Extra Text: (seg0)   Hash chain length 2.8 avg, 7 max, using 119 of 128 buckets; total 2 expansions.

                                            ->  Shared Scan (share slice:id 1:0)  (cost=0.00..471.45 rows=2797284 width=6) (actual time=0.033..116.288 rows=2799196 loops=1)
              ->  Result  (cost=0.00..1027.98 rows=744082 width=38) (actual time=5103.101..5544.369 rows=984149 loops=1)
                    ->  HashAggregate  (cost=0.00..999.71 rows=744082 width=22) (actual time=5103.100..5461.809 rows=984149 loops=1)
                          Group Key: share0_ref3.ticket_no
                          Extra Text: (seg0)   983447 groups total in 32 batches; 1 overflows; 1838814 spill groups.
(seg0)   Hash chain length 2.4 avg, 14 max, using 507813 of 589824 buckets; total 11 expansions.

                          ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..647.96 rows=2797284 width=14) (actual time=0.014..2758.154 rows=2799730 loops=1)
                                Hash Key: share0_ref3.ticket_no
                                ->  Result  (cost=0.00..525.38 rows=2797284 width=14) (actual time=0.191..450.483 rows=2799196 loops=1)
                                      ->  Shared Scan (share slice:id 2:0)  (cost=0.00..525.38 rows=2797284 width=14) (actual time=0.189..176.878 rows=2799196 loops=1)
              ->  Result  (cost=0.00..838.17 rows=1 width=32) (actual time=0.032..0.033 rows=2 loops=1)
                    ->  GroupAggregate  (cost=0.00..838.17 rows=1 width=16) (actual time=0.031..0.032 rows=2 loops=1)
                          Group Key: share0_ref4.fare_conditions
                          ->  Sort  (cost=0.00..838.17 rows=1 width=16) (actual time=0.027..0.027 rows=6 loops=1)
                                Sort Key: share0_ref4.fare_conditions
                                Sort Method:  quicksort  Memory: 99kB
                                ->  Redistribute Motion 3:3  (slice3; segments: 3)  (cost=0.00..838.17 rows=1 width=16) (actual time=0.003..0.005 rows=6 loops=1)
                                      Hash Key: share0_ref4.fare_conditions
                                      ->  Result  (cost=0.00..838.17 rows=1 width=16) (actual time=274.517..274.531 rows=3 loops=1)
                                            ->  HashAggregate  (cost=0.00..838.17 rows=1 width=16) (actual time=274.517..274.530 rows=3 loops=1)
                                                  Group Key: share0_ref4.fare_conditions
                                                  Extra Text: (seg0)   Hash chain length 1.5 avg, 2 max, using 2 of 32 buckets; total 0 expansions.

                                                  ->  Shared Scan (share slice:id 3:0)  (cost=0.00..484.93 rows=2797284 width=8) (actual time=1.501..90.602 rows=2799196 loops=1)
Planning time: 23.694 ms
  (slice0)    Executor memory: 304K bytes.
  (slice1)    Executor memory: 404K bytes avg x 3 workers, 404K bytes max (seg0).
  (slice2)    Executor memory: 236K bytes avg x 3 workers, 236K bytes max (seg0).
  (slice3)    Executor memory: 340K bytes avg x 3 workers, 340K bytes max (seg0).
* (slice4)    Executor memory: 23982K bytes avg x 3 workers, 23982K bytes max (seg0).  Work_mem: 15926K bytes max, 120544K bytes wanted.
Memory used:  128000kB
Memory wanted:  1206840kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 9554.464 ms

-- Группировка в параллельных планах
explain analyze select flight_id, count(*) from ticket_flights group by flight_id;

Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..879.68 rows=81603 width=12) (actual time=1117.991..1203.780 rows=150588 loops=1)
  ->  HashAggregate  (cost=0.00..876.03 rows=27201 width=12) (actual time=1116.845..1121.121 rows=50270 loops=1)
        Group Key: flight_id
        Extra Text: (seg0)   Hash chain length 3.2 avg, 15 max, using 15571 of 16384 buckets; total 9 expansions.

        ->  Redistribute Motion 3:3  (slice1; segments: 3)  (cost=0.00..872.55 rows=27201 width=12) (actual time=816.059..1089.552 rows=146247 loops=1)
              Hash Key: flight_id
              ->  Result  (cost=0.00..871.52 rows=27201 width=12) (actual time=814.378..882.389 rows=146214 loops=1)
                    ->  HashAggregate  (cost=0.00..871.52 rows=27201 width=12) (actual time=814.376..866.713 rows=146214 loops=1)
                          Group Key: flight_id
                          Extra Text: (seg2)   Hash chain length 4.5 avg, 15 max, using 32412 of 32768 buckets; total 10 expansions.

                          ->  Seq Scan on ticket_flights  (cost=0.00..501.77 rows=2797284 width=4) (actual time=0.027..158.701 rows=2799196 loops=1)
Planning time: 2.537 ms
  (slice0)    Executor memory: 103K bytes.
  (slice1)    Executor memory: 7716K bytes avg x 3 workers, 7737K bytes max (seg1).
  (slice2)    Executor memory: 3170K bytes avg x 3 workers, 3170K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 1210.477 ms

-- Соединение вложенным циклом
explain analyze select * from tickets t join ticket_flights tf on tf.ticket_no = t.ticket_no where t.ticket_no in ('0005432312163','0005432312164');

Hash Join  (cost=0.00..956.08 rows=4 width=132) (actual time=758.375..758.956 rows=8 loops=1)
  Hash Cond: (t.ticket_no = tf.ticket_no)
  Extra Text: Hash chain length 4.0 avg, 4 max, using 2 of 131072 buckets.
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..525.01 rows=3 width=100) (actual time=750.732..751.243 rows=2 loops=1)
        ->  Seq Scan on tickets t  (cost=0.00..525.00 rows=1 width=100) (actual time=98.385..750.398 rows=1 loops=1)
              Filter: ((ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[])) AND ((ticket_no = '0005432312163'::bpchar) OR (ticket_no = '0005432312164'::bpchar)))
  ->  Hash  (cost=431.07..431.07 rows=2 width=32) (actual time=7.550..7.550 rows=8 loops=1)
        Buckets: 131072  Batches: 1  Memory Usage: 1kB
        ->  Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..431.07 rows=5 width=32) (actual time=4.770..7.543 rows=8 loops=1)
              ->  Bitmap Heap Scan on ticket_flights tf  (cost=0.00..431.07 rows=2 width=32) (actual time=4.834..4.880 rows=4 loops=1)
                    Recheck Cond: ((ticket_no = '0005432312163'::bpchar) OR (ticket_no = '0005432312164'::bpchar))
                    ->  BitmapOr  (cost=0.00..0.00 rows=0 width=0) (actual time=1.458..1.458 rows=1 loops=1)
                          ->  Bitmap Index Scan on ticket_flights_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=1.319..1.319 rows=2 loops=1)
                                Index Cond: (ticket_no = '0005432312163'::bpchar)
                          ->  Bitmap Index Scan on ticket_flights_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.117..0.117 rows=2 loops=1)
                                Index Cond: (ticket_no = '0005432312164'::bpchar)
Planning time: 11.584 ms
  (slice0)    Executor memory: 1248K bytes.  Work_mem: 1K bytes max.
  (slice1)    Executor memory: 236K bytes avg x 3 workers, 236K bytes max (seg0).
  (slice2)    Executor memory: 1078K bytes avg x 3 workers, 1319K bytes max (seg0).  Work_mem: 33K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 762.758 ms

-- Вложенный цикл для левого соединения
explain analyze select * from aircrafts a left join seats s on (a.aircraft_code = s.aircraft_code) where a.model like 'аэробус%';

Hash Right Join  (cost=0.00..862.39 rows=50 width=83) (actual time=3.521..3.521 rows=0 loops=1)
  Hash Cond: (s.aircraft_code = ml.aircraft_code)
  Extra Text: Hash chain length 0.0 avg, 0 max, using 0 of 262144 buckets.
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..431.09 rows=1339 width=15) (never executed)
        ->  Seq Scan on seats s  (cost=0.00..431.01 rows=447 width=15) (actual time=0.012..0.027 rows=457 loops=1)
  ->  Hash  (cost=431.00..431.00 rows=1 width=68) (actual time=3.236..3.236 rows=0 loops=1)
        Buckets: 262144  Batches: 1  Memory Usage: 0kB
        ->  Gather Motion 1:1  (slice2; segments: 1)  (cost=0.00..431.00 rows=1 width=68) (actual time=3.236..3.236 rows=0 loops=1)
              ->  Seq Scan on aircrafts_data ml  (cost=0.00..431.00 rows=1 width=68) (actual time=0.000..1.346 rows=0 loops=1)
                    Filter: (model ~~ 'аэробус%'::text)
Planning time: 6.617 ms
  (slice0)    Executor memory: 2220K bytes.
  (slice1)    Executor memory: 204K bytes avg x 3 workers, 204K bytes max (seg0).
  (slice2)    Executor memory: 204K bytes (seg2).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 8.898 ms

-- Вложенный цикл для антисоединения
explain analyze select * from aircrafts a where a.model like 'аэробус%' 
  and not exists (select * from seats s where s.aircraft_code = a.aircraft_code);

Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..862.07 rows=1 width=68) (actual time=8.359..8.359 rows=0 loops=1)
  ->  Result  (cost=0.00..862.07 rows=1 width=68) (actual time=0.000..3.580 rows=0 loops=1)
        Filter: (COALESCE((count((count()))), '0'::bigint) = '0'::bigint)
        ->  Result  (cost=0.00..862.07 rows=1 width=28) (actual time=0.000..3.580 rows=0 loops=1)
              ->  Hash Left Join  (cost=0.00..862.07 rows=1 width=76) (actual time=0.000..3.580 rows=0 loops=1)
                    Hash Cond: (ml.aircraft_code = s.aircraft_code)
                    Extra Text: (seg2)   Hash chain length 1.0 avg, 1 max, using 8 of 262144 buckets.Hash chain length 1.0 avg, 1 max, using 9 of 32 buckets; total 0 expansions.

                    ->  Result  (cost=0.00..431.00 rows=1 width=68) (actual time=0.000..2.450 rows=0 loops=1)
                          ->  Seq Scan on aircrafts_data ml  (cost=0.00..431.00 rows=1 width=68) (actual time=0.000..2.449 rows=0 loops=1)
                                Filter: (model ~~ 'аэробус%'::text)
                    ->  Hash  (cost=431.07..431.07 rows=3 width=12) (actual time=3.120..3.120 rows=8 loops=1)
                          ->  GroupAggregate  (cost=0.00..431.07 rows=3 width=12) (actual time=3.114..3.117 rows=8 loops=1)
                                Group Key: s.aircraft_code
                                ->  Sort  (cost=0.00..431.07 rows=3 width=12) (actual time=3.110..3.112 rows=24 loops=1)
                                      Sort Key: s.aircraft_code
                                      Sort Method:  quicksort  Memory: 99kB
                                      ->  Redistribute Motion 3:3  (slice1; segments: 3)  (cost=0.00..431.07 rows=3 width=12) (actual time=2.253..3.082 rows=24 loops=1)
                                            Hash Key: s.aircraft_code
                                            ->  Result  (cost=0.00..431.07 rows=3 width=12) (actual time=0.069..0.073 rows=9 loops=1)
                                                  ->  HashAggregate  (cost=0.00..431.07 rows=3 width=12) (actual time=0.068..0.072 rows=9 loops=1)
                                                        Group Key: s.aircraft_code
                                                        Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 9 of 32 buckets; total 0 expansions.

                                                        ->  Seq Scan on seats s  (cost=0.00..431.01 rows=447 width=4) (actual time=0.025..0.047 rows=457 loops=1)
Planning time: 7.917 ms
  (slice0)    Executor memory: 155K bytes.
  (slice1)    Executor memory: 292K bytes avg x 3 workers, 292K bytes max (seg0).
  (slice2)    Executor memory: 2397K bytes avg x 3 workers, 2400K bytes max (seg2).  Work_mem: 65K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 9.043 ms

-- Вложенный цикл для полусоединения
explain analyze select * from aircrafts a where a.model like 'аэробус%'
  and exists (select * from seats s where s.aircraft_code = a.aircraft_code);

Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..862.07 rows=1 width=68) (actual time=2.500..2.500 rows=0 loops=1)
  ->  Hash Join  (cost=0.00..862.07 rows=1 width=68) (actual time=0.000..1.284 rows=0 loops=1)
        Hash Cond: (s.aircraft_code = ml.aircraft_code)
        ->  GroupAggregate  (cost=0.00..431.06 rows=3 width=4) (never executed)
              Group Key: s.aircraft_code
              ->  Sort  (cost=0.00..431.06 rows=3 width=4) (never executed)
                    Sort Key: s.aircraft_code
                    ->  Redistribute Motion 3:3  (slice1; segments: 3)  (cost=0.00..431.06 rows=3 width=4) (never executed)
                          Hash Key: s.aircraft_code
                          ->  HashAggregate  (cost=0.00..431.06 rows=3 width=4) (actual time=0.189..0.193 rows=9 loops=1)
                                Group Key: s.aircraft_code
                                Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 9 of 32 buckets; total 0 expansions.

                                ->  Seq Scan on seats s  (cost=0.00..431.01 rows=447 width=4) (actual time=0.028..0.153 rows=457 loops=1)
        ->  Hash  (cost=431.00..431.00 rows=1 width=68) (actual time=0.000..0.040 rows=0 loops=1)
              ->  Seq Scan on aircrafts_data ml  (cost=0.00..431.00 rows=1 width=68) (actual time=0.000..0.039 rows=0 loops=1)
                    Filter: (model ~~ 'аэробус%'::text)
Planning time: 9.803 ms
  (slice0)    Executor memory: 155K bytes.
  (slice1)    Executor memory: 260K bytes avg x 3 workers, 260K bytes max (seg0).
  (slice2)    Executor memory: 764K bytes avg x 3 workers, 764K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 4.464 ms

-- Мемоизация - кеширование повторяющихся данных внутреннего набора
explain analyze select * from flights f join aircrafts_data a on f.aircraft_code = a.aircraft_code where f.flight_no = 'PG0003';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..870.07 rows=277 width=191) (actual time=7.281..10.677 rows=113 loops=1)
  ->  Hash Join  (cost=0.00..869.87 rows=93 width=191) (actual time=9.080..9.865 rows=42 loops=1)
        Hash Cond: (f.aircraft_code = a.aircraft_code)
        Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 9 of 262144 buckets.
        ->  Seq Scan on flights f  (cost=0.00..438.77 rows=93 width=123) (actual time=8.924..9.618 rows=42 loops=1)
              Filter: (flight_no = 'PG0003'::bpchar)
        ->  Hash  (cost=431.00..431.00 rows=9 width=68) (actual time=0.039..0.039 rows=9 loops=1)
              ->  Seq Scan on aircrafts_data a  (cost=0.00..431.00 rows=9 width=68) (actual time=0.033..0.036 rows=9 loops=1)
Planning time: 7.992 ms
  (slice0)    Executor memory: 1130K bytes.
  (slice1)    Executor memory: 3353K bytes avg x 3 workers, 3358K bytes max (seg1).  Work_mem: 1K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 17.377 ms

-- Вложенный цикл в параллельных планах
explain analyze select t.passenger_name from tickets t join ticket_flights tf on tf.ticket_no = t.ticket_no
  join flights f on f.flight_id = tf.flight_id where f.flight_id = 12345;

Gather Motion 3:1  (slice3; segments: 3)  (cost=0.00..1768.97 rows=102 width=16) (actual time=1052.881..1086.814 rows=22 loops=1)
  ->  Hash Join  (cost=0.00..1768.96 rows=34 width=16) (actual time=822.131..1055.774 rows=9 loops=1)
        Hash Cond: (t.ticket_no = tf.ticket_no)
        Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 9 of 262144 buckets.
        ->  Seq Scan on tickets t  (cost=0.00..492.65 rows=983286 width=30) (actual time=0.039..149.835 rows=984149 loops=1)
        ->  Hash  (cost=1032.57..1032.57 rows=34 width=14) (actual time=638.139..638.139 rows=9 loops=1)
              ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..1032.57 rows=34 width=14) (actual time=95.941..638.126 rows=9 loops=1)
                    Hash Key: tf.ticket_no
                    ->  Hash Join  (cost=0.00..1032.56 rows=34 width=14) (actual time=291.924..637.291 rows=9 loops=1)
                          Hash Cond: (tf.flight_id = f.flight_id)
                          Extra Text: (seg2)   Hash chain length 1.0 avg, 1 max, using 1 of 262144 buckets.
                          ->  Seq Scan on ticket_flights tf  (cost=0.00..593.80 rows=34 width=18) (actual time=284.558..629.729 rows=9 loops=1)
                                Filter: (flight_id = 12345)
                          ->  Hash  (cost=438.75..438.75 rows=1 width=4) (actual time=4.568..4.568 rows=1 loops=1)
                                ->  Broadcast Motion 3:3  (slice1; segments: 3)  (cost=0.00..438.75 rows=1 width=4) (actual time=3.138..4.566 rows=1 loops=1)
                                      ->  Seq Scan on flights f  (cost=0.00..438.75 rows=1 width=4) (actual time=2.446..3.971 rows=1 loops=1)
                                            Filter: (flight_id = 12345)
Planning time: 11.371 ms
  (slice0)    Executor memory: 272K bytes.
  (slice1)    Executor memory: 177K bytes avg x 3 workers, 188K bytes max (seg2).
  (slice2)    Executor memory: 2304K bytes avg x 3 workers, 2304K bytes max (seg0).  Work_mem: 1K bytes max.
  (slice3)    Executor memory: 2304K bytes avg x 3 workers, 2304K bytes max (seg0).  Work_mem: 1K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 1090.931 ms

-- Функциональные зависимости предикатов (dependencies)
explain analyze select * from flights where flight_no = 'PG0007' and departure_airport = 'VKO';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..441.12 rows=25 width=123) (actual time=4.445..14.780 rows=396 loops=1)
  ->  Seq Scan on flights  (cost=0.00..441.11 rows=9 width=123) (actual time=0.141..9.846 rows=147 loops=1)
        Filter: ((flight_no = 'PG0007'::bpchar) AND (departure_airport = 'VKO'::bpchar))
Planning time: 2.694 ms
  (slice0)    Executor memory: 1130K bytes.
  (slice1)    Executor memory: 1086K bytes avg x 3 workers, 1086K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 15.975 ms

create statistics (dependencies) on flight_no, departure_airport from flights; -- не поддерживается
analyze flights;

-- Наиболее частые комбинации значений (mcv)
explain analyze select * from flights where departure_airport = 'LED' and aircraft_code = '321';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..441.78 rows=1261 width=123) (actual time=4.543..34.987 rows=5148 loops=1)
  ->  Seq Scan on flights  (cost=0.00..441.21 rows=421 width=123) (actual time=0.179..11.278 rows=1754 loops=1)
        Filter: ((departure_airport = 'LED'::bpchar) AND (aircraft_code = '321'::bpchar))
Planning time: 2.693 ms
  (slice0)    Executor memory: 1130K bytes.
  (slice1)    Executor memory: 1086K bytes avg x 3 workers, 1086K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 38.191 ms

create statistics (mcv) on departure_airport, aircraft_code from flights; -- не поддерживается
analyze flights;



-- Уникальные комбинации
explain analyze select distinct departure_airport, arrival_airport from flights;

Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..455.68 rows=6084 width=8) (actual time=10.703..10.727 rows=618 loops=1)
  ->  HashAggregate  (cost=0.00..455.50 rows=2028 width=8) (actual time=10.118..10.132 rows=208 loops=1)
        Group Key: departure_airport, arrival_airport
        Extra Text: (seg2)   Hash chain length 3.4 avg, 11 max, using 61 of 64 buckets; total 1 expansions.

        ->  Redistribute Motion 3:3  (slice1; segments: 3)  (cost=0.00..455.00 rows=2028 width=8) (actual time=9.956..9.980 rows=624 loops=1)
              Hash Key: departure_airport, arrival_airport
              ->  HashAggregate  (cost=0.00..454.95 rows=2028 width=8) (actual time=7.818..7.846 rows=618 loops=1)
                    Group Key: departure_airport, arrival_airport
                    Extra Text: (seg0)   Hash chain length 4.8 avg, 11 max, using 128 of 128 buckets; total 2 expansions.

                    ->  Seq Scan on flights  (cost=0.00..436.40 rows=71623 width=8) (actual time=0.063..2.995 rows=71653 loops=1)
Planning time: 3.251 ms
  (slice0)    Executor memory: 296K bytes.
  (slice1)    Executor memory: 388K bytes avg x 3 workers, 388K bytes max (seg0).
  (slice2)    Executor memory: 144K bytes avg x 3 workers, 144K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 11.975 ms

create statistics on departure_airport, arrival_airport from flights; -- не поддерживается
analyze flights;



-- Статистика по выражению
explain analyze select * from flights where extract(month from scheduled_departure at time zone 'Europe/Moscow') = 1; -- не поддерживается



create statistics on extract(month from scheduled_departure at time zone 'europe/moscow') from flights; -- не поддерживается
analyze flights;



select * from pg_stats_ext;
select * from pg_stats_ext_exprs;
select * from pg_statistic_ext;
select * from pg_statistic_ext_data;

analyze flights;

-- Узел Materialize

explain analyze select a1.city, a2.city from airports a1, airports a2 where a1.timezone = 'Europe/Moscow' -- не поддерживается
  and abs(a2.coordinates[1]) > 66.652; -- за полярным кругом



-- Материализация CTE - не поддерживается
explain analyze
  with q as materialized (select f.flight_id, a.aircraft_code from flights f join aircrafts a on a.aircraft_code = f.aircraft_code) 
  select * from q join seats s on s.aircraft_code = q.aircraft_code where s.seat_no = '1A';
-- SQL Error [42601]: ERROR: syntax error at or near "materialized"


-- Рекурсивные запросы
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

Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..486170.06 rows=744977 width=8) (actual time=98.839..146.291 rows=214971 loops=1)
  ->  Recursive Union  (cost=0.00..486170.06 rows=248326 width=8) (actual time=2.255..125.742 rows=98696 loops=1)
        ->  Seq Scan on airports_data ml  (cost=0.00..2.04 rows=35 width=4) (actual time=2.254..2.260 rows=37 loops=1)
        ->  Hash Join  (cost=19588.86..47126.85 rows=24830 width=8) (actual time=47.308..52.973 rows=49330 loops=2)
              Hash Cond: (r.airport_code = f.departure_airport)
              Extra Text: (seg0)   Hash chain length 2066.0 avg, 20875 max, using 104 of 524288 buckets.
              ->  WorkTable Scan on r  (cost=0.00..23.40 rows=116 width=20) (actual time=0.004..0.772 rows=18 loops=2)
                    Filter: (n < 2)
              ->  Hash  (cost=11531.35..11531.35 rows=214867 width=8) (actual time=93.459..93.459 rows=214867 loops=1)
                    ->  Broadcast Motion 3:3  (slice1; segments: 3)  (cost=0.00..11531.35 rows=214867 width=8) (actual time=0.012..66.465 rows=214867 loops=1)
                          ->  Seq Scan on flights f  (cost=0.00..2936.67 rows=71623 width=8) (actual time=0.139..4.825 rows=71653 loops=1)
Planning time: 4.790 ms
  (slice0)    Executor memory: 536K bytes.
  (slice1)    Executor memory: 380K bytes avg x 3 workers, 380K bytes max (seg0).
  (slice2)    Executor memory: 32984K bytes avg x 3 workers, 34008K bytes max (seg0).  Work_mem: 8394K bytes max.
Memory used:  128000kB
Optimizer: Postgres query optimizer
Execution time: 158.073 ms




