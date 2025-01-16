## Замеры производительности ##

```
explain analyze select * from q1;
```
```
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..578.70 rows=300000 width=85) (actual time=4.667..5203.343 rows=300000 loops=1)
  ->  Seq Scan on q1  (cost=0.00..440.49 rows=150000 width=85) (actual time=0.083..21.645 rows=150590 loops=1)
Optimizer: GPORCA
Planning Time: 3.748 ms
  (slice0)    Executor memory: 25K bytes.
  (slice1)    Executor memory: 43K bytes avg x 2 workers, 43K bytes max (seg0).
Memory used:  128000kB
Execution Time: 5223.812 ms
```
```
explain analyze select * from q2;
```
```
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..611.75 rows=1199969 width=25) (actual time=0.821..7219.757 rows=1199969 loops=1)
  ->  Seq Scan on q2  (cost=0.00..449.15 rows=599985 width=25) (actual time=0.118..162.451 rows=600209 loops=1)
Optimizer: GPORCA
Planning Time: 2.196 ms
  (slice0)    Executor memory: 29K bytes.
  (slice1)    Executor memory: 43K bytes avg x 2 workers, 43K bytes max (seg0).
Memory used:  128000kB
Execution Time: 7269.774 ms
```
```
explain analyze select * from q3;
```
```
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..517.06 rows=160000 width=93) (actual time=2.737..2731.787 rows=160000 loops=1)
  ->  Seq Scan on q3  (cost=0.00..436.41 rows=80000 width=93) (actual time=0.044..15.463 rows=80105 loops=1)
Optimizer: GPORCA
Planning Time: 2.947 ms
  (slice0)    Executor memory: 24K bytes.
  (slice1)    Executor memory: 55K bytes avg x 2 workers, 55K bytes max (seg0).
Memory used:  128000kB
Execution Time: 2739.756 ms
```
```
explain analyze select * from q4;
```
```
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..1055.94 rows=1199969 width=90) (actual time=5.355..20512.617 rows=1199969 loops=1)
  ->  Seq Scan on q4  (cost=0.00..470.60 rows=599985 width=90) (actual time=0.982..336.976 rows=600632 loops=1)
Optimizer: GPORCA
Planning Time: 3.546 ms
  (slice0)    Executor memory: 28K bytes.
  (slice1)    Executor memory: 62K bytes avg x 2 workers, 62K bytes max (seg0).
Memory used:  128000kB
Execution Time: 20566.323 ms
```
```
explain analyze select * from q5;
```
```
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..517.06 rows=160000 width=93) (actual time=3.075..2553.160 rows=160000 loops=1)
  ->  Seq Scan on q5  (cost=0.00..436.41 rows=80000 width=93) (actual time=0.031..9.850 rows=80105 loops=1)
Optimizer: GPORCA
Planning Time: 2.248 ms
  (slice0)    Executor memory: 24K bytes.
  (slice1)    Executor memory: 55K bytes avg x 2 workers, 55K bytes max (seg0).
Memory used:  128000kB
Execution Time: 2566.582 ms
```
