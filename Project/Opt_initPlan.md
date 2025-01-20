## В PostgreSQL 17 запросы, в планах выполнения которых есть initPlan, могут использовать параллельные процессы (workers) для выполнения initPlan ##
   
**Запрос:**
```
explain (costs off) select flight_id from ticket_flights where flight_id = (select 65405);
```

**В PostgreSQL 17 в плане выполнения этого запроса есть initPlan:**
```
Gather
  Workers Planned: 2
  InitPlan 1
    ->  Result
  ->  Parallel Seq Scan on ticket_flights
        Filter: (flight_id = (InitPlan 1).col1)
```
**Для выполнения запроса в PostgreSQL 17 используются параллельные процессы (workers).**
   
**План этого запроса в Arenadata DB 7.2:**
```
set optimizer = on;
```
```
Gather Motion 4:1  (slice1; segments: 4)
  ->  Hash Join
        Hash Cond: (flight_id = (65405))
        ->  Seq Scan on ticket_flights
        ->  Hash
              ->  Result
Optimizer: GPORCA
```
```
set optimizer = off;
```
```
Gather Motion 4:1  (slice1; segments: 4)
  InitPlan 1 (returns $0)  (slice2)
    ->  Result
  ->  Seq Scan on ticket_flights
        Filter: (flight_id = $0)
Optimizer: Postgres-based planner
```
   
**Вывод: в Arenadata степень распараллеливания выше - по количеству сегментов кластера.**


