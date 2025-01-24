set schema 'bookings';

-- 01
explain analyze select * from flights;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..552.06 rows=214867 width=123) (actual time=24.932..432.675 rows=214867 loops=1)
  ->  Seq Scan on flights  (cost=0.00..437.18 rows=71623 width=123) (actual time=22.051..69.204 rows=71653 loops=1)
Planning Time: 10.133 ms
  (slice0)    Executor memory: 36K bytes.
  (slice1)    Executor memory: 1118K bytes avg x 3x(0) workers, 1118K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 440.769 ms

-- 02
create unique index bookings_pkey on bookings.bookings using btree (book_ref);

explain analyze select * from bookings where book_ref = 'CDE08B';

Gather Motion 1:1  (slice1; segments: 1)  (cost=0.00..387.96 rows=1 width=36) (actual time=10.960..10.963 rows=1 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..387.96 rows=1 width=36) (actual time=9.650..9.659 rows=1 loops=1)
        Recheck Cond: (book_ref = 'CDE08B'::bpchar)
        ->  Bitmap Index Scan on bookings_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=1.088..1.088 rows=1 loops=1)
              Index Cond: (book_ref = 'CDE08B'::bpchar)
Planning Time: 4.698 ms
  (slice0)    Executor memory: 129K bytes.
  (slice1)    Executor memory: 515K bytes (seg2).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 14.297 ms

-- 03
explain analyze select * from bookings where book_ref > '000900' and book_ref < '000939';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..534.10 rows=337778 width=36) (actual time=78.165..80.627 rows=5 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..488.78 rows=112593 width=36) (actual time=80.070..80.150 rows=3 loops=1)
        Filter: ((book_ref > '000900'::bpchar) AND (book_ref < '000939'::bpchar))
Planning Time: 2.368 ms
  (slice0)    Executor memory: 18K bytes.
  (slice1)    Executor memory: 255K bytes avg x 3x(0) workers, 255K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 81.547 ms

-- 04
explain analyze select * from bookings where book_ref in ('000906','000909','000917','000930','000938');

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..387.98 rows=6 width=36) (actual time=2.788..3.581 rows=5 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..387.97 rows=2 width=36) (actual time=2.550..2.559 rows=3 loops=1)
        Recheck Cond: (book_ref = ANY ('{000906,000909,000917,000930,000938}'::bpchar[]))
        ->  Bitmap Index Scan on bookings_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.121..0.121 rows=3 loops=1)
              Index Cond: (book_ref = ANY ('{000906,000909,000917,000930,000938}'::bpchar[]))
Planning Time: 5.658 ms
  (slice0)    Executor memory: 129K bytes.
  (slice1)    Executor memory: 515K bytes avg x 3x(0) workers, 515K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 6.988 ms

-- 05
create index on bookings(book_date);
create index on bookings(total_amount);

explain analyze select * from bookings where total_amount < 5000;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..399.06 rows=4351 width=36) (actual time=3.096..9.930 rows=1471 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..398.38 rows=1451 width=36) (actual time=1.884..8.801 rows=497 loops=1)
        Recheck Cond: (total_amount < '5000'::numeric)
        ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=1.709..1.709 rows=497 loops=1)
              Index Cond: (total_amount < '5000'::numeric)
Planning Time: 6.380 ms
  (slice0)    Executor memory: 138K bytes.
  (slice1)    Executor memory: 2574K bytes avg x 3x(0) workers, 2574K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 10.845 ms

-- 06
explain analyze select * from bookings where total_amount < 5000 or total_amount > 500000;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..464.12 rows=15473 width=36) (actual time=2.270..15.918 rows=9636 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..461.70 rows=5158 width=36) (actual time=2.678..11.890 rows=3255 loops=1)
        Recheck Cond: ((total_amount < '5000'::numeric) OR (total_amount > '500000'::numeric))
        ->  BitmapOr  (cost=0.00..0.00 rows=0 width=0) (actual time=1.731..1.732 rows=1 loops=1)
              ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=0.186..0.187 rows=497 loops=1)
                    Index Cond: (total_amount < '5000'::numeric)
              ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=2.362..2.362 rows=2758 loops=1)
                    Index Cond: (total_amount > '500000'::numeric)
Planning Time: 3.872 ms
  (slice0)    Executor memory: 249K bytes.
  (slice1)    Executor memory: 4353K bytes avg x 3x(0) workers, 4353K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 19.263 ms

-- 07
explain analyze select * from bookings where total_amount < 5000 OR book_date::timestamp with time zone = bookings.now() - INTERVAL '1 day';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..636.92 rows=846893 width=36) (actual time=101.179..239.460 rows=1474 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..523.30 rows=282298 width=36) (actual time=0.606..231.668 rows=498 loops=1)
        Filter: ((total_amount < '5000'::numeric) OR ((book_date)::timestamp with time zone = '2017-08-14 18:00:00+03'::timestamp with time zone))
Planning Time: 5.085 ms
  (slice0)    Executor memory: 28K bytes.
  (slice1)    Executor memory: 264K bytes avg x 3x(0) workers, 264K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 240.117 ms

-- 08
explain analyze select count(*) from bookings where total_amount < 5000 and book_date::timestamp with time zone > '2017-07-15 18:00:00+03'::timestamp;

Finalize Aggregate  (cost=0.00..398.07 rows=1 width=8) (actual time=7.703..7.705 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..398.07 rows=1 width=8) (actual time=7.143..7.689 rows=3 loops=1)
        ->  Partial Aggregate  (cost=0.00..398.07 rows=1 width=8) (actual time=2.893..2.894 rows=1 loops=1)
              ->  Bitmap Heap Scan on bookings  (cost=0.00..398.07 rows=1032 width=1) (actual time=0.376..3.588 rows=54 loops=1)
                    Recheck Cond: (total_amount < '5000'::numeric)
                    Filter: ((book_date)::timestamp with time zone > '2017-07-15 18:00:00'::timestamp without time zone)
                    Rows Removed by Filter: 443
                    ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=0.200..0.201 rows=497 loops=1)
                          Index Cond: (total_amount < '5000'::numeric)
Planning Time: 6.367 ms
  (slice0)    Executor memory: 152K bytes.
  (slice1)    Executor memory: 2579K bytes avg x 3x(0) workers, 2579K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 14.811 ms

-- 09
explain analyze select total_amount from bookings where total_amount > 200000;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..484.99 rows=143499 width=6) (actual time=2.981..85.813 rows=141535 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..481.78 rows=47833 width=6) (actual time=0.063..70.120 rows=47209 loops=1)
        Filter: (total_amount > '200000'::numeric)
Planning Time: 2.432 ms
  (slice0)    Executor memory: 32K bytes.
  (slice1)    Executor memory: 264K bytes avg x 3x(0) workers, 264K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 91.639 ms

-- 10
explain analyze select * from ticket_flights where ticket_no = '0005432000284' and flight_id = 187662;

Gather Motion 1:1  (slice1; segments: 1)  (cost=0.00..716.60 rows=1 width=32) (actual time=844.139..844.141 rows=1 loops=1)
  ->  Seq Scan on ticket_flights  (cost=0.00..716.60 rows=1 width=32) (actual time=472.080..842.705 rows=1 loops=1)
        Filter: ((ticket_no = '0005432000284'::bpchar) AND (flight_id = 187662))
Planning Time: 3.717 ms
  (slice0)    Executor memory: 18K bytes.
  (slice1)    Executor memory: 255K bytes (seg2).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 844.998 ms

-- 11
explain analyze select count(*) from bookings;

Finalize Aggregate  (cost=0.00..459.40 rows=1 width=8) (actual time=161.788..161.795 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..459.40 rows=1 width=8) (actual time=147.374..161.767 rows=3 loops=1)
        ->  Partial Aggregate  (cost=0.00..459.40 rows=1 width=8) (actual time=149.006..149.007 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..458.09 rows=703704 width=1) (actual time=0.073..132.035 rows=705433 loops=1)
Planning Time: 1.837 ms
  (slice0)    Executor memory: 34K bytes.
  (slice1)    Executor memory: 263K bytes avg x 3x(0) workers, 263K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 169.841 ms

-- 12
explain analyze select sum(total_amount) from bookings where book_ref < '400000';

Finalize Aggregate  (cost=0.00..488.24 rows=1 width=8) (actual time=91.642..91.644 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..488.24 rows=1 width=8) (actual time=82.573..91.613 rows=3 loops=1)
        ->  Partial Aggregate  (cost=0.00..488.24 rows=1 width=8) (actual time=79.493..79.494 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..488.05 rows=281482 width=6) (actual time=0.056..66.862 rows=176113 loops=1)
                    Filter: (book_ref < '400000'::bpchar)
Planning Time: 3.595 ms
  (slice0)    Executor memory: 124K bytes.
  (slice1)    Executor memory: 266K bytes avg x 3x(0) workers, 266K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 97.709 ms

-- 13
explain analyze select count(book_ref) from bookings where book_ref <= '400000';

Finalize Aggregate  (cost=0.00..485.13 rows=1 width=8) (actual time=56.195..56.196 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..485.13 rows=1 width=8) (actual time=50.234..56.183 rows=3 loops=1)
        ->  Partial Aggregate  (cost=0.00..485.13 rows=1 width=8) (actual time=49.025..49.026 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..484.91 rows=281482 width=7) (actual time=0.060..44.253 rows=176113 loops=1)
                    Filter: (book_ref <= '400000'::bpchar)
Planning Time: 3.217 ms
  (slice0)    Executor memory: 38K bytes.
  (slice1)    Executor memory: 265K bytes avg x 3x(0) workers, 265K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 56.840 ms

-- 14
explain analyze select count(*) from bookings where total_amount < 20000 and book_date::timestamp with time zone > '2017-07-15 18:00:00+03'::timestamp;

Finalize Aggregate  (cost=0.00..507.24 rows=1 width=8) (actual time=79.506..79.507 rows=1 loops=1)
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..507.24 rows=1 width=8) (actual time=64.483..79.383 rows=3 loops=1)
        ->  Partial Aggregate  (cost=0.00..507.24 rows=1 width=8) (actual time=67.101..67.102 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..507.24 rows=52666 width=1) (actual time=0.087..66.845 rows=6379 loops=1)
                    Filter: ((total_amount < '20000'::numeric) AND ((book_date)::timestamp with time zone > '2017-07-15 18:00:00'::timestamp without time zone))
Planning Time: 3.958 ms
  (slice0)    Executor memory: 38K bytes.
  (slice1)    Executor memory: 266K bytes avg x 3x(0) workers, 266K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 85.470 ms

-- 15
explain analyze select *, sum(total_amount) over (order by book_date) from bookings;

WindowAgg  (cost=0.00..3654.59 rows=2111110 width=32) (actual time=3816.927..7317.530 rows=2111110 loops=1)
  Order By: book_date
  ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..3578.59 rows=2111110 width=36) (actual time=3816.895..6242.229 rows=2111110 loops=1)
        Merge Key: book_date
        ->  Sort  (cost=0.00..3295.36 rows=703704 width=36) (actual time=2763.905..2953.239 rows=705433 loops=1)
              Sort Key: book_date
              Sort Method:  external merge  Disk: 96800kB
              ->  Seq Scan on bookings  (cost=0.00..458.09 rows=703704 width=36) (actual time=0.052..84.089 rows=705433 loops=1)
Planning Time: 2.080 ms
  (slice0)    Executor memory: 86K bytes.
  (slice1)    Executor memory: 63854K bytes avg x 3x(0) workers, 63854K bytes max (seg0).  Work_mem: 63854K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 7393.766 ms

-- 16
explain analyze select *, sum(total_amount) over (order by book_date), count(*) over (order by book_ref) from bookings;

WindowAgg  (cost=0.00..11769.65 rows=2111110 width=40) (actual time=11307.971..12652.342 rows=2111110 loops=1)
  Order By: book_ref
  ->  Sort  (cost=0.00..11702.09 rows=2111110 width=32) (actual time=11307.953..12035.530 rows=2111110 loops=1)
        Sort Key: book_ref
        Sort Method:  external merge  Disk: 115360kB
        ->  WindowAgg  (cost=0.00..3654.59 rows=2111110 width=32) (actual time=3249.685..6756.615 rows=2111110 loops=1)
              Order By: book_date
              ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..3578.59 rows=2111110 width=36) (actual time=3249.661..5682.411 rows=2111110 loops=1)
                    Merge Key: book_date
                    ->  Sort  (cost=0.00..3295.36 rows=703704 width=36) (actual time=3158.419..3392.927 rows=705433 loops=1)
                          Sort Key: book_date
                          Sort Method:  external merge  Disk: 96896kB
                          ->  Seq Scan on bookings  (cost=0.00..458.09 rows=703704 width=36) (actual time=0.352..432.721 rows=705433 loops=1)
Planning Time: 1.400 ms
  (slice0)    Executor memory: 42286K bytes.  Work_mem: 42286K bytes max.
  (slice1)    Executor memory: 42538K bytes avg x 3x(0) workers, 42538K bytes max (seg0).  Work_mem: 42538K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 12709.887 ms

-- 17
explain analyze select fare_conditions from seats group by fare_conditions;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..431.07 rows=3 width=8) (actual time=9.879..10.070 rows=3 loops=1)
  ->  GroupAggregate  (cost=0.00..431.07 rows=1 width=8) (actual time=9.655..9.657 rows=2 loops=1)
        Group Key: fare_conditions
        ->  Sort  (cost=0.00..431.07 rows=1 width=8) (actual time=9.648..9.649 rows=6 loops=1)
              Sort Key: fare_conditions
              Sort Method:  quicksort  Memory: 75kB
              ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..431.07 rows=1 width=8) (actual time=8.037..9.635 rows=6 loops=1)
                    Hash Key: fare_conditions
                    ->  Streaming HashAggregate  (cost=0.00..431.07 rows=1 width=8) (actual time=8.243..8.244 rows=3 loops=1)
                          Group Key: fare_conditions
                          ->  Seq Scan on seats  (cost=0.00..431.01 rows=447 width=8) (actual time=8.109..8.143 rows=457 loops=1)
Planning Time: 3.757 ms
  (slice0)    Executor memory: 125K bytes.
  (slice1)    Executor memory: 147K bytes avg x 3x(0) workers, 147K bytes max (seg0).  Work_mem: 1K bytes max.
  (slice2)    Executor memory: 269K bytes avg x 3x(0) workers, 269K bytes max (seg0).  Work_mem: 24K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 18.666 ms

-- 18
create unique index ticket_flights_pkey on bookings.ticket_flights using btree (ticket_no, flight_id);
analyze bookings.ticket_flights;
explain analyze select ticket_no, count(ticket_no) from ticket_flights group by ticket_no;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..1308.48 rows=2763698 width=22) (actual time=3800.595..6579.855 rows=2949857 loops=1)
  ->  HashAggregate  (cost=0.00..1081.90 rows=921233 width=22) (actual time=3792.051..4594.849 rows=984149 loops=1)
        Group Key: ticket_no
        Planned Partitions: 4
        ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..727.96 rows=2797284 width=14) (actual time=0.017..1992.818 rows=2799730 loops=1)
              Hash Key: ticket_no
              ->  Seq Scan on ticket_flights  (cost=0.00..532.54 rows=2797284 width=14) (actual time=2.799..401.312 rows=2799196 loops=1)
Planning Time: 3.003 ms
  (slice0)    Executor memory: 12335K bytes.
  (slice1)    Executor memory: 23549K bytes avg x 3x(0) workers, 23549K bytes max (seg0).  Work_mem: 32913K bytes max.
  (slice2)    Executor memory: 265K bytes avg x 3x(0) workers, 265K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 6709.197 ms

-- 19
explain analyze select fare_conditions, ticket_no, amount, count(*) from ticket_flights
group by grouping sets (fare_conditions, ticket_no, amount);

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..3742.91 rows=2764022 width=30) (actual time=6722.325..9815.900 rows=2950198 loops=1)
  ->  Sequence  (cost=0.00..3433.89 rows=921341 width=30) (actual time=2572.076..7680.290 rows=984270 loops=1)
        ->  Shared Scan (share slice:id 1:0)  (cost=0.00..681.02 rows=2797284 width=1) (actual time=2016.490..2164.398 rows=2799196 loops=1)
              ->  Seq Scan on ticket_flights  (cost=0.00..532.54 rows=2797284 width=28) (actual time=0.058..898.234 rows=2799196 loops=1)
        ->  Append  (cost=0.00..2725.23 rows=921341 width=30) (actual time=1210.733..6255.564 rows=984270 loops=1)
              ->  Finalize HashAggregate  (cost=0.00..822.51 rows=107 width=14) (actual time=1210.719..1210.730 rows=120 loops=1)
                    Group Key: share0_ref2.amount
                    ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..822.50 rows=107 width=14) (actual time=0.014..1209.493 rows=359 loops=1)
                          Hash Key: share0_ref2.amount
                          ->  Streaming Partial HashAggregate  (cost=0.00..822.49 rows=107 width=14) (actual time=1205.438..1205.460 rows=338 loops=1)
                                Group Key: share0_ref2.amount
                                ->  Shared Scan (share slice:id 2:0)  (cost=0.00..471.45 rows=2797284 width=6) (actual time=2007.997..2176.803 rows=2799196 loops=1)
              ->  HashAggregate  (cost=0.00..1001.89 rows=921233 width=22) (actual time=4145.074..4983.993 rows=984149 loops=1)
                    Group Key: share0_ref3.ticket_no
                    Planned Partitions: 8
                    ->  Redistribute Motion 3:3  (slice3; segments: 3)  (cost=0.00..647.96 rows=2797284 width=14) (actual time=0.011..2362.292 rows=2799730 loops=1)
                          Hash Key: share0_ref3.ticket_no
                          ->  Result  (cost=0.00..525.38 rows=2797284 width=14) (actual time=2017.303..2632.872 rows=2799196 loops=1)
                                ->  Shared Scan (share slice:id 3:0)  (cost=0.00..525.38 rows=2797284 width=14) (actual time=2017.299..2325.607 rows=2799196 loops=1)
              ->  Finalize GroupAggregate  (cost=0.00..838.17 rows=1 width=16) (actual time=0.031..0.032 rows=2 loops=1)
                    Group Key: share0_ref4.fare_conditions
                    ->  Sort  (cost=0.00..838.17 rows=1 width=16) (actual time=0.025..0.025 rows=6 loops=1)
                          Sort Key: share0_ref4.fare_conditions
                          Sort Method:  quicksort  Memory: 75kB
                          ->  Redistribute Motion 3:3  (slice4; segments: 3)  (cost=0.00..838.17 rows=1 width=16) (actual time=0.004..0.005 rows=6 loops=1)
                                Hash Key: share0_ref4.fare_conditions
                                ->  Streaming Partial HashAggregate  (cost=0.00..838.17 rows=1 width=16) (actual time=1073.360..1073.361 rows=3 loops=1)
                                      Group Key: share0_ref4.fare_conditions
                                      ->  Shared Scan (share slice:id 4:0)  (cost=0.00..484.93 rows=2797284 width=8) (actual time=2012.517..2160.979 rows=2799196 loops=1)
Planning Time: 13.745 ms
  (slice0)    Executor memory: 3219K bytes.
  (slice1)    Executor memory: 14318K bytes avg x 3x(0) workers, 14401K bytes max (seg1).  Work_mem: 16657K bytes max.
  (slice2)    Executor memory: 128K bytes avg x 3x(0) workers, 128K bytes max (seg0).  Work_mem: 77K bytes max.
  (slice3)    Executor memory: 112K bytes avg x 3x(0) workers, 112K bytes max (seg0).
  (slice4)    Executor memory: 123K bytes avg x 3x(0) workers, 123K bytes max (seg0).  Work_mem: 24K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 9959.543 ms

-- 20
explain analyze select flight_id, count(*) from ticket_flights group by flight_id;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..910.49 rows=82012 width=12) (actual time=1330.259..1530.861 rows=150588 loops=1)
  ->  Finalize HashAggregate  (cost=0.00..906.82 rows=27338 width=12) (actual time=1329.335..1343.234 rows=50270 loops=1)
        Group Key: flight_id
        ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..903.32 rows=27338 width=12) (actual time=415.717..1266.168 rows=146247 loops=1)
              Hash Key: flight_id
              ->  Streaming Partial HashAggregate  (cost=0.00..902.29 rows=27338 width=12) (actual time=1178.702..1208.374 rows=146214 loops=1)
                    Group Key: flight_id
                    ->  Seq Scan on ticket_flights  (cost=0.00..532.54 rows=2797284 width=4) (actual time=0.103..649.636 rows=2799196 loops=1)
Planning Time: 3.694 ms
  (slice0)    Executor memory: 1593K bytes.
  (slice1)    Executor memory: 3923K bytes avg x 3x(0) workers, 3926K bytes max (seg0).  Work_mem: 5649K bytes max.
  (slice2)    Executor memory: 14159K bytes avg x 3x(0) workers, 14282K bytes max (seg0).  Work_mem: 18449K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 1536.111 ms

-- 21
explain analyze select * from tickets t join ticket_flights tf on tf.ticket_no = t.ticket_no where t.ticket_no in ('0005432312163','0005432312164');

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..923.81 rows=11 width=132) (actual time=483.877..536.687 rows=8 loops=1)
  ->  Hash Join  (cost=0.00..923.80 rows=4 width=132) (actual time=41.834..534.988 rows=4 loops=1)
        Hash Cond: (tickets.ticket_no = ticket_flights.ticket_no)
        Extra Text: (seg0)   Hash chain length 4.0 avg, 4 max, using 1 of 131072 buckets.
        ->  Seq Scan on tickets  (cost=0.00..535.82 rows=1 width=100) (actual time=37.685..530.735 rows=1 loops=1)
              Filter: ((ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[])) AND (ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[])))
        ->  Hash  (cost=387.98..387.98 rows=3 width=32) (actual time=0.011..0.015 rows=4 loops=1)
              Buckets: 131072  Batches: 1  Memory Usage: 1025kB
              ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..387.98 rows=3 width=32) (actual time=0.004..0.005 rows=4 loops=1)
                    Hash Key: ticket_flights.ticket_no
                    ->  Bitmap Heap Scan on ticket_flights  (cost=0.00..387.98 rows=3 width=32) (actual time=1.048..1.109 rows=4 loops=1)
                          Recheck Cond: (ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[]))
                          ->  Bitmap Index Scan on ticket_flights_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.565..0.565 rows=4 loops=1)
                                Index Cond: (ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[]))
Planning Time: 10.553 ms
  (slice0)    Executor memory: 169K bytes.
  (slice1)    Executor memory: 1239K bytes avg x 3x(0) workers, 1332K bytes max (seg0).  Work_mem: 1025K bytes max.
  (slice2)    Executor memory: 2663K bytes avg x 3x(0) workers, 2663K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 538.671 ms

-- 22
explain analyze select * from aircrafts a left join seats s on (a.aircraft_code = s.aircraft_code) where a.model like 'аэробус%';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..862.24 rows=2 width=35) (actual time=19.795..19.798 rows=0 loops=1)
  ->  Hash Left Join  (cost=0.00..862.24 rows=1 width=35) (actual time=19.118..19.120 rows=0 loops=1)
        Hash Cond: (aircrafts_data.aircraft_code = seats.aircraft_code)
        ->  Result  (cost=0.00..431.00 rows=1 width=20) (actual time=3.411..3.411 rows=0 loops=1)
              ->  Seq Scan on aircrafts_data  (cost=0.00..431.00 rows=1 width=20) (actual time=3.410..3.410 rows=0 loops=1)
                    Filter: (model ~~ 'аэробус%'::text)
        ->  Hash  (cost=431.05..431.05 rows=447 width=15) (actual time=4.473..4.475 rows=1169 loops=1)
              Buckets: 524288  Batches: 1  Memory Usage: 4151kB
              ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..431.05 rows=447 width=15) (actual time=1.856..4.398 rows=1169 loops=1)
                    Hash Key: seats.aircraft_code
                    ->  Seq Scan on seats  (cost=0.00..431.01 rows=447 width=15) (actual time=0.057..0.087 rows=457 loops=1)
Planning Time: 6.368 ms
  (slice0)    Executor memory: 48K bytes.
  (slice1)    Executor memory: 4407K bytes avg x 3x(0) workers, 4441K bytes max (seg2).  Work_mem: 4151K bytes max.
  (slice2)    Executor memory: 255K bytes avg x 3x(0) workers, 255K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 21.755 ms

-- 23
explain analyze select * from aircrafts a where a.model like 'аэробус%' 
  and not exists (select * from seats s where s.aircraft_code = a.aircraft_code);

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..862.07 rows=1 width=20) (actual time=3.799..3.802 rows=0 loops=1)
  ->  Result  (cost=0.00..862.07 rows=1 width=20) (actual time=1.572..1.575 rows=0 loops=1)
        Filter: (COALESCE((count()), '0'::bigint) = '0'::bigint)
        ->  Hash Left Join  (cost=0.00..862.07 rows=1 width=28) (actual time=1.571..1.574 rows=0 loops=1)
              Hash Cond: (aircrafts_data.aircraft_code = seats.aircraft_code)
              ->  Result  (cost=0.00..431.00 rows=1 width=20) (actual time=0.055..0.056 rows=0 loops=1)
                    ->  Seq Scan on aircrafts_data  (cost=0.00..431.00 rows=1 width=20) (actual time=0.055..0.055 rows=0 loops=1)
                          Filter: (model ~~ 'аэробус%'::text)
              ->  Hash  (cost=431.07..431.07 rows=3 width=12) (actual time=2.665..2.667 rows=8 loops=1)
                    Buckets: 262144  Batches: 1  Memory Usage: 2049kB
                    ->  Finalize GroupAggregate  (cost=0.00..431.07 rows=3 width=12) (actual time=2.655..2.659 rows=8 loops=1)
                          Group Key: seats.aircraft_code
                          ->  Sort  (cost=0.00..431.07 rows=3 width=12) (actual time=2.645..2.647 rows=24 loops=1)
                                Sort Key: seats.aircraft_code
                                Sort Method:  quicksort  Memory: 76kB
                                ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..431.07 rows=3 width=12) (actual time=2.020..2.629 rows=24 loops=1)
                                      Hash Key: seats.aircraft_code
                                      ->  Streaming Partial HashAggregate  (cost=0.00..431.07 rows=3 width=12) (actual time=0.130..0.132 rows=9 loops=1)
                                            Group Key: seats.aircraft_code
                                            ->  Seq Scan on seats  (cost=0.00..431.01 rows=447 width=4) (actual time=0.048..0.073 rows=457 loops=1)
Planning Time: 11.493 ms
  (slice0)    Executor memory: 83K bytes.
  (slice1)    Executor memory: 2392K bytes avg x 3x(0) workers, 2403K bytes max (seg2).  Work_mem: 2049K bytes max.
  (slice2)    Executor memory: 270K bytes avg x 3x(0) workers, 270K bytes max (seg0).  Work_mem: 24K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 5.164 ms

-- 24
explain analyze select * from aircrafts a where a.model like 'аэробус%'
  and exists (select * from seats s where s.aircraft_code = a.aircraft_code);

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..862.07 rows=1 width=20) (actual time=4.320..4.323 rows=0 loops=1)
  ->  Hash Join  (cost=0.00..862.07 rows=1 width=20) (actual time=3.059..3.063 rows=0 loops=1)
        Hash Cond: (aircrafts_data.aircraft_code = seats.aircraft_code)
        ->  Result  (cost=0.00..431.00 rows=1 width=20) (actual time=0.058..0.059 rows=0 loops=1)
              ->  Seq Scan on aircrafts_data  (cost=0.00..431.00 rows=1 width=20) (actual time=0.058..0.058 rows=0 loops=1)
                    Filter: (model ~~ 'аэробус%'::text)
        ->  Hash  (cost=431.07..431.07 rows=3 width=4) (actual time=2.227..2.229 rows=8 loops=1)
              Buckets: 262144  Batches: 1  Memory Usage: 2049kB
              ->  GroupAggregate  (cost=0.00..431.07 rows=3 width=4) (actual time=2.218..2.221 rows=8 loops=1)
                    Group Key: seats.aircraft_code
                    ->  Sort  (cost=0.00..431.07 rows=3 width=4) (actual time=2.212..2.213 rows=24 loops=1)
                          Sort Key: seats.aircraft_code
                          Sort Method:  quicksort  Memory: 76kB
                          ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..431.07 rows=3 width=4) (actual time=1.049..2.197 rows=24 loops=1)
                                Hash Key: seats.aircraft_code
                                ->  Streaming HashAggregate  (cost=0.00..431.07 rows=3 width=4) (actual time=0.114..0.115 rows=9 loops=1)
                                      Group Key: seats.aircraft_code
                                      ->  Seq Scan on seats  (cost=0.00..431.01 rows=447 width=4) (actual time=0.048..0.075 rows=457 loops=1)
Planning Time: 11.849 ms
  (slice0)    Executor memory: 72K bytes.
  (slice1)    Executor memory: 2302K bytes avg x 3x(0) workers, 2395K bytes max (seg2).  Work_mem: 2049K bytes max.
  (slice2)    Executor memory: 269K bytes avg x 3x(0) workers, 269K bytes max (seg0).  Work_mem: 24K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 6.001 ms

-- 25
explain analyze select * from flights f join aircrafts_data a on f.aircraft_code = a.aircraft_code where f.flight_no = 'PG0003';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..870.59 rows=1 width=143) (actual time=5.490..8.749 rows=113 loops=1)
  ->  Hash Join  (cost=0.00..870.59 rows=1 width=143) (actual time=8.439..9.107 rows=42 loops=1)
        Hash Cond: (flights.aircraft_code = aircrafts_data.aircraft_code)
        Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 9 of 262144 buckets.
        ->  Seq Scan on flights  (cost=0.00..439.56 rows=93 width=123) (actual time=8.187..8.741 rows=42 loops=1)
              Filter: (flight_no = 'PG0003'::bpchar)
        ->  Hash  (cost=431.00..431.00 rows=1 width=20) (actual time=0.072..0.073 rows=9 loops=1)
              Buckets: 262144  Batches: 1  Memory Usage: 2049kB
              ->  Seq Scan on aircrafts_data  (cost=0.00..431.00 rows=1 width=20) (actual time=0.064..0.067 rows=9 loops=1)
Planning Time: 6.800 ms
  (slice0)    Executor memory: 58K bytes.
  (slice1)    Executor memory: 3354K bytes avg x 3x(0) workers, 3357K bytes max (seg1).  Work_mem: 2049K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 11.658 ms

-- 26
explain analyze select t.passenger_name from tickets t join ticket_flights tf on tf.ticket_no = t.ticket_no
  join flights f on f.flight_id = tf.flight_id where f.flight_id = 12345;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..1811.34 rows=103 width=16) (actual time=780.756..1079.393 rows=22 loops=1)
  ->  Hash Join  (cost=0.00..1811.34 rows=35 width=16) (actual time=652.362..996.044 rows=9 loops=1)
        Hash Cond: (tickets.ticket_no = ticket_flights.ticket_no)
        Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 9 of 262144 buckets.
        ->  Seq Scan on tickets  (cost=0.00..503.47 rows=983286 width=30) (actual time=1.636..253.505 rows=984149 loops=1)
        ->  Hash  (cost=1064.12..1064.12 rows=35 width=14) (actual time=113.422..113.423 rows=9 loops=1)
              Buckets: 262144  Batches: 1  Memory Usage: 2049kB
              ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..1064.12 rows=35 width=14) (actual time=108.240..113.409 rows=9 loops=1)
                    Hash Key: ticket_flights.ticket_no
                    ->  Hash Join  (cost=0.00..1064.12 rows=35 width=14) (actual time=23.216..111.966 rows=9 loops=1)
                          Hash Cond: (ticket_flights.flight_id = flights.flight_id)
                          Extra Text: (seg2)   Hash chain length 1.0 avg, 1 max, using 1 of 262144 buckets.
                          ->  Seq Scan on ticket_flights  (cost=0.00..624.57 rows=35 width=18) (actual time=17.754..106.372 rows=9 loops=1)
                                Filter: (flight_id = 12345)
                          ->  Hash  (cost=439.54..439.54 rows=1 width=4) (actual time=4.280..4.283 rows=1 loops=1)
                                Buckets: 262144  Batches: 1  Memory Usage: 2049kB
                                ->  Broadcast Motion 3:3  (slice3; segments: 3)  (cost=0.00..439.54 rows=1 width=4) (actual time=2.658..4.268 rows=1 loops=1)
                                      ->  Seq Scan on flights  (cost=0.00..439.54 rows=1 width=4) (actual time=0.713..3.265 rows=1 loops=1)
                                            Filter: (flight_id = 12345)
Planning Time: 12.357 ms
  (slice0)    Executor memory: 65K bytes.
  (slice1)    Executor memory: 2350K bytes avg x 3x(0) workers, 2350K bytes max (seg2).  Work_mem: 2049K bytes max.
  (slice2)    Executor memory: 2355K bytes avg x 3x(0) workers, 2355K bytes max (seg0).  Work_mem: 2049K bytes max.
  (slice3)    Executor memory: 231K bytes avg x 3x(0) workers, 236K bytes max (seg2).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 1080.217 ms

-- 27
explain analyze select * from flights where flight_no = 'PG0007' and departure_airport = 'VKO';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..441.91 rows=26 width=123) (actual time=3.066..10.203 rows=396 loops=1)
  ->  Seq Scan on flights  (cost=0.00..441.90 rows=9 width=123) (actual time=0.231..8.470 rows=147 loops=1)
        Filter: ((flight_no = 'PG0007'::bpchar) AND (departure_airport = 'VKO'::bpchar))
Planning Time: 5.493 ms
  (slice0)    Executor memory: 39K bytes.
  (slice1)    Executor memory: 1125K bytes avg x 3x(0) workers, 1125K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 11.082 ms

create statistics (dependencies) on flight_no, departure_airport from flights; -- не поддерживается
analyze flights;

-- 28
explain analyze select * from flights where departure_airport = 'LED' and aircraft_code = '321';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..442.59 rows=1290 width=123) (actual time=4.107..20.469 rows=5148 loops=1)
  ->  Seq Scan on flights  (cost=0.00..442.00 rows=430 width=123) (actual time=0.227..6.120 rows=1754 loops=1)
        Filter: ((departure_airport = 'LED'::bpchar) AND (aircraft_code = '321'::bpchar))
Planning Time: 2.763 ms
  (slice0)    Executor memory: 39K bytes.
  (slice1)    Executor memory: 1125K bytes avg x 3x(0) workers, 1125K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 21.580 ms

create statistics (mcv) on departure_airport, aircraft_code from flights; -- не поддерживается
analyze flights;



-- 29
explain analyze select distinct departure_airport, arrival_airport from flights;

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..456.46 rows=6084 width=8) (actual time=25.530..26.095 rows=618 loops=1)
  ->  HashAggregate  (cost=0.00..456.28 rows=2028 width=8) (actual time=23.926..23.944 rows=208 loops=1)
        Group Key: departure_airport, arrival_airport
        ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..455.78 rows=2028 width=8) (actual time=20.796..23.812 rows=624 loops=1)
              Hash Key: departure_airport, arrival_airport
              ->  Streaming HashAggregate  (cost=0.00..455.73 rows=2028 width=8) (actual time=20.018..20.070 rows=618 loops=1)
                    Group Key: departure_airport, arrival_airport
                    ->  Seq Scan on flights  (cost=0.00..437.18 rows=71623 width=8) (actual time=0.146..10.388 rows=71653 loops=1)
Planning Time: 4.602 ms
  (slice0)    Executor memory: 245K bytes.
  (slice1)    Executor memory: 131K bytes avg x 3x(0) workers, 131K bytes max (seg2).  Work_mem: 129K bytes max.
  (slice2)    Executor memory: 455K bytes avg x 3x(0) workers, 455K bytes max (seg1).  Work_mem: 145K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 27.345 ms

create statistics on departure_airport, arrival_airport from flights; -- не поддерживается
analyze flights;



-- 30
explain analyze select * from flights where extract(month from scheduled_departure at time zone 'Europe/Moscow') = 1; -- не поддерживается



create statistics on extract(month from scheduled_departure at time zone 'europe/moscow') from flights; -- не поддерживается
analyze flights;



select * from pg_stats_ext;
select * from pg_stats_ext_exprs;
select * from pg_statistic_ext;
select * from pg_statistic_ext_data;

analyze flights;

-- 31

explain analyze select a1.city, a2.city from airports a1, airports a2 where a1.timezone = 'Europe/Moscow' -- не поддерживается
  and abs(a2.coordinates[1]) > 66.652; -- за полярным кругом



-- 32
explain analyze
  with q as materialized (select f.flight_id, a.aircraft_code from flights f join aircrafts a on a.aircraft_code = f.aircraft_code) 
  select * from q join seats s on s.aircraft_code = q.aircraft_code where s.seat_no = '1A';

Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..1313.08 rows=9 width=27) (actual time=85.958..722.825 rows=214867 loops=1)
  ->  Hash Join  (cost=0.00..1313.08 rows=3 width=27) (actual time=85.752..105.370 rows=202195 loops=1)
        Hash Cond: (seats.aircraft_code = aircrafts_data.aircraft_code)
        Extra Text: (seg2)   Hash chain length 28885.0 avg, 60196 max, using 7 of 262144 buckets.
        ->  Redistribute Motion 3:3  (slice2; segments: 3)  (cost=0.00..431.03 rows=3 width=15) (actual time=0.001..0.012 rows=8 loops=1)
              Hash Key: seats.aircraft_code
              ->  Seq Scan on seats  (cost=0.00..431.03 rows=3 width=15) (actual time=0.056..0.067 rows=4 loops=1)
                    Filter: ((seat_no)::text = '1A'::text)
        ->  Hash  (cost=882.05..882.05 rows=1 width=12) (actual time=85.558..85.559 rows=202195 loops=1)
              Buckets: 262144  Batches: 1  Memory Usage: 9947kB
              ->  Redistribute Motion 3:3  (slice3; segments: 3)  (cost=0.00..882.05 rows=1 width=12) (actual time=5.932..73.262 rows=202195 loops=1)
                    Hash Key: aircrafts_data.aircraft_code
                    ->  Hash Join  (cost=0.00..882.05 rows=1 width=12) (actual time=3.521..22.995 rows=71653 loops=1)
                          Hash Cond: (flights.aircraft_code = aircrafts_data.aircraft_code)
                          Extra Text: (seg2)   Hash chain length 1.0 avg, 1 max, using 9 of 262144 buckets.
                          ->  Seq Scan on flights  (cost=0.00..437.18 rows=71623 width=8) (actual time=0.178..7.716 rows=71653 loops=1)
                          ->  Hash  (cost=431.00..431.00 rows=1 width=8) (actual time=0.408..0.412 rows=9 loops=1)
                                Buckets: 262144  Batches: 1  Memory Usage: 2049kB
                                ->  Seq Scan on aircrafts_data  (cost=0.00..431.00 rows=1 width=8) (actual time=0.396..0.399 rows=9 loops=1)
Planning Time: 10.267 ms
  (slice0)    Executor memory: 83K bytes.
  (slice1)    Executor memory: 4891K bytes avg x 3x(0) workers, 10001K bytes max (seg2).  Work_mem: 9947K bytes max.
  (slice2)    Executor memory: 258K bytes avg x 3x(0) workers, 258K bytes max (seg0).
  (slice3)    Executor memory: 2570K bytes avg x 3x(0) workers, 2570K bytes max (seg0).  Work_mem: 2049K bytes max.
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 728.986 ms

-- 33
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


Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..85721.69 rows=716327 width=20) (actual time=139.429..216.845 rows=214971 loops=1)
  ->  Recursive Union  (cost=0.00..76170.66 rows=238776 width=8) (actual time=4.583..169.187 rows=98696 loops=1)
        ->  Seq Scan on airports_data ml  (cost=0.00..1.35 rows=35 width=8) (actual time=4.581..4.590 rows=37 loops=1)
        ->  Hash Join  (cost=6529.95..7139.38 rows=23874 width=8) (actual time=66.781..76.657 rows=49330 loops=2)
              Hash Cond: (r.airport_code = f.departure_airport)
              Extra Text: (seg0)   Hash chain length 2066.0 avg, 20875 max, using 104 of 524288 buckets.
              ->  WorkTable Scan on r  (cost=0.00..7.80 rows=116 width=20) (actual time=0.001..4.424 rows=18 loops=2)
                    Filter: (n < 2)
                    Rows Removed by Filter: 49330
              ->  Hash  (cost=3844.12..3844.12 rows=214867 width=8) (actual time=133.119..133.120 rows=214867 loops=1)
                    Buckets: 524288  Batches: 1  Memory Usage: 12490kB
                    ->  Broadcast Motion 3:3  (slice2; segments: 3)  (cost=0.00..3844.12 rows=214867 width=8) (actual time=0.016..110.163 rows=214867 loops=1)
                          ->  Seq Scan on flights f  (cost=0.00..979.22 rows=71622 width=8) (actual time=0.244..5.753 rows=71653 loops=1)
Planning Time: 1.771 ms
  (slice0)    Executor memory: 95K bytes.
  (slice1)    Executor memory: 15646K bytes avg x 3x(0) workers, 16833K bytes max (seg0).  Work_mem: 12490K bytes max.
  (slice2)    Executor memory: 332K bytes avg x 3x(0) workers, 332K bytes max (seg0).
Memory used:  128000kB
Optimizer: Postgres query optimizer
Execution Time: 223.041 ms


