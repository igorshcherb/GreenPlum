set schema 'bookings';

-- 01
explain analyze select * from flights;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..536.21 rows=214867 width=123) (actual time=24.844..4092.255 rows=214867 loops=1)
  ->  Seq Scan on flights  (cost=0.00..435.52 rows=53717 width=123) (actual time=18.412..178.723 rows=53736 loops=1)
Optimizer: GPORCA
Planning Time: 4.433 ms
  (slice0)    Executor memory: 36K bytes.
  (slice1)    Executor memory: 1050K bytes avg x 4 workers, 1050K bytes max (seg0).
Memory used:  128000kB
Execution Time: 4102.776 ms

-- 02
create unique index bookings_pkey on bookings.bookings using btree (book_ref);

explain analyze select * from bookings where book_ref = 'CDE08B';

Gather Motion 1:1  (slice1; segments: 1)  (cost=0.00..387.96 rows=1 width=36) (actual time=8.331..8.333 rows=1 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..387.96 rows=1 width=36) (actual time=7.114..7.117 rows=1 loops=1)
        Recheck Cond: (book_ref = 'CDE08B'::bpchar)
        Heap Blocks: exact=1
        ->  Bitmap Index Scan on bookings_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.157..0.158 rows=1 loops=1)
              Index Cond: (book_ref = 'CDE08B'::bpchar)
Optimizer: GPORCA
Planning Time: 3.607 ms
  (slice0)    Executor memory: 53K bytes.
  (slice1)    Executor memory: 389K bytes (seg3).
Memory used:  128000kB
Execution Time: 13.605 ms

-- 03
explain analyze select * from bookings where book_ref > '000900' and book_ref < '000939';

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..513.85 rows=337778 width=36) (actual time=45.091..216.285 rows=5 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..473.18 rows=84445 width=36) (actual time=0.087..45.478 rows=2 loops=1)
        Filter: ((book_ref > '000900'::bpchar) AND (book_ref < '000939'::bpchar))
        Rows Removed by Filter: 528190
Optimizer: GPORCA
Planning Time: 2.240 ms
  (slice0)    Executor memory: 17K bytes.
  (slice1)    Executor memory: 183K bytes avg x 4 workers, 183K bytes max (seg0).
Memory used:  128000kB
Execution Time: 222.427 ms

-- 04
explain analyze select * from bookings where book_ref in ('000906','000909','000917','000930','000938');

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..387.97 rows=6 width=36) (actual time=3.123..11.171 rows=5 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..387.97 rows=2 width=36) (actual time=7.186..7.190 rows=2 loops=1)
        Recheck Cond: (book_ref = ANY ('{000906,000909,000917,000930,000938}'::bpchar[]))
        Heap Blocks: exact=1
        ->  Bitmap Index Scan on bookings_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.184..0.184 rows=2 loops=1)
              Index Cond: (book_ref = ANY ('{000906,000909,000917,000930,000938}'::bpchar[]))
Optimizer: GPORCA
Planning Time: 2.443 ms
  (slice0)    Executor memory: 53K bytes.
  (slice1)    Executor memory: 334K bytes avg x 4 workers, 389K bytes max (seg1).
Memory used:  128000kB
Execution Time: 13.325 ms

-- 05
create index on bookings(book_date);
create index on bookings(total_amount);

explain analyze select * from bookings where total_amount < 5000;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..396.31 rows=4322 width=36) (actual time=9.680..44.228 rows=1471 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..395.72 rows=1081 width=36) (actual time=3.636..11.127 rows=386 loops=1)
        Recheck Cond: (total_amount < '5000'::numeric)
        Heap Blocks: exact=17
        ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=3.555..3.556 rows=386 loops=1)
              Index Cond: (total_amount < '5000'::numeric)
Optimizer: GPORCA
Planning Time: 5.408 ms
  (slice0)    Executor memory: 62K bytes.
  (slice1)    Executor memory: 2430K bytes avg x 4 workers, 2440K bytes max (seg0).
Memory used:  128000kB
Execution Time: 46.811 ms

-- 06
explain analyze select * from bookings where total_amount < 5000 or total_amount > 500000;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..455.63 rows=15149 width=36) (actual time=9.651..126.716 rows=9636 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=0.00..453.56 rows=3788 width=36) (actual time=7.362..45.038 rows=2461 loops=1)
        Recheck Cond: ((total_amount < '5000'::numeric) OR (total_amount > '500000'::numeric))
        Heap Blocks: exact=17
        ->  BitmapOr  (cost=0.00..0.00 rows=0 width=0) (actual time=7.183..7.185 rows=1 loops=1)
              ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=2.944..2.944 rows=386 loops=1)
                    Index Cond: (total_amount < '5000'::numeric)
              ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=2.799..2.800 rows=2085 loops=1)
                    Index Cond: (total_amount > '500000'::numeric)
Optimizer: GPORCA
Planning Time: 4.531 ms
  (slice0)    Executor memory: 98K bytes.
  (slice1)    Executor memory: 4202K bytes avg x 4 workers, 4202K bytes max (seg0).
Memory used:  128000kB
Execution Time: 131.108 ms

-- 07
explain analyze select * from bookings where total_amount < 5000 OR book_date::timestamp with time zone = bookings.now() - INTERVAL '1 day';

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..601.04 rows=846876 width=36) (actual time=191.529..794.464 rows=1474 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..499.06 rows=211719 width=36) (actual time=0.471..700.333 rows=386 loops=1)
        Filter: ((total_amount < '5000'::numeric) OR ((book_date)::timestamp with time zone = '2017-08-14 18:00:00+03'::timestamp with time zone))
        Rows Removed by Filter: 526603
Optimizer: GPORCA
Planning Time: 3.724 ms
  (slice0)    Executor memory: 26K bytes.
  (slice1)    Executor memory: 191K bytes avg x 4 workers, 191K bytes max (seg0).
Memory used:  128000kB
Execution Time: 795.982 ms

-- 08
explain analyze select count(*) from bookings where total_amount < 5000 and book_date::timestamp with time zone > '2017-07-15 18:00:00+03'::timestamp;

Finalize Aggregate  (cost=0.00..395.49 rows=1 width=8) (actual time=10.660..10.662 rows=1 loops=1)
  ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..395.49 rows=1 width=8) (actual time=10.067..10.648 rows=4 loops=1)
        ->  Partial Aggregate  (cost=0.00..395.49 rows=1 width=8) (actual time=3.085..3.086 rows=1 loops=1)
              ->  Bitmap Heap Scan on bookings  (cost=0.00..395.49 rows=769 width=1) (actual time=1.438..4.928 rows=42 loops=1)
                    Recheck Cond: (total_amount < '5000'::numeric)
                    Filter: ((book_date)::timestamp with time zone > '2017-07-15 18:00:00'::timestamp without time zone)
                    Rows Removed by Filter: 344
                    Heap Blocks: exact=17
                    ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..0.00 rows=0 width=0) (actual time=1.229..1.229 rows=386 loops=1)
                          Index Cond: (total_amount < '5000'::numeric)
Optimizer: GPORCA
Planning Time: 5.256 ms
  (slice0)    Executor memory: 70K bytes.
  (slice1)    Executor memory: 2428K bytes avg x 4 workers, 2428K bytes max (seg0).
Memory used:  128000kB
Execution Time: 14.283 ms

-- 09
explain analyze select total_amount from bookings where total_amount > 200000;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..470.79 rows=142822 width=6) (actual time=0.014..938.128 rows=141535 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..467.92 rows=35706 width=6) (actual time=0.108..285.135 rows=35523 loops=1)
        Filter: (total_amount > '200000'::numeric)
        Rows Removed by Filter: 491466
Optimizer: GPORCA
Planning Time: 2.854 ms
  (slice0)    Executor memory: 30K bytes.
  (slice1)    Executor memory: 191K bytes avg x 4 workers, 191K bytes max (seg0).
Memory used:  128000kB
Execution Time: 949.431 ms

-- 10
explain analyze select * from ticket_flights where ticket_no = '0005432000284' and flight_id = 187662;

Gather Motion 1:1  (slice1; segments: 1)  (cost=0.00..640.59 rows=1 width=32) (actual time=790.107..790.109 rows=1 loops=1)
  ->  Seq Scan on ticket_flights  (cost=0.00..640.59 rows=1 width=32) (actual time=612.099..790.256 rows=1 loops=1)
        Filter: ((ticket_no = '0005432000284'::bpchar) AND (flight_id = 187662))
        Rows Removed by Filter: 2097945
Optimizer: GPORCA
Planning Time: 2.643 ms
  (slice0)    Executor memory: 17K bytes.
  (slice1)    Executor memory: 183K bytes (seg2).
Memory used:  128000kB
Execution Time: 792.431 ms

-- 11
explain analyze select count(*) from bookings;

Finalize Aggregate  (cost=0.00..451.14 rows=1 width=8) (actual time=346.537..346.540 rows=1 loops=1)
  ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..451.14 rows=1 width=8) (actual time=136.070..346.519 rows=4 loops=1)
        ->  Partial Aggregate  (cost=0.00..451.14 rows=1 width=8) (actual time=364.052..364.054 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..450.16 rows=527778 width=1) (actual time=0.109..344.110 rows=528627 loops=1)
Optimizer: GPORCA
Planning Time: 1.639 ms
  (slice0)    Executor memory: 28K bytes.
  (slice1)    Executor memory: 189K bytes avg x 4 workers, 189K bytes max (seg0).
Memory used:  128000kB
Execution Time: 367.598 ms

-- 12
explain analyze select sum(total_amount) from bookings where book_ref < '400000';

Finalize Aggregate  (cost=0.00..472.77 rows=1 width=8) (actual time=178.899..178.900 rows=1 loops=1)
  ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..472.77 rows=1 width=8) (actual time=96.437..178.870 rows=4 loops=1)
        ->  Partial Aggregate  (cost=0.00..472.77 rows=1 width=8) (actual time=104.766..104.767 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..472.63 rows=211111 width=6) (actual time=0.073..170.456 rows=132284 loops=1)
                    Filter: (book_ref < '400000'::bpchar)
                    Rows Removed by Filter: 395908
Optimizer: GPORCA
Planning Time: 4.134 ms
  (slice0)    Executor memory: 46K bytes.
  (slice1)    Executor memory: 191K bytes avg x 4 workers, 191K bytes max (seg0).
Memory used:  128000kB
Execution Time: 181.736 ms

-- 13
explain analyze select count(book_ref) from bookings where book_ref <= '400000';

Finalize Aggregate  (cost=0.00..470.44 rows=1 width=8) (actual time=119.129..119.133 rows=1 loops=1)
  ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..470.44 rows=1 width=8) (actual time=40.866..119.109 rows=4 loops=1)
        ->  Partial Aggregate  (cost=0.00..470.44 rows=1 width=8) (actual time=40.117..40.119 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..470.27 rows=211111 width=7) (actual time=0.054..34.409 rows=132284 loops=1)
                    Filter: (book_ref <= '400000'::bpchar)
                    Rows Removed by Filter: 395908
Optimizer: GPORCA
Planning Time: 2.628 ms
  (slice0)    Executor memory: 31K bytes.
  (slice1)    Executor memory: 190K bytes avg x 4 workers, 190K bytes max (seg0).
Memory used:  128000kB
Execution Time: 245.347 ms

-- 14
explain analyze select count(*) from bookings where total_amount < 20000 and book_date::timestamp with time zone > '2017-07-15 18:00:00+03'::timestamp;

Finalize Aggregate  (cost=0.00..487.06 rows=1 width=8) (actual time=406.312..406.313 rows=1 loops=1)
  ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..487.06 rows=1 width=8) (actual time=48.752..406.293 rows=4 loops=1)
        ->  Partial Aggregate  (cost=0.00..487.06 rows=1 width=8) (actual time=47.226..47.228 rows=1 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..487.06 rows=40222 width=1) (actual time=0.111..47.035 rows=4813 loops=1)
                    Filter: ((total_amount < '20000'::numeric) AND ((book_date)::timestamp with time zone > '2017-07-15 18:00:00'::timestamp without time zone))
                    Rows Removed by Filter: 523814
Optimizer: GPORCA
Planning Time: 3.940 ms
  (slice0)    Executor memory: 31K bytes.
  (slice1)    Executor memory: 191K bytes avg x 4 workers, 191K bytes max (seg0).
Memory used:  128000kB
Execution Time: 409.853 ms

-- 15
explain analyze select *, sum(total_amount) over (order by book_date) from bookings;

WindowAgg  (cost=0.00..2863.62 rows=2111110 width=32) (actual time=10881.950..39250.146 rows=2111110 loops=1)
  Order By: book_date
  ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..2787.62 rows=2111110 width=36) (actual time=10881.932..37276.969 rows=2111110 loops=1)
        Merge Key: book_date
        ->  Sort  (cost=0.00..2533.40 rows=527778 width=36) (actual time=1334.801..1692.531 rows=528627 loops=1)
              Sort Key: book_date
              Sort Method:  quicksort  Memory: 223963kB
              Executor Memory: 190989kB  Segments: 4  Max: 47801kB (segment 0)
              ->  Seq Scan on bookings  (cost=0.00..450.16 rows=527778 width=36) (actual time=0.069..29.597 rows=528627 loops=1)
Optimizer: GPORCA
Planning Time: 2.632 ms
  (slice0)    Executor memory: 95K bytes.
  (slice1)    Executor memory: 47748K bytes avg x 4 workers, 47801K bytes max (seg0).  Work_mem: 47801K bytes max.
Memory used:  128000kB
Execution Time: 39478.280 ms

-- 16
explain analyze select *, sum(total_amount) over (order by book_date), count(*) over (order by book_ref) from bookings;

WindowAgg  (cost=0.00..10978.68 rows=2111110 width=40) (actual time=46201.224..50579.485 rows=2111110 loops=1)
  Order By: book_ref
  ->  Sort  (cost=0.00..10911.12 rows=2111110 width=32) (actual time=46201.207..48724.165 rows=2111110 loops=1)
        Sort Key: book_ref
        Sort Method:  external merge  Disk: 115360kB
        Executor Memory: 42290kB  Segments: 1  Max: 42290kB (segment -1)
        ->  WindowAgg  (cost=0.00..2863.62 rows=2111110 width=32) (actual time=10427.639..35164.195 rows=2111110 loops=1)
              Order By: book_date
              ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..2787.62 rows=2111110 width=36) (actual time=10427.625..33074.565 rows=2111110 loops=1)
                    Merge Key: book_date
                    ->  Sort  (cost=0.00..2533.40 rows=527778 width=36) (actual time=9835.842..10208.212 rows=528627 loops=1)
                          Sort Key: book_date
                          Sort Method:  external merge  Disk: 96928kB
                          Executor Memory: 170165kB  Segments: 4  Max: 42542kB (segment 0)
                          ->  Seq Scan on bookings  (cost=0.00..450.16 rows=527778 width=36) (actual time=0.090..31.826 rows=528627 loops=1)
Optimizer: GPORCA
Planning Time: 1.624 ms
* (slice0)    Executor memory: 42290K bytes.  Work_mem: 42290K bytes max, 263236K bytes wanted.
* (slice1)    Executor memory: 42542K bytes avg x 4 workers, 42542K bytes max (seg0).  Work_mem: 42542K bytes max, 65876K bytes wanted.
Memory used:  128000kB
Memory wanted:  1053140kB
Execution Time: 50722.037 ms

-- 17
explain analyze select fare_conditions from seats group by fare_conditions;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..431.05 rows=3 width=8) (actual time=79.250..83.443 rows=3 loops=1)
  ->  GroupAggregate  (cost=0.00..431.05 rows=1 width=8) (actual time=77.586..77.588 rows=2 loops=1)
        Group Key: fare_conditions
        ->  Sort  (cost=0.00..431.05 rows=1 width=8) (actual time=77.450..77.451 rows=8 loops=1)
              Sort Key: fare_conditions
              Sort Method:  quicksort  Memory: 100kB
              Executor Memory: 110kB  Segments: 4  Max: 28kB (segment 0)
              ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..431.05 rows=1 width=8) (actual time=27.256..77.439 rows=8 loops=1)
                    Hash Key: fare_conditions
                    ->  Streaming HashAggregate  (cost=0.00..431.05 rows=1 width=8) (actual time=6.788..6.793 rows=3 loops=1)
                          Group Key: fare_conditions
                          Extra Text: (seg0)   hash table(s): 1; chain length 1.0 avg, 1 max; using 3 of 8 buckets; total 2 expansions.

                          ->  Seq Scan on seats  (cost=0.00..431.01 rows=335 width=8) (actual time=3.925..3.942 rows=352 loops=1)
Optimizer: GPORCA
Planning Time: 2.876 ms
  (slice0)    Executor memory: 48K bytes.
  (slice1)    Executor memory: 72K bytes avg x 4 workers, 72K bytes max (seg0).  Work_mem: 28K bytes max.
* (slice2)    Executor memory: 193K bytes avg x 4 workers, 193K bytes max (seg0).  Work_mem: 24K bytes max, 24K bytes wanted.
Memory used:  128000kB
Memory wanted:  448kB
Execution Time: 97.823 ms

-- 18
create unique index ticket_flights_pkey on bookings.ticket_flights using btree (ticket_no, flight_id);
analyze bookings.ticket_flights;
explain analyze select ticket_no, count(ticket_no) from ticket_flights group by ticket_no;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..1090.57 rows=2406715 width=22) (actual time=90742.845..109449.383 rows=2949857 loops=1)
  ->  HashAggregate  (cost=0.00..913.46 rows=601679 width=22) (actual time=90815.597..93501.204 rows=738017 loops=1)
        Group Key: ticket_no
        Planned Partitions: 4
        Extra Text: (seg0)   hash table(s): 1; 737289 groups total in 4 batches, 5550044 spill partitions; disk usage: 47584KB; chain length 2.2 avg, 9 max; using 737289 of 2621440 buckets; total 0 expansions.

        ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..649.10 rows=2097963 width=14) (actual time=9.894..80785.319 rows=2099727 loops=1)
              Hash Key: ticket_no
              ->  Seq Scan on ticket_flights  (cost=0.00..502.54 rows=2097963 width=14) (actual time=0.368..3115.298 rows=2099027 loops=1)
Optimizer: GPORCA
Planning Time: 3.240 ms
  (slice0)    Executor memory: 12330K bytes.
* (slice1)    Executor memory: 23545K bytes avg x 4 workers, 23545K bytes max (seg0).  Work_mem: 32913K bytes max, 73745K bytes wanted.
  (slice2)    Executor memory: 192K bytes avg x 4 workers, 192K bytes max (seg0).
Memory used:  128000kB
Memory wanted:  74044kB
Execution Time: 109574.404 ms

-- 19
explain analyze select fare_conditions, ticket_no, amount, count(*) from ticket_flights
group by grouping sets (fare_conditions, ticket_no, amount);

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..3230.75 rows=2407041 width=32) (actual time=100291.302..117917.069 rows=2950198 loops=1)
  ->  Sequence  (cost=0.00..2973.10 rows=601761 width=32) (actual time=9876.874..103495.169 rows=738114 loops=1)
        ->  Shared Scan (share slice:id 1:0)  (cost=0.00..613.90 rows=2097963 width=1) (actual time=5968.917..7283.082 rows=2099027 loops=1)
              ->  Seq Scan on ticket_flights  (cost=0.00..502.54 rows=2097963 width=28) (actual time=0.051..373.739 rows=2099027 loops=1)
        ->  Append  (cost=0.00..2339.94 rows=601761 width=32) (actual time=887.147..94374.228 rows=738114 loops=1)
              ->  Finalize HashAggregate  (cost=0.00..716.40 rows=81 width=14) (actual time=887.145..887.156 rows=96 loops=1)
                    Group Key: share0_ref2.amount
                    Extra Text: (seg0)   hash table(s): 1; chain length 2.4 avg, 5 max; using 84 of 128 buckets; total 0 expansions.

                    Extra Text: (seg1)   hash table(s): 1; chain length 3.0 avg, 6 max; using 96 of 128 buckets; total 0 expansions.

                    ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..716.39 rows=81 width=14) (actual time=0.009..887.081 rows=382 loops=1)
                          Hash Key: share0_ref2.amount
                          ->  Streaming Partial HashAggregate  (cost=0.00..716.38 rows=81 width=14) (actual time=9598.020..9598.045 rows=338 loops=1)
                                Group Key: share0_ref2.amount
                                Extra Text: (seg0)   hash table(s): 1; chain length 2.9 avg, 8 max; using 338 of 512 buckets; total 2 expansions.

                                ->  Shared Scan (share slice:id 2:0)  (cost=0.00..461.34 rows=2097963 width=6) (actual time=5809.768..7930.149 rows=2099027 loops=1)
              ->  HashAggregate  (cost=0.00..858.07 rows=601679 width=22) (actual time=90402.293..93369.931 rows=738017 loops=1)
                    Group Key: share0_ref3.ticket_no
                    Planned Partitions: 4
                    Extra Text: (seg0)   hash table(s): 1; 737289 groups total in 20 batches, 7057764 spill partitions; disk usage: 62976KB; chain length 2.2 avg, 9 max; using 737289 of 5505024 buckets; total 1 expansions.

                    ->  Redistribute Motion 4:4  (slice3; segments: 4)  (cost=0.00..593.72 rows=2097963 width=14) (actual time=0.009..77462.468 rows=2099727 loops=1)
                          Hash Key: share0_ref3.ticket_no
                          ->  Result  (cost=0.00..501.79 rows=2097963 width=14) (actual time=5124.759..9851.272 rows=2099027 loops=1)
                                ->  Shared Scan (share slice:id 3:0)  (cost=0.00..501.79 rows=2097963 width=14) (actual time=5124.756..7652.370 rows=2099027 loops=1)
              ->  Finalize HashAggregate  (cost=0.00..726.96 rows=1 width=16) (actual time=0.018..0.019 rows=2 loops=1)
                    Group Key: share0_ref4.fare_conditions
                    Extra Text: (seg0)   hash table(s): 1; chain length 1.0 avg, 1 max; using 2 of 4 buckets; total 1 expansions.

                    ->  Redistribute Motion 4:4  (slice4; segments: 4)  (cost=0.00..726.96 rows=1 width=16) (actual time=0.005..0.007 rows=8 loops=1)
                          Hash Key: share0_ref4.fare_conditions
                          ->  Streaming Partial HashAggregate  (cost=0.00..726.96 rows=1 width=16) (actual time=8956.789..8956.799 rows=3 loops=1)
                                Group Key: share0_ref4.fare_conditions
                                Extra Text: (seg0)   hash table(s): 1; chain length 1.0 avg, 1 max; using 3 of 8 buckets; total 2 expansions.

                                ->  Shared Scan (share slice:id 4:0)  (cost=0.00..471.45 rows=2097963 width=8) (actual time=4377.133..5602.449 rows=2099027 loops=1)
Optimizer: GPORCA
Planning Time: 15.566 ms
  (slice0)    Executor memory: 3201K bytes.
* (slice1)    Executor memory: 14315K bytes avg x 4 workers, 14431K bytes max (seg2).  Work_mem: 16561K bytes max, 86033K bytes wanted.
* (slice2)    Executor memory: 98K bytes avg x 4 workers, 98K bytes max (seg0).  Work_mem: 77K bytes max, 77K bytes wanted.
  (slice3)    Executor memory: 69K bytes avg x 4 workers, 69K bytes max (seg0).
* (slice4)    Executor memory: 69K bytes avg x 4 workers, 69K bytes max (seg0).  Work_mem: 24K bytes max, 24K bytes wanted.
Memory used:  128000kB
Memory wanted:  775088kB
Execution Time: 118067.772 ms

-- 20
explain analyze select flight_id, count(*) from ticket_flights group by flight_id;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..779.88 rows=81020 width=12) (actual time=9419.145..10020.897 rows=150588 loops=1)
  ->  Finalize HashAggregate  (cost=0.00..776.62 rows=20255 width=12) (actual time=9416.648..9425.751 rows=37736 loops=1)
        Group Key: flight_id
        Extra Text: (seg0)   hash table(s): 1; chain length 2.6 avg, 8 max; using 37736 of 65536 buckets; total 1 expansions.

        ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..774.03 rows=20255 width=12) (actual time=1112.621..8403.487 rows=143817 loops=1)
              Hash Key: flight_id
              ->  Streaming Partial HashAggregate  (cost=0.00..773.27 rows=20255 width=12) (actual time=1085.936..2072.000 rows=143630 loops=1)
                    Group Key: flight_id
                    Extra Text: (seg0)   hash table(s): 1; chain length 2.5 avg, 10 max; using 143497 of 262144 buckets; total 3 expansions.

                    ->  Seq Scan on ticket_flights  (cost=0.00..502.54 rows=2097963 width=4) (actual time=0.223..196.824 rows=2099027 loops=1)
Optimizer: GPORCA
Planning Time: 2.860 ms
  (slice0)    Executor memory: 1586K bytes.
* (slice1)    Executor memory: 3579K bytes avg x 4 workers, 3622K bytes max (seg1).  Work_mem: 5649K bytes max, 5649K bytes wanted.
* (slice2)    Executor memory: 14215K bytes avg x 4 workers, 14293K bytes max (seg0).  Work_mem: 18449K bytes max, 18449K bytes wanted.
Memory used:  128000kB
Memory wanted:  37196kB
Execution Time: 10039.379 ms

-- 21
explain analyze select * from tickets t join ticket_flights tf on tf.ticket_no = t.ticket_no where t.ticket_no in ('0005432312163','0005432312164');

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..897.60 rows=12 width=136) (actual time=615.611..1095.372 rows=8 loops=1)
  ->  Hash Join  (cost=0.00..897.60 rows=3 width=136) (actual time=99.207..601.821 rows=4 loops=1)
        Hash Cond: (t.ticket_no = tf.ticket_no)
        Extra Text: (seg0)   Hash chain length 4.0 avg, 4 max, using 1 of 131072 buckets.
        ->  Seq Scan on tickets t  (cost=0.00..509.61 rows=1 width=104) (actual time=92.344..594.894 rows=1 loops=1)
              Filter: ((ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[])) AND (ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[])))
              Rows Removed by Filter: 737288
        ->  Hash  (cost=387.97..387.97 rows=2 width=32) (actual time=1.651..1.652 rows=4 loops=1)
              Buckets: 131072  Batches: 1  Memory Usage: 1025kB
              ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..387.97 rows=2 width=32) (actual time=0.005..1.644 rows=4 loops=1)
                    Hash Key: tf.ticket_no
                    ->  Bitmap Heap Scan on ticket_flights tf  (cost=0.00..387.97 rows=2 width=32) (actual time=1.004..1.033 rows=3 loops=1)
                          Recheck Cond: (ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[]))
                          Heap Blocks: exact=3
                          ->  Bitmap Index Scan on ticket_flights_pkey  (cost=0.00..0.00 rows=0 width=0) (actual time=0.663..0.663 rows=3 loops=1)
                                Index Cond: (ticket_no = ANY ('{0005432312163,0005432312164}'::bpchar[]))
Optimizer: GPORCA
Planning Time: 8.749 ms
  (slice0)    Executor memory: 89K bytes.
  (slice1)    Executor memory: 1154K bytes avg x 4 workers, 1260K bytes max (seg0).  Work_mem: 1025K bytes max.
  (slice2)    Executor memory: 1929K bytes avg x 4 workers, 2441K bytes max (seg0).
Memory used:  128000kB
Execution Time: 1097.162 ms

-- 22
explain analyze select * from aircrafts a left join seats s on (a.aircraft_code = s.aircraft_code) where a.model like 'аэробус%';

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..862.18 rows=2 width=35) (actual time=93.074..93.076 rows=0 loops=1)
  ->  Hash Left Join  (cost=0.00..862.18 rows=1 width=35) (actual time=0.000..91.414 rows=0 loops=1)
        Hash Cond: (ml.aircraft_code = s.aircraft_code)
        ->  Result  (cost=0.00..431.00 rows=1 width=20) (actual time=0.000..8.128 rows=0 loops=1)
              ->  Result  (cost=0.00..431.00 rows=1 width=20) (actual time=0.000..8.126 rows=0 loops=1)
                    Filter: ((NULL::text) ~~ 'аэробус%'::text)
                    ->  Seq Scan on aircrafts_data ml  (cost=0.00..431.00 rows=1 width=12) (actual time=2.777..2.783 rows=9 loops=1)
        ->  Hash  (cost=431.03..431.03 rows=335 width=15) (actual time=82.254..82.255 rows=1053 loops=1)
              Buckets: 524288  Batches: 1  Memory Usage: 4146kB
              ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..431.03 rows=335 width=15) (actual time=16.774..82.181 rows=1053 loops=1)
                    Hash Key: s.aircraft_code
                    ->  Seq Scan on seats s  (cost=0.00..431.01 rows=335 width=15) (actual time=0.278..0.309 rows=352 loops=1)
Optimizer: GPORCA
Planning Time: 19.203 ms
  (slice0)    Executor memory: 46K bytes.
  (slice1)    Executor memory: 4334K bytes avg x 4 workers, 4368K bytes max (seg2).  Work_mem: 4146K bytes max.
  (slice2)    Executor memory: 183K bytes avg x 4 workers, 183K bytes max (seg0).
Memory used:  128000kB
Execution Time: 106.811 ms

-- 23
explain analyze select * from aircrafts a where a.model like 'аэробус%' 
  and not exists (select * from seats s where s.aircraft_code = a.aircraft_code);

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..862.05 rows=1 width=20) (actual time=40.468..40.471 rows=0 loops=1)
  ->  Result  (cost=0.00..862.05 rows=1 width=20) (actual time=0.000..36.473 rows=0 loops=1)
        Filter: ((NULL::text) ~~ 'аэробус%'::text)
        ->  Result  (cost=0.00..862.05 rows=1 width=12) (actual time=0.000..36.472 rows=0 loops=1)
              Filter: (COALESCE((count()), '0'::bigint) = '0'::bigint)
              ->  Hash Left Join  (cost=0.00..862.05 rows=1 width=20) (actual time=35.000..35.106 rows=7 loops=1)
                    Hash Cond: (ml.aircraft_code = s.aircraft_code)
                    Extra Text: (seg2)   Hash chain length 1.0 avg, 1 max, using 7 of 262144 buckets.
                    ->  Result  (cost=0.00..431.00 rows=1 width=12) (actual time=0.048..0.051 rows=7 loops=1)
                          ->  Seq Scan on aircrafts_data ml  (cost=0.00..431.00 rows=1 width=12) (actual time=0.071..0.074 rows=9 loops=1)
                    ->  Hash  (cost=431.05..431.05 rows=3 width=12) (actual time=34.800..34.801 rows=7 loops=1)
                          Buckets: 262144  Batches: 1  Memory Usage: 2049kB
                          ->  Finalize GroupAggregate  (cost=0.00..431.05 rows=3 width=12) (actual time=34.792..34.796 rows=7 loops=1)
                                Group Key: s.aircraft_code
                                ->  Sort  (cost=0.00..431.05 rows=3 width=12) (actual time=34.785..34.786 rows=28 loops=1)
                                      Sort Key: s.aircraft_code
                                      Sort Method:  quicksort  Memory: 101kB
                                      Executor Memory: 111kB  Segments: 4  Max: 29kB (segment 2)
                                      ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..431.05 rows=3 width=12) (actual time=1.693..34.764 rows=28 loops=1)
                                            Hash Key: s.aircraft_code
                                            ->  Streaming Partial HashAggregate  (cost=0.00..431.05 rows=3 width=12) (actual time=0.154..0.161 rows=9 loops=1)
                                                  Group Key: s.aircraft_code
                                                  Extra Text: (seg0)   hash table(s): 1; chain length 1.7 avg, 2 max; using 9 of 16 buckets; total 2 expansions.

                                                  ->  Seq Scan on seats s  (cost=0.00..431.01 rows=335 width=4) (actual time=0.264..0.284 rows=352 loops=1)
Optimizer: GPORCA
Planning Time: 12.701 ms
  (slice0)    Executor memory: 71K bytes.
  (slice1)    Executor memory: 2316K bytes avg x 4 workers, 2325K bytes max (seg2).  Work_mem: 2049K bytes max.
* (slice2)    Executor memory: 194K bytes avg x 4 workers, 194K bytes max (seg0).  Work_mem: 24K bytes max, 24K bytes wanted.
Memory used:  128000kB
Memory wanted:  972kB
Execution Time: 42.532 ms

-- 24
explain analyze select * from aircrafts a where a.model like 'аэробус%'
  and exists (select * from seats s where s.aircraft_code = a.aircraft_code);

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..862.05 rows=1 width=20) (actual time=39.655..39.658 rows=0 loops=1)
  ->  Result  (cost=0.00..862.05 rows=1 width=20) (actual time=0.000..33.101 rows=0 loops=1)
        Filter: ((NULL::text) ~~ 'аэробус%'::text)
        ->  Hash Join  (cost=0.00..862.05 rows=1 width=12) (actual time=32.219..32.323 rows=7 loops=1)
              Hash Cond: (ml.aircraft_code = s.aircraft_code)
              Extra Text: (seg2)   Hash chain length 1.0 avg, 1 max, using 7 of 262144 buckets.
              ->  Result  (cost=0.00..431.00 rows=1 width=12) (actual time=0.059..0.063 rows=7 loops=1)
                    ->  Seq Scan on aircrafts_data ml  (cost=0.00..431.00 rows=1 width=12) (actual time=0.055..0.061 rows=9 loops=1)
                          Filter: (NOT (aircraft_code IS NULL))
              ->  Hash  (cost=431.05..431.05 rows=3 width=4) (actual time=31.964..31.965 rows=7 loops=1)
                    Buckets: 262144  Batches: 1  Memory Usage: 2049kB
                    ->  GroupAggregate  (cost=0.00..431.05 rows=3 width=4) (actual time=31.956..31.959 rows=7 loops=1)
                          Group Key: s.aircraft_code
                          ->  Sort  (cost=0.00..431.05 rows=3 width=4) (actual time=31.950..31.951 rows=28 loops=1)
                                Sort Key: s.aircraft_code
                                Sort Method:  quicksort  Memory: 101kB
                                Executor Memory: 111kB  Segments: 4  Max: 29kB (segment 2)
                                ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..431.05 rows=3 width=4) (actual time=1.743..31.933 rows=28 loops=1)
                                      Hash Key: s.aircraft_code
                                      ->  Streaming HashAggregate  (cost=0.00..431.05 rows=3 width=4) (actual time=0.193..0.201 rows=9 loops=1)
                                            Group Key: s.aircraft_code
                                            Extra Text: (seg0)   hash table(s): 1; chain length 2.0 avg, 2 max; using 9 of 16 buckets; total 2 expansions.

                                            ->  Seq Scan on seats s  (cost=0.00..431.01 rows=335 width=4) (actual time=0.461..0.480 rows=352 loops=1)
Optimizer: GPORCA
Planning Time: 16.476 ms
  (slice0)    Executor memory: 64K bytes.
  (slice1)    Executor memory: 2268K bytes avg x 4 workers, 2320K bytes max (seg2).  Work_mem: 2049K bytes max.
* (slice2)    Executor memory: 193K bytes avg x 4 workers, 193K bytes max (seg0).  Work_mem: 24K bytes max, 24K bytes wanted.
Memory used:  128000kB
Memory wanted:  872kB
Execution Time: 42.420 ms

-- 25
explain analyze select * from flights f join aircrafts_data a on f.aircraft_code = a.aircraft_code where f.flight_no = 'PG0003';

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..868.32 rows=1 width=143) (actual time=9.164..13.586 rows=113 loops=1)
  ->  Hash Join  (cost=0.00..868.32 rows=1 width=143) (actual time=5.633..6.186 rows=34 loops=1)
        Hash Cond: (f.aircraft_code = a.aircraft_code)
        Extra Text: (seg2)   Hash chain length 1.0 avg, 1 max, using 9 of 262144 buckets.
        ->  Seq Scan on flights f  (cost=0.00..437.30 rows=69 width=123) (actual time=5.399..5.843 rows=34 loops=1)
              Filter: (flight_no = 'PG0003'::bpchar)
              Rows Removed by Filter: 53697
        ->  Hash  (cost=431.00..431.00 rows=1 width=20) (actual time=0.102..0.103 rows=9 loops=1)
              Buckets: 262144  Batches: 1  Memory Usage: 2049kB
              ->  Seq Scan on aircrafts_data a  (cost=0.00..431.00 rows=1 width=20) (actual time=0.093..0.096 rows=9 loops=1)
Optimizer: GPORCA
Planning Time: 5.011 ms
  (slice0)    Executor memory: 50K bytes.
  (slice1)    Executor memory: 3280K bytes avg x 4 workers, 3280K bytes max (seg0).  Work_mem: 2049K bytes max.
Memory used:  128000kB
Execution Time: 15.080 ms

-- 26
explain analyze select t.passenger_name from tickets t join ticket_flights tf on tf.ticket_no = t.ticket_no
  join flights f on f.flight_id = tf.flight_id where f.flight_id = 12345;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..1112.31 rows=104 width=16) (actual time=974.691..3327.197 rows=22 loops=1)
  ->  Hash Join  (cost=0.00..1112.30 rows=26 width=16) (actual time=1316.394..2317.429 rows=7 loops=1)
        Hash Cond: (t.ticket_no = tf.ticket_no)
        Extra Text: (seg0)   Hash chain length 1.0 avg, 1 max, using 7 of 524288 buckets.
        ->  Seq Scan on tickets t  (cost=0.00..485.35 rows=737465 width=30) (actual time=16.028..2236.991 rows=738017 loops=1)
        ->  Hash  (cost=444.14..444.14 rows=26 width=14) (actual time=625.221..625.222 rows=7 loops=1)
              Buckets: 524288  Batches: 1  Memory Usage: 4097kB
              ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..444.14 rows=26 width=14) (actual time=515.212..625.204 rows=7 loops=1)
                    Hash Key: tf.ticket_no
                    ->  Nested Loop  (cost=0.00..444.14 rows=26 width=14) (actual time=209.473..506.757 rows=7 loops=1)
                          Join Filter: true
                          ->  Broadcast Motion 4:4  (slice3; segments: 4)  (cost=0.00..437.29 rows=1 width=4) (actual time=6.938..6.942 rows=1 loops=1)
                                ->  Seq Scan on flights f  (cost=0.00..437.29 rows=1 width=4) (actual time=0.307..2.446 rows=1 loops=1)
                                      Filter: (flight_id = 12345)
                                      Rows Removed by Filter: 53681
                          ->  Index Only Scan using ticket_flights_pkey on ticket_flights tf  (cost=0.00..6.85 rows=26 width=14) (actual time=204.283..501.552 rows=7 loops=1)
                                Index Cond: ((flight_id = f.flight_id) AND (flight_id = 12345))
                                Heap Fetches: 0
Optimizer: GPORCA
Planning Time: 8.594 ms
  (slice0)    Executor memory: 48K bytes.
  (slice1)    Executor memory: 4326K bytes avg x 4 workers, 4326K bytes max (seg2).  Work_mem: 4097K bytes max.
  (slice2)    Executor memory: 180K bytes avg x 4 workers, 180K bytes max (seg0).
  (slice3)    Executor memory: 161K bytes avg x 4 workers, 167K bytes max (seg3).
Memory used:  128000kB
Execution Time: 3368.559 ms

-- 27
explain analyze select * from flights where flight_no = 'PG0007' and departure_airport = 'VKO';

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..439.07 rows=25 width=123) (actual time=6.842..14.859 rows=396 loops=1)
  ->  Seq Scan on flights  (cost=0.00..439.06 rows=7 width=123) (actual time=1.125..5.516 rows=102 loops=1)
        Filter: ((flight_no = 'PG0007'::bpchar) AND (departure_airport = 'VKO'::bpchar))
        Rows Removed by Filter: 53616
Optimizer: GPORCA
Planning Time: 3.069 ms
  (slice0)    Executor memory: 37K bytes.
  (slice1)    Executor memory: 1052K bytes avg x 4 workers, 1052K bytes max (seg0).
Memory used:  128000kB
Execution Time: 16.655 ms

create statistics s1 (dependencies) on flight_no, departure_airport from flights;
analyze flights;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..439.18 rows=276 width=123) (actual time=3.950..8.316 rows=396 loops=1)
  ->  Seq Scan on flights  (cost=0.00..439.07 rows=69 width=123) (actual time=1.418..6.570 rows=102 loops=1)
        Filter: ((flight_no = 'PG0007'::bpchar) AND (departure_airport = 'VKO'::bpchar))
        Rows Removed by Filter: 53616
Optimizer: GPORCA
Planning Time: 3.067 ms
  (slice0)    Executor memory: 38K bytes.
  (slice1)    Executor memory: 1052K bytes avg x 4 workers, 1052K bytes max (seg0).
Memory used:  128000kB
Execution Time: 13.351 ms

-- 28
explain analyze select * from flights where departure_airport = 'LED' and aircraft_code = '321';

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..439.68 rows=1337 width=123) (actual time=0.338..98.332 rows=5148 loops=1)
  ->  Seq Scan on flights  (cost=0.00..439.13 rows=335 width=123) (actual time=0.278..11.428 rows=1331 loops=1)
        Filter: ((departure_airport = 'LED'::bpchar) AND (aircraft_code = '321'::bpchar))
        Rows Removed by Filter: 52405
Optimizer: GPORCA
Planning Time: 3.185 ms
  (slice0)    Executor memory: 38K bytes.
  (slice1)    Executor memory: 1052K bytes avg x 4 workers, 1052K bytes max (seg0).
Memory used:  128000kB
Execution Time: 106.225 ms

create statistics s2 (mcv) on departure_airport, aircraft_code from flights;
analyze flights;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..439.66 rows=1300 width=123) (actual time=2.621..27.736 rows=5148 loops=1)
  ->  Seq Scan on flights  (cost=0.00..439.13 rows=325 width=123) (actual time=0.268..5.096 rows=1331 loops=1)
        Filter: ((departure_airport = 'LED'::bpchar) AND (aircraft_code = '321'::bpchar))
        Rows Removed by Filter: 52405
Optimizer: GPORCA
Planning Time: 4.379 ms
  (slice0)    Executor memory: 38K bytes.
  (slice1)    Executor memory: 1052K bytes avg x 4 workers, 1052K bytes max (seg0).
Memory used:  128000kB
Execution Time: 28.715 ms

-- 29
explain analyze select distinct departure_airport, arrival_airport from flights;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..449.91 rows=6084 width=8) (actual time=77.839..79.863 rows=618 loops=1)
  ->  HashAggregate  (cost=0.00..449.75 rows=1521 width=8) (actual time=70.622..70.636 rows=166 loops=1)
        Group Key: departure_airport, arrival_airport
        Extra Text: (seg1)   hash table(s): 1; chain length 2.0 avg, 3 max; using 166 of 2048 buckets; total 0 expansions.

        ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..449.37 rows=1521 width=8) (actual time=20.535..70.523 rows=664 loops=1)
              Hash Key: departure_airport, arrival_airport
              ->  Streaming HashAggregate  (cost=0.00..449.34 rows=1521 width=8) (actual time=10.108..10.156 rows=618 loops=1)
                    Group Key: departure_airport, arrival_airport
                    Extra Text: (seg0)   hash table(s): 1; chain length 2.1 avg, 4 max; using 618 of 2048 buckets; total 0 expansions.

                    ->  Seq Scan on flights  (cost=0.00..435.52 rows=53717 width=8) (actual time=0.290..3.190 rows=53736 loops=1)
Optimizer: GPORCA
Planning Time: 2.681 ms
  (slice0)    Executor memory: 140K bytes.
* (slice1)    Executor memory: 76K bytes avg x 4 workers, 77K bytes max (seg1).  Work_mem: 81K bytes max, 81K bytes wanted.
* (slice2)    Executor memory: 327K bytes avg x 4 workers, 327K bytes max (seg1).  Work_mem: 97K bytes max, 97K bytes wanted.
Memory used:  128000kB
Memory wanted:  492kB
Execution Time: 105.173 ms

create statistics s3 on departure_airport, arrival_airport from flights;
analyze flights;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..449.37 rows=618 width=8) (actual time=27.894..29.371 rows=618 loops=1)
  ->  HashAggregate  (cost=0.00..449.35 rows=155 width=8) (actual time=26.782..26.793 rows=166 loops=1)
        Group Key: departure_airport, arrival_airport
        Extra Text: (seg1)   hash table(s): 1; chain length 2.4 avg, 5 max; using 166 of 256 buckets; total 0 expansions.

        ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..449.31 rows=155 width=8) (actual time=21.262..26.716 rows=664 loops=1)
              Hash Key: departure_airport, arrival_airport
              ->  Streaming HashAggregate  (cost=0.00..449.31 rows=155 width=8) (actual time=9.250..9.287 rows=618 loops=1)
                    Group Key: departure_airport, arrival_airport
                    Extra Text: (seg0)   hash table(s): 1; chain length 2.7 avg, 7 max; using 618 of 1024 buckets; total 2 expansions.

                    ->  Seq Scan on flights  (cost=0.00..435.52 rows=53717 width=8) (actual time=0.306..3.067 rows=53736 loops=1)
Optimizer: GPORCA
Planning Time: 2.990 ms
  (slice0)    Executor memory: 60K bytes.
* (slice1)    Executor memory: 44K bytes avg x 4 workers, 44K bytes max (seg0).  Work_mem: 48K bytes max, 48K bytes wanted.
* (slice2)    Executor memory: 291K bytes avg x 4 workers, 291K bytes max (seg1).  Work_mem: 89K bytes max, 89K bytes wanted.
Memory used:  128000kB
Memory wanted:  476kB
Execution Time: 37.929 ms

-- 30
explain analyze select * from flights where extract(month from scheduled_departure::timestamp with time zone at time zone 'Europe/Moscow') = 1;

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..477.56 rows=85947 width=123) (actual time=2.172..189.274 rows=16831 loops=1)
  ->  Seq Scan on flights  (cost=0.00..442.20 rows=21487 width=123) (actual time=0.506..73.367 rows=4298 loops=1)
        Filter: (date_part('month'::text, timezone('Europe/Moscow'::text, (scheduled_departure)::timestamp with time zone)) = '1'::double precision)
        Rows Removed by Filter: 49420
Optimizer: GPORCA
Planning Time: 1.817 ms
  (slice0)    Executor memory: 38K bytes.
  (slice1)    Executor memory: 1052K bytes avg x 4 workers, 1052K bytes max (seg0).
Memory used:  128000kB
Execution Time: 195.092 ms

create statistics s4 on extract(month from scheduled_departure::timestamp with time zone at time zone 'Europe/Moscow') from flights; -- не поддерживается
-- SQL Error [0A000]: ERROR: only simple column references are allowed in CREATE STATISTICS
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

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..1307.94 rows=9 width=27) (actual time=1236.947..2529.783 rows=214867 loops=1)
  ->  Hash Join  (cost=0.00..1307.94 rows=3 width=27) (actual time=1222.976..1238.756 rows=194163 loops=1)
        Hash Cond: (s.aircraft_code = ml.aircraft_code)
        Extra Text: (seg2)   Hash chain length 32360.5 avg, 60196 max, using 6 of 262144 buckets.
        ->  Redistribute Motion 4:4  (slice2; segments: 4)  (cost=0.00..431.02 rows=3 width=15) (actual time=0.002..0.017 rows=7 loops=1)
              Hash Key: s.aircraft_code
              ->  Seq Scan on seats s  (cost=0.00..431.02 rows=3 width=15) (actual time=0.172..0.186 rows=4 loops=1)
                    Filter: ((seat_no)::text = '1A'::text)
                    Rows Removed by Filter: 348
        ->  Hash  (cost=876.92..876.92 rows=1 width=12) (actual time=1222.809..1222.810 rows=194163 loops=1)
              Buckets: 262144  Batches: 1  Memory Usage: 9633kB
              ->  Redistribute Motion 4:4  (slice3; segments: 4)  (cost=0.00..876.92 rows=1 width=12) (actual time=16.238..1207.685 rows=194163 loops=1)
                    Hash Key: ml.aircraft_code
                    ->  Hash Join  (cost=0.00..876.92 rows=1 width=12) (actual time=2.801..83.097 rows=53736 loops=1)
                          Hash Cond: (f.aircraft_code = ml.aircraft_code)
                          Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 9 of 262144 buckets.
                          ->  Seq Scan on flights f  (cost=0.00..435.52 rows=53717 width=8) (actual time=0.654..72.673 rows=53736 loops=1)
                          ->  Hash  (cost=431.00..431.00 rows=1 width=8) (actual time=0.537..0.537 rows=9 loops=1)
                                Buckets: 262144  Batches: 1  Memory Usage: 2049kB
                                ->  Seq Scan on aircrafts_data ml  (cost=0.00..431.00 rows=1 width=8) (actual time=0.529..0.531 rows=9 loops=1)
Optimizer: GPORCA
Planning Time: 12.882 ms
  (slice0)    Executor memory: 71K bytes.
  (slice1)    Executor memory: 4194K bytes avg x 4 workers, 9706K bytes max (seg2).  Work_mem: 9633K bytes max.
  (slice2)    Executor memory: 185K bytes avg x 4 workers, 185K bytes max (seg0).
  (slice3)    Executor memory: 2499K bytes avg x 4 workers, 2499K bytes max (seg0).  Work_mem: 2049K bytes max.
Memory used:  128000kB
Execution Time: 2566.404 ms

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

Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..78895.75 rows=716327 width=20) (actual time=5692.418..6746.387 rows=214971 loops=1)
  ->  Recursive Union  (cost=0.00..69941.66 rows=179082 width=8) (actual time=91.080..5706.161 rows=80862 loops=1)
        ->  Seq Scan on airports_data ml  (cost=0.00..1.26 rows=26 width=8) (actual time=4.267..4.272 rows=27 loops=1)
        ->  Hash Join  (cost=6105.84..6635.88 rows=17906 width=8) (actual time=2799.503..2804.040 rows=40418 loops=2)
              Hash Cond: (r.airport_code = f.departure_airport)
              Extra Text: (seg0)   Hash chain length 2066.0 avg, 20875 max, using 104 of 524288 buckets.
              ->  WorkTable Scan on r  (cost=0.00..5.85 rows=87 width=20) (actual time=0.001..0.588 rows=14 loops=2)
                    Filter: (n < 2)
                    Rows Removed by Filter: 22799
              ->  Hash  (cost=3420.01..3420.01 rows=214867 width=8) (actual time=5598.693..5598.694 rows=214867 loops=1)
                    Buckets: 524288  Batches: 1  Memory Usage: 12490kB
                    ->  Broadcast Motion 4:4  (slice2; segments: 4)  (cost=0.00..3420.01 rows=214867 width=8) (actual time=0.013..5570.181 rows=214867 loops=1)
                          ->  Seq Scan on flights f  (cost=0.00..734.17 rows=53717 width=8) (actual time=0.262..22.721 rows=53736 loops=1)
Optimizer: Postgres-based planner
Planning Time: 11.851 ms
  (slice0)    Executor memory: 87K bytes.
  (slice1)    Executor memory: 15046K bytes avg x 4 workers, 16277K bytes max (seg0).  Work_mem: 12490K bytes max.
  (slice2)    Executor memory: 263K bytes avg x 4 workers, 263K bytes max (seg0).
Memory used:  128000kB
Execution Time: 6755.768 ms



