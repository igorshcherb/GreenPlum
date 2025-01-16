## Запросы с использованием оконных функций ##

**Заказы покупателей с указанием средней суммы заказов этого покупателя и общей суммы**
```
select c.c_custkey, 
       c.c_name,
       o.o_orderkey,
       o.o_totalprice,
       (avg(o.o_totalprice) over (partition by c.c_custkey))::decimal(15, 2) avg_totalprice,
       sum(o.o_totalprice) over (partition by c.c_custkey) sum_totalprice
from orders o
     join customer c on c.c_custkey = o.o_custkey
limit 10;
```
   
|c_custkey|c_name|o_orderkey|o_totalprice|avg_totalprice|sum_totalprice|
|---------|------|----------|------------|--------------|--------------|
|2|Customer#000000002|816323|254784.09|189806.08|1518448.61|
|2|Customer#000000002|36422|258009.94|189806.08|1518448.61|
|2|Customer#000000002|859108|104371.91|189806.08|1518448.61|
|2|Customer#000000002|883557|53517.87|189806.08|1518448.61|
|2|Customer#000000002|1073670|76519.01|189806.08|1518448.61|
|2|Customer#000000002|895172|228148.80|189806.08|1518448.61|
|2|Customer#000000002|135943|290986.92|189806.08|1518448.61|
|2|Customer#000000002|916775|252110.07|189806.08|1518448.61|
|4|Customer#000000004|100064|58885.07|143276.70|2722257.32|
|4|Customer#000000004|9154|307247.26|143276.70|2722257.32|
   
**Строки заказов в порядке количества товара**
```
select o.o_orderkey,
       o.o_orderdate,
       l.l_linenumber,
       l.l_quantity,
       rank() OVER (PARTITION BY o.o_orderkey ORDER BY l.l_quantity DESC) rank_quantity
from orders o
     join lineitem l on l.l_orderkey = o.o_orderkey
order by o.o_orderkey, rank_quantity
limit 10
```

|o_orderkey|o_orderdate|l_linenumber|l_quantity|rank_quantity|
|----------|-----------|------------|----------|-------------|
|1|1996-01-02|2|36.00|1|
|1|1996-01-02|6|32.00|2|
|1|1996-01-02|4|28.00|3|
|1|1996-01-02|5|24.00|4|
|1|1996-01-02|1|17.00|5|
|1|1996-01-02|3|8.00|6|
|2|1996-12-01|1|38.00|1|
|3|1993-10-14|2|49.00|1|
|3|1993-10-14|1|45.00|2|
|3|1993-10-14|5|28.00|3|
