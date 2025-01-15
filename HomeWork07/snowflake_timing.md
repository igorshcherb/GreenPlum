## Замеры времени выполнения запросов ##
 
### Query 1: Retrieve Customer Orders with Order and Customer Details ###   
```
explain (analyze)
select c.c_custkey, 
       c.c_name, 
       c.c_address, 
       c.c_phone,
       o.o_orderkey,
       o.o_orderdate,
       o.o_totalprice
from orders o
     join customer c on c.c_custkey = o.o_custkey
```
```
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..1105.98 rows=300000 width=85) (actual time=22.103..4044.185 rows=300000 loops=1)
  ->  Hash Join  (cost=0.00..991.49 rows=150000 width=85) (actual time=20.747..423.269 rows=151208 loops=1)
        Hash Cond: (o.o_custkey = c.c_custkey)
        Extra Text: (seg1)   Hash chain length 1.1 avg, 3 max, using 14175 of 131072 buckets.
        ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..460.60 rows=150000 width=24) (actual time=0.038..39.978 rows=151208 loops=1)
              Hash Key: o.o_custkey
              ->  Dynamic Seq Scan on orders o  (cost=0.00..442.63 rows=150000 width=24) (actual time=9.872..1488.464 rows=150135 loops=1)
                    Number of partitions to scan: 87 (out of 87)
                    Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
        ->  Hash  (cost=432.56..432.56 rows=15000 width=65) (actual time=15.829..15.829 rows=15031 loops=1)
              Buckets: 131072  Batches: 1  Memory Usage: 2450kB
              ->  Seq Scan on customer c  (cost=0.00..432.56 rows=15000 width=65) (actual time=9.569..11.917 rows=15031 loops=1)
Optimizer: GPORCA
Planning Time: 50.227 ms
  (slice0)    Executor memory: 48K bytes.
  (slice1)    Executor memory: 2971K bytes avg x 2 workers, 2983K bytes max (seg1).  Work_mem: 2450K bytes max.
  (slice2)    Executor memory: 710K bytes avg x 2 workers, 711K bytes max (seg1).
Memory used:  128000kB
Execution Time: 4076.185 ms
```
       
### Query 2: Retrieve Detailed Order Information with Line Items ###   
```
explain (analyze)     
select o.o_orderkey,
       o.o_orderdate,
       l.l_linenumber,
       l.l_quantity,
       l.l_discount
from orders o
     join lineitem l on l.l_orderkey = o.o_orderkey 
```
```
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..1344.60 rows=1199410 width=25) (actual time=589.233..9142.787 rows=1199969 loops=1)
  ->  Hash Join  (cost=0.00..1209.97 rows=599705 width=25) (actual time=591.747..4241.806 rows=600656 loops=1)
        Hash Cond: (l.l_orderkey = o.o_orderkey)
        Extra Text: (seg1)   Hash chain length 1.2 avg, 6 max, using 130535 of 524288 buckets.
        ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..543.70 rows=599985 width=21) (actual time=0.016..2258.274 rows=600656 loops=1)
              Hash Key: l.l_orderkey
              ->  Dynamic Seq Scan on lineitem l  (cost=0.00..480.83 rows=599985 width=21) (actual time=10.685..2102.222 rows=600209 loops=1)
                    Number of partitions to scan: 87 (out of 87)
                    Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
        ->  Hash  (cost=442.63..442.63 rows=150000 width=12) (actual time=586.317..586.317 rows=150135 loops=1)
              Buckets: 524288  Batches: 1  Memory Usage: 10548kB
              ->  Dynamic Seq Scan on orders o  (cost=0.00..442.63 rows=150000 width=12) (actual time=0.691..471.666 rows=150135 loops=1)
                    Number of partitions to scan: 87 (out of 87)
                    Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
Optimizer: GPORCA
Planning Time: 144.098 ms
  (slice0)    Executor memory: 51K bytes.
  (slice1)    Executor memory: 11601K bytes avg x 2 workers, 11601K bytes max (seg1).  Work_mem: 10548K bytes max.
  (slice2)    Executor memory: 796K bytes avg x 2 workers, 796K bytes max (seg1).
Memory used:  128000kB
Execution Time: 9210.230 ms
```
   
### Query 3: Retrieve Supplier and Part Information for Each Supplier-Part Relationship ###   
```
explain (analyze) 
select s.s_suppkey,
       s.s_name,
       s.s_address,
       p.p_partkey,
       p.p_name
from partsupp ps
     join supplier s on s.s_suppkey = ps.ps_suppkey
     join part p on p.p_partkey = ps.ps_partkey
```
```
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..1459.19 rows=159590 width=93) (actual time=199.285..1345.911 rows=160000 loops=1)
  ->  Hash Join  (cost=0.00..1392.56 rows=79795 width=93) (actual time=198.352..330.267 rows=80252 loops=1)
        Hash Cond: (ps.ps_suppkey = s.s_suppkey)
        Extra Text: (seg1)   Hash chain length 1.0 avg, 2 max, using 1988 of 131072 buckets.
        ->  Hash Join  (cost=0.00..913.85 rows=79795 width=41) (actual time=186.630..285.204 rows=80252 loops=1)
              Hash Cond: (p.p_partkey = ps.ps_partkey)
              Extra Text: (seg1)   Hash chain length 4.2 avg, 12 max, using 19248 of 262144 buckets.
              ->  Seq Scan on part p  (cost=0.00..432.76 rows=20000 width=37) (actual time=2.884..9.469 rows=20063 loops=1)
              ->  Hash  (cost=441.81..441.81 rows=80000 width=8) (actual time=182.802..182.803 rows=80252 loops=1)
                    Buckets: 262144  Batches: 1  Memory Usage: 5183kB
                    ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..441.81 rows=80000 width=8) (actual time=0.020..173.467 rows=80252 loops=1)
                          Hash Key: ps.ps_partkey
                          ->  Seq Scan on partsupp ps  (cost=0.00..438.61 rows=80000 width=8) (actual time=2.184..10.155 rows=80192 loops=1)
        ->  Hash  (cost=434.13..434.13 rows=2000 width=56) (actual time=11.205..11.205 rows=2000 loops=1)
              Buckets: 131072  Batches: 1  Memory Usage: 1197kB
              ->  Broadcast Motion 2:2  (slice3; segments: 2)  (cost=0.00..434.13 rows=2000 width=56) (actual time=9.360..10.533 rows=2000 loops=1)
                    ->  Seq Scan on supplier s  (cost=0.00..431.10 rows=1000 width=56) (actual time=2.363..2.624 rows=1002 loops=1)
Optimizer: GPORCA
Planning Time: 11.791 ms
  (slice0)    Executor memory: 66K bytes.
  (slice1)    Executor memory: 6691K bytes avg x 2 workers, 6691K bytes max (seg0).  Work_mem: 5183K bytes max.
  (slice2)    Executor memory: 263K bytes avg x 2 workers, 263K bytes max (seg0).
  (slice3)    Executor memory: 353K bytes avg x 2 workers, 353K bytes max (seg0).
Memory used:  128000kB
Execution Time: 1361.969 ms
```
   
### Query 4: Retrieve Comprehensive Customer Order and Line Item Details ###   
```
explain (analyze)
select c.c_custkey, 
       c.c_name, 
       c.c_address, 
       c.c_phone,
       o.o_orderkey,
       o.o_orderdate,
       l.l_linenumber,
       l.l_quantity,
       l.l_discount
from customer c 
     join orders o on o.o_custkey = c.c_custkey
     join lineitem l on l.l_orderkey = o.o_orderkey      
```
```
Hash Join  (cost=0.00..2487.12 rows=1199410 width=90) (actual time=711.298..10375.746 rows=1199969 loops=1)
  Hash Cond: (o.o_custkey = c.c_custkey)
  Extra Text: Hash chain length 1.1 avg, 4 max, using 26786 of 131072 buckets.
  ->  Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..1389.27 rows=1199410 width=29) (actual time=0.010..9177.500 rows=1199969 loops=1)
        ->  Hash Join  (cost=0.00..1233.10 rows=599705 width=29) (actual time=619.369..3706.730 rows=600656 loops=1)
              Hash Cond: (l.l_orderkey = o.o_orderkey)
              Extra Text: (seg1)   Hash chain length 1.3 avg, 6 max, using 114262 of 262144 buckets.
              ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..543.70 rows=599985 width=21) (actual time=0.016..1920.469 rows=600656 loops=1)
                    Hash Key: l.l_orderkey
                    ->  Dynamic Seq Scan on lineitem l  (cost=0.00..480.83 rows=599985 width=21) (actual time=2.122..455.360 rows=600209 loops=1)
                          Number of partitions to scan: 87 (out of 87)
                          Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
              ->  Hash  (cost=442.63..442.63 rows=150000 width=16) (actual time=619.095..619.096 rows=150135 loops=1)
                    Buckets: 262144  Batches: 1  Memory Usage: 9086kB
                    ->  Dynamic Seq Scan on orders o  (cost=0.00..442.63 rows=150000 width=16) (actual time=0.240..351.223 rows=150135 loops=1)
                          Number of partitions to scan: 87 (out of 87)
                          Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
  ->  Hash  (cost=443.13..443.13 rows=30000 width=65) (actual time=710.950..710.951 rows=30000 loops=1)
        Buckets: 131072  Batches: 1  Memory Usage: 3870kB
        ->  Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..443.13 rows=30000 width=65) (actual time=7.261..703.946 rows=30000 loops=1)
              ->  Seq Scan on customer c  (cost=0.00..432.56 rows=15000 width=65) (actual time=0.669..4.565 rows=15031 loops=1)
Optimizer: GPORCA
Planning Time: 26.365 ms
  (slice0)    Executor memory: 4082K bytes.  Work_mem: 3870K bytes max.
  (slice1)    Executor memory: 9669K bytes avg x 2 workers, 9669K bytes max (seg0).  Work_mem: 9086K bytes max.
  (slice2)    Executor memory: 796K bytes avg x 2 workers, 796K bytes max (seg1).
  (slice3)    Executor memory: 455K bytes avg x 2 workers, 458K bytes max (seg0).
Memory used:  128000kB
Execution Time: 10433.591 ms
```
   
### Query 5: Retrieve All Parts Supplied by a Specific Supplier with Supplier Details ###   
```
explain (analyze)
select s.s_suppkey,
       s.s_name,
       s.s_address,
       p.p_partkey,
       p.p_name
from partsupp ps
     join supplier s on s.s_suppkey = ps.ps_suppkey
     join part p on p.p_partkey = ps.ps_partkey
where s.s_suppkey = 1002
```
   
