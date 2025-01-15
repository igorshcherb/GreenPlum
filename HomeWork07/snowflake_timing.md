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
   
