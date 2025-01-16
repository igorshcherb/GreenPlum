## Замеры производительности нормализованной модели данных ##
 
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
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..1105.98 rows=300000 width=85) (actual time=94.915..10193.509 rows=300000 loops=1)
  ->  Hash Join  (cost=0.00..991.49 rows=150000 width=85) (actual time=94.881..383.235 rows=151208 loops=1)
        Hash Cond: (o.o_custkey = c.c_custkey)
        Extra Text: (seg1)   Hash chain length 1.1 avg, 3 max, using 14175 of 131072 buckets.
        ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..460.60 rows=150000 width=24) (actual time=0.009..142.992 rows=151208 loops=1)
              Hash Key: o.o_custkey
              ->  Dynamic Seq Scan on orders o  (cost=0.00..442.63 rows=150000 width=24) (actual time=6.399..581.851 rows=150135 loops=1)
                    Number of partitions to scan: 87 (out of 87)
                    Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
        ->  Hash  (cost=432.56..432.56 rows=15000 width=65) (actual time=91.850..91.851 rows=15031 loops=1)
              Buckets: 131072  Batches: 1  Memory Usage: 2450kB
              ->  Seq Scan on customer c  (cost=0.00..432.56 rows=15000 width=65) (actual time=84.086..87.001 rows=15031 loops=1)
Optimizer: GPORCA
Planning Time: 3.374 ms
  (slice0)    Executor memory: 47K bytes.
  (slice1)    Executor memory: 2971K bytes avg x 2 workers, 2983K bytes max (seg1).  Work_mem: 2450K bytes max.
  (slice2)    Executor memory: 710K bytes avg x 2 workers, 710K bytes max (seg1).
Memory used:  128000kB
Execution Time: 10208.614 ms
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
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..1344.60 rows=1199410 width=25) (actual time=305.392..11686.988 rows=1199969 loops=1)
  ->  Hash Join  (cost=0.00..1209.97 rows=599705 width=25) (actual time=308.411..2105.379 rows=600656 loops=1)
        Hash Cond: (l.l_orderkey = o.o_orderkey)
        Extra Text: (seg1)   Hash chain length 1.2 avg, 6 max, using 130535 of 524288 buckets.
        ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..543.70 rows=599985 width=21) (actual time=0.009..1073.687 rows=600656 loops=1)
              Hash Key: l.l_orderkey
              ->  Dynamic Seq Scan on lineitem l  (cost=0.00..480.83 rows=599985 width=21) (actual time=1.463..320.903 rows=600209 loops=1)
                    Number of partitions to scan: 87 (out of 87)
                    Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
        ->  Hash  (cost=442.63..442.63 rows=150000 width=12) (actual time=306.695..306.696 rows=150135 loops=1)
              Buckets: 524288  Batches: 1  Memory Usage: 10548kB
              ->  Dynamic Seq Scan on orders o  (cost=0.00..442.63 rows=150000 width=12) (actual time=0.473..196.825 rows=150135 loops=1)
                    Number of partitions to scan: 87 (out of 87)
                    Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
Optimizer: GPORCA
Planning Time: 4.717 ms
  (slice0)    Executor memory: 51K bytes.
  (slice1)    Executor memory: 11596K bytes avg x 2 workers, 11596K bytes max (seg0).  Work_mem: 10548K bytes max.
  (slice2)    Executor memory: 796K bytes avg x 2 workers, 796K bytes max (seg1).
Memory used:  128000kB
Execution Time: 11733.645 ms
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
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..1459.19 rows=159590 width=93) (actual time=165.197..3276.259 rows=160000 loops=1)
  ->  Hash Join  (cost=0.00..1392.56 rows=79795 width=93) (actual time=163.418..254.331 rows=80252 loops=1)
        Hash Cond: (ps.ps_suppkey = s.s_suppkey)
        Extra Text: (seg1)   Hash chain length 1.0 avg, 2 max, using 1988 of 131072 buckets.
        ->  Hash Join  (cost=0.00..913.85 rows=79795 width=41) (actual time=144.248..163.859 rows=80252 loops=1)
              Hash Cond: (p.p_partkey = ps.ps_partkey)
              Extra Text: (seg1)   Hash chain length 4.2 avg, 12 max, using 19248 of 262144 buckets.
              ->  Seq Scan on part p  (cost=0.00..432.76 rows=20000 width=37) (actual time=0.196..3.730 rows=20063 loops=1)
              ->  Hash  (cost=441.81..441.81 rows=80000 width=8) (actual time=142.856..142.857 rows=80252 loops=1)
                    Buckets: 262144  Batches: 1  Memory Usage: 5183kB
                    ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..441.81 rows=80000 width=8) (actual time=0.014..115.415 rows=80252 loops=1)
                          Hash Key: ps.ps_partkey
                          ->  Seq Scan on partsupp ps  (cost=0.00..438.61 rows=80000 width=8) (actual time=0.289..6.233 rows=80192 loops=1)
        ->  Hash  (cost=434.13..434.13 rows=2000 width=56) (actual time=19.564..19.564 rows=2000 loops=1)
              Buckets: 131072  Batches: 1  Memory Usage: 1197kB
              ->  Broadcast Motion 2:2  (slice3; segments: 2)  (cost=0.00..434.13 rows=2000 width=56) (actual time=14.910..19.164 rows=2000 loops=1)
                    ->  Seq Scan on supplier s  (cost=0.00..431.10 rows=1000 width=56) (actual time=0.244..0.317 rows=1002 loops=1)
Optimizer: GPORCA
Planning Time: 8.425 ms
  (slice0)    Executor memory: 66K bytes.
  (slice1)    Executor memory: 6691K bytes avg x 2 workers, 6691K bytes max (seg0).  Work_mem: 5183K bytes max.
  (slice2)    Executor memory: 263K bytes avg x 2 workers, 263K bytes max (seg0).
  (slice3)    Executor memory: 353K bytes avg x 2 workers, 353K bytes max (seg0).
Memory used:  128000kB
Execution Time: 3311.731 ms
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
Hash Join  (cost=0.00..2487.12 rows=1199410 width=90) (actual time=1737.606..37487.160 rows=1199969 loops=1)
  Hash Cond: (o.o_custkey = c.c_custkey)
  Extra Text: Hash chain length 1.1 avg, 4 max, using 26786 of 131072 buckets.
  ->  Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..1389.27 rows=1199410 width=29) (actual time=0.016..35109.829 rows=1199969 loops=1)
        ->  Hash Join  (cost=0.00..1233.10 rows=599705 width=29) (actual time=1529.890..14821.376 rows=600656 loops=1)
              Hash Cond: (l.l_orderkey = o.o_orderkey)
              Extra Text: (seg1)   Hash chain length 1.3 avg, 6 max, using 114262 of 262144 buckets.
              ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..543.70 rows=599985 width=21) (actual time=0.076..12135.383 rows=600656 loops=1)
                    Hash Key: l.l_orderkey
                    ->  Dynamic Seq Scan on lineitem l  (cost=0.00..480.83 rows=599985 width=21) (actual time=7.309..1458.600 rows=600209 loops=1)
                          Number of partitions to scan: 87 (out of 87)
                          Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
              ->  Hash  (cost=442.63..442.63 rows=150000 width=16) (actual time=1527.187..1527.188 rows=150135 loops=1)
                    Buckets: 262144  Batches: 1  Memory Usage: 9086kB
                    ->  Dynamic Seq Scan on orders o  (cost=0.00..442.63 rows=150000 width=16) (actual time=1.024..1224.684 rows=150135 loops=1)
                          Number of partitions to scan: 87 (out of 87)
                          Partitions scanned:  Avg 87.0 x 2 workers.  Max 87 parts (seg0).
  ->  Hash  (cost=443.13..443.13 rows=30000 width=65) (actual time=1736.574..1736.574 rows=30000 loops=1)
        Buckets: 131072  Batches: 1  Memory Usage: 3870kB
        ->  Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..443.13 rows=30000 width=65) (actual time=131.251..1714.009 rows=30000 loops=1)
              ->  Seq Scan on customer c  (cost=0.00..432.56 rows=15000 width=65) (actual time=0.401..11.258 rows=15031 loops=1)
Optimizer: GPORCA
Planning Time: 114.675 ms
  (slice0)    Executor memory: 4082K bytes.  Work_mem: 3870K bytes max.
  (slice1)    Executor memory: 9675K bytes avg x 2 workers, 9675K bytes max (seg0).  Work_mem: 9086K bytes max.
  (slice2)    Executor memory: 796K bytes avg x 2 workers, 796K bytes max (seg1).
  (slice3)    Executor memory: 455K bytes avg x 2 workers, 458K bytes max (seg0).
Memory used:  128000kB
Execution Time: 37584.546 ms
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
```
Hash Join  (cost=0.00..1310.51 rows=80 width=93) (actual time=18.340..21.358 rows=80 loops=1)
  Hash Cond: (ps.ps_suppkey = s.s_suppkey)
  Extra Text: Hash chain length 1.0 avg, 1 max, using 1 of 131072 buckets.
  ->  Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..879.34 rows=80 width=41) (actual time=8.996..11.863 rows=80 loops=1)
        ->  Hash Join  (cost=0.00..879.33 rows=40 width=41) (actual time=16.426..19.883 rows=45 loops=1)
              Hash Cond: (p.p_partkey = ps.ps_partkey)
              Extra Text: (seg1)   Hash chain length 1.0 avg, 1 max, using 45 of 262144 buckets.
              ->  Seq Scan on part p  (cost=0.00..432.76 rows=20000 width=37) (actual time=0.479..1.665 rows=20063 loops=1)
              ->  Hash  (cost=441.25..441.25 rows=40 width=8) (actual time=15.806..15.806 rows=45 loops=1)
                    Buckets: 262144  Batches: 1  Memory Usage: 2050kB
                    ->  Redistribute Motion 2:2  (slice2; segments: 2)  (cost=0.00..441.25 rows=40 width=8) (actual time=9.643..15.723 rows=45 loops=1)
                          Hash Key: ps.ps_partkey
                          ->  Seq Scan on partsupp ps  (cost=0.00..441.24 rows=40 width=8) (actual time=0.389..2.155 rows=42 loops=1)
                                Filter: (ps_suppkey = 1002)
                                Rows Removed by Filter: 79766
  ->  Hash  (cost=431.13..431.13 rows=1 width=56) (actual time=9.172..9.173 rows=1 loops=1)
        Buckets: 131072  Batches: 1  Memory Usage: 1025kB
        ->  Gather Motion 2:1  (slice3; segments: 2)  (cost=0.00..431.13 rows=1 width=56) (actual time=9.166..9.167 rows=1 loops=1)
              ->  Seq Scan on supplier s  (cost=0.00..431.13 rows=1 width=56) (actual time=0.497..0.515 rows=1 loops=1)
                    Filter: (s_suppkey = 1002)
                    Rows Removed by Filter: 997
Optimizer: GPORCA
Planning Time: 7.765 ms
  (slice0)    Executor memory: 1117K bytes.  Work_mem: 1025K bytes max.
  (slice1)    Executor memory: 2347K bytes avg x 2 workers, 2347K bytes max (seg1).  Work_mem: 2050K bytes max.
  (slice2)    Executor memory: 256K bytes avg x 2 workers, 256K bytes max (seg0).
  (slice3)    Executor memory: 354K bytes avg x 2 workers, 354K bytes max (seg0).
Memory used:  128000kB
Execution Time: 36.623 ms
```
      
