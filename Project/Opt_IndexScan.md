## Index Scan ##

**Запрос:**
```
explain analyze select total_amount from bookings where total_amount > 200000;
```
   
**План выполнения запроса в PostgreSQL 17:**
   
```
Index Only Scan using bookings_total_amount_idx on bookings
  Index Cond: (total_amount > '200000'::numeric)
```

**План выполнения запроса в Arenadata DB 7.2**   
   
**Без индекса:**   
```
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..470.73 rows=140272 width=6) (actual time=18.210..7060.269 rows=141535 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..467.91 rows=35068 width=6) (actual time=4.629..4800.110 rows=35523 loops=1)
        Filter: (total_amount > '200000'::numeric)
        Rows Removed by Filter: 491466
Optimizer: GPORCA
Planning Time: 7.818 ms
  (slice0)    Executor memory: 30K bytes.
  (slice1)    Executor memory: 191K bytes avg x 4 workers, 191K bytes max (seg0).
Memory used:  128000kB
Execution Time: 7074.754 ms
```
**С индексом:**   
   
**С оптимизатором GPORCA:**
```
create index bookings_total_amount_idx on bookings using btree(total_amount);
analyze bookings;
set optimizer = on;
```
```
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..470.79 rows=142822 width=6) (actual time=1.161..1604.234 rows=141535 loops=1)
  ->  Seq Scan on bookings  (cost=0.00..467.92 rows=35706 width=6) (actual time=0.124..799.493 rows=35523 loops=1)
        Filter: (total_amount > '200000'::numeric)
        Rows Removed by Filter: 491466
Optimizer: GPORCA
Planning Time: 2.242 ms
  (slice0)    Executor memory: 30K bytes.
  (slice1)    Executor memory: 191K bytes avg x 4 workers, 191K bytes max (seg0).
Memory used:  128000kB
Execution Time: 1615.481 ms
```
**С оптимизатором Postgres:**
```
set optimizer = off;
```
```
Gather Motion 4:1  (slice1; segments: 4)  (cost=1480.18..4526.87 rows=143340 width=6) (actual time=5.968..440.136 rows=141535 loops=1)
  ->  Bitmap Heap Scan on bookings  (cost=1480.18..2735.12 rows=35835 width=6) (actual time=4.630..18.760 rows=35523 loops=1)
        Recheck Cond: (total_amount > '200000'::numeric)
        Heap Blocks: exact=17
        ->  Bitmap Index Scan on bookings_total_amount_idx  (cost=0.00..1471.22 rows=35835 width=0) (actual time=4.516..4.517 rows=35523 loops=1)
              Index Cond: (total_amount > '200000'::numeric)
Optimizer: Postgres-based planner
Planning Time: 0.303 ms
  (slice0)    Executor memory: 68K bytes.
  (slice1)    Executor memory: 2428K bytes avg x 4 workers, 2428K bytes max (seg0).
Memory used:  128000kB
Execution Time: 449.957 ms
```
   
**Выводы:** сканирование индекса в 15 раз ускорило выполнение запроса в Arenadata DB 7.2.
   
