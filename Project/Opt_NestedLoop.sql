set schema 'bookings';

explain analyze 
with q as (select b1.book_ref, b1.total_amount from bookings b1 limit 100)
select q.book_ref, q.total_amount from q left join bookings b2 on q.total_amount > b2.total_amount and q.total_amount < b2.total_amount + 100;

-- Arenadata DB 7.2

Nested Loop Left Join  (cost=0.00..18009777.49 rows=28148150 width=13) (actual time=7288.358..44161.007 rows=100 loops=1)
  Join Filter: ((b1.total_amount > b2.total_amount) AND (b1.total_amount < (b2.total_amount + '100'::numeric)))
  Rows Removed by Join Filter: 211111000
  ->  Limit  (cost=0.00..462.93 rows=100 width=13) (actual time=0.006..0.355 rows=100 loops=1)
        ->  Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..462.92 rows=100 width=13) (actual time=0.004..0.249 rows=100 loops=1)
              ->  Limit  (cost=0.00..462.92 rows=25 width=13) (actual time=0.099..0.109 rows=100 loops=1)
                    ->  Seq Scan on bookings b1  (cost=0.00..450.16 rows=527778 width=13) (actual time=0.093..0.098 rows=100 loops=1)
  ->  Materialize  (cost=0.00..511.08 rows=2111110 width=6) (actual time=63.215..156.556 rows=2090208 loops=101)
        ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..498.42 rows=2111110 width=6) (actual time=0.016..6155.398 rows=2111110 loops=1)
              ->  Seq Scan on bookings b2  (cost=0.00..450.16 rows=527778 width=6) (actual time=0.192..51.241 rows=528627 loops=1)
Optimizer: GPORCA
Planning Time: 6.093 ms
  (slice0)    Executor memory: 84234K bytes.  Work_mem: 117173K bytes max.
  (slice1)    Executor memory: 190K bytes avg x 4 workers, 190K bytes max (seg0).
  (slice2)    Executor memory: 186K bytes avg x 4 workers, 186K bytes max (seg0).
Memory used:  128000kB
Execution Time: 44179.454 ms

set optimizer = off;

Nested Loop Left Join  (cost=10000000000.00..10006941809.04 rows=23456778 width=44) (actual time=9048.441..87574.355 rows=100 loops=1)
  Join Filter: ((b1.total_amount > b2.total_amount) AND (b1.total_amount < (b2.total_amount + '100'::numeric)))
  Rows Removed by Join Filter: 211111000
  ->  Limit  (cost=0.00..1.54 rows=100 width=13) (actual time=1.622..3.055 rows=100 loops=1)
        ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..6.15 rows=400 width=13) (actual time=1.619..1.872 rows=100 loops=1)
              ->  Limit  (cost=0.00..1.15 rows=100 width=13) (actual time=0.096..0.110 rows=100 loops=1)
                    ->  Seq Scan on bookings b1  (cost=0.00..6084.78 rows=527778 width=13) (actual time=0.086..0.093 rows=100 loops=1)
  ->  Materialize  (cost=0.00..43029.20 rows=2111110 width=6) (actual time=0.035..453.554 rows=2111110 loops=100)
        ->  Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..32473.65 rows=2111110 width=6) (actual time=3.464..7305.411 rows=2111110 loops=1)
              ->  Seq Scan on bookings b2  (cost=0.00..6084.78 rows=527778 width=6) (actual time=0.182..58.842 rows=528627 loops=1)
Optimizer: Postgres-based planner
Planning Time: 3.370 ms
  (slice0)    Executor memory: 84203K bytes.  Work_mem: 117145K bytes max.
  (slice1)    Executor memory: 185K bytes avg x 4 workers, 185K bytes max (seg0).
  (slice2)    Executor memory: 190K bytes avg x 4 workers, 190K bytes max (seg0).
Memory used:  128000kB
Execution Time: 87591.542 ms

-- Cloudberry 1.6

Nested Loop Left Join  (cost=0.00..18037344.36 rows=28148150 width=13) (actual time=1551.487..33154.994 rows=100 loops=1)
  Join Filter: ((bookings_1.total_amount > bookings.total_amount) AND (bookings_1.total_amount < (bookings.total_amount + '100'::numeric)))
  Rows Removed by Join Filter: 211111000
  ->  Limit  (cost=0.00..475.11 rows=100 width=13) (actual time=0.007..0.459 rows=100 loops=1)
        ->  Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..475.11 rows=100 width=13) (actual time=0.004..0.367 rows=100 loops=1)
              ->  Limit  (cost=0.00..475.11 rows=34 width=13) (actual time=3.274..3.286 rows=100 loops=1)
                    ->  Seq Scan on bookings bookings_1  (cost=0.00..458.09 rows=703704 width=13) (actual time=3.273..3.279 rows=100 loops=1)
  ->  Materialize  (cost=0.00..525.82 rows=2111110 width=6) (actual time=11.968..87.587 rows=2090208 loops=101)
        ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..513.15 rows=2111110 width=6) (actual time=18.788..499.185 rows=2111110 loops=1)
              ->  Seq Scan on bookings  (cost=0.00..458.09 rows=703704 width=6) (actual time=3.762..258.843 rows=705433 loops=1)
Planning Time: 50.735 ms
  (slice0)    Executor memory: 84243K bytes.  Work_mem: 117173K bytes max.
  (slice1)    Executor memory: 262K bytes avg x 3x(0) workers, 262K bytes max (seg0).
  (slice2)    Executor memory: 260K bytes avg x 3x(0) workers, 260K bytes max (seg0).
Memory used:  128000kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution Time: 33190.099 ms

set optimizer = off;

Nested Loop Left Join  (cost=10000000000.00..10007320460.88 rows=23456778 width=44) (actual time=583.775..23182.584 rows=100 loops=1)
  Join Filter: ((b1.total_amount > b2.total_amount) AND (b1.total_amount < (b2.total_amount + '100'::numeric)))
  Rows Removed by Join Filter: 211111000
  ->  Limit  (cost=0.00..1.72 rows=100 width=13) (actual time=0.601..0.934 rows=100 loops=1)
        ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..5.15 rows=300 width=13) (actual time=0.600..0.872 rows=100 loops=1)
              ->  Limit  (cost=0.00..1.15 rows=100 width=13) (actual time=0.073..0.082 rows=100 loops=1)
                    ->  Seq Scan on bookings b1  (cost=0.00..8112.03 rows=703703 width=13) (actual time=0.072..0.077 rows=100 loops=1)
  ->  Materialize  (cost=0.00..46815.72 rows=2111110 width=6) (actual time=3.544..65.557 rows=2111110 loops=100)
        ->  Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..36260.17 rows=2111110 width=6) (actual time=3.565..238.704 rows=2111110 loops=1)
              ->  Seq Scan on bookings b2  (cost=0.00..8112.03 rows=703703 width=6) (actual time=0.113..78.805 rows=705433 loops=1)
Planning Time: 6.348 ms
  (slice0)    Executor memory: 84238K bytes.  Work_mem: 117173K bytes max.
  (slice1)    Executor memory: 258K bytes avg x 3x(0) workers, 258K bytes max (seg0).
  (slice2)    Executor memory: 262K bytes avg x 3x(0) workers, 262K bytes max (seg0).
Memory used:  128000kB
Optimizer: Postgres query optimizer
Execution Time: 23198.395 ms

-- Arenadata 6.27 

Nested Loop Left Join  (cost=0.00..18021491.33 rows=9382717 width=13) (actual time=908.193..23898.546 rows=100 loops=1)
  Join Filter: ((b1.total_amount > b2.total_amount) AND (b1.total_amount < (b2.total_amount + '100'::numeric)))
  Rows Removed by Join Filter: 211111000
  ->  Limit  (cost=0.00..467.37 rows=34 width=13) (actual time=0.004..0.246 rows=100 loops=1)
        ->  Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..467.37 rows=100 width=13) (actual time=0.003..0.197 rows=100 loops=1)
              ->  Limit  (cost=0.00..467.37 rows=34 width=13) (actual time=3.693..3.702 rows=100 loops=1)
                    ->  Seq Scan on bookings b1  (cost=0.00..450.35 rows=703704 width=13) (actual time=3.693..3.697 rows=100 loops=1)
  ->  Materialize  (cost=0.00..518.08 rows=703704 width=6) (actual time=6.511..55.878 rows=2090208 loops=101)
        ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..505.41 rows=2111110 width=6) (actual time=13.115..485.694 rows=2111110 loops=1)
              ->  Seq Scan on bookings b2  (cost=0.00..450.35 rows=703704 width=6) (actual time=1.767..243.819 rows=705433 loops=1)
Planning time: 41.121 ms
* (slice0)    Executor memory: 41652K bytes.  Work_mem: 41312K bytes max, 41280K bytes wanted.
  (slice1)    Executor memory: 220K bytes avg x 3 workers, 220K bytes max (seg0).
  (slice2)    Executor memory: 204K bytes avg x 3 workers, 204K bytes max (seg0).
Memory used:  128000kB
Memory wanted:  41980kB
Optimizer: Pivotal Optimizer (GPORCA)
Execution time: 23909.984 ms

set optimizer = off;

Nested Loop Left Join  (cost=10000000000.00..10004498196.08 rows=23456778 width=44) (actual time=1640.134..28534.315 rows=100 loops=1)
  Join Filter: ((b1.total_amount > b2.total_amount) AND (b1.total_amount < (b2.total_amount + '100'::numeric)))
  Rows Removed by Join Filter: 211111000
  ->  Limit  (cost=0.00..3.15 rows=100 width=13) (actual time=1.265..1.550 rows=100 loops=1)
        ->  Gather Motion 3:1  (slice1; segments: 3)  (cost=0.00..3.15 rows=100 width=13) (actual time=1.263..1.491 rows=100 loops=1)
              ->  Limit  (cost=0.00..1.15 rows=34 width=13) (actual time=0.051..0.060 rows=100 loops=1)
                    ->  Seq Scan on bookings b1  (cost=0.00..24336.10 rows=703704 width=13) (actual time=0.051..0.055 rows=100 loops=1)
  ->  Materialize  (cost=0.00..77113.85 rows=703704 width=6) (actual time=14.498..68.816 rows=2111110 loops=100)
        ->  Gather Motion 3:1  (slice2; segments: 3)  (cost=0.00..66558.30 rows=2111110 width=6) (actual time=0.047..1304.426 rows=2111110 loops=1)
              ->  Seq Scan on bookings b2  (cost=0.00..24336.10 rows=703704 width=6) (actual time=0.063..68.847 rows=705433 loops=1)
Planning time: 6.152 ms
* (slice0)    Executor memory: 58220K bytes.  Work_mem: 57856K bytes max, 57824K bytes wanted.
  (slice1)    Executor memory: 204K bytes avg x 3 workers, 204K bytes max (seg0).
  (slice2)    Executor memory: 220K bytes avg x 3 workers, 220K bytes max (seg0).
Memory used:  128000kB
Memory wanted:  58524kB
Optimizer: Postgres query optimizer
Execution time: 28540.146 ms




