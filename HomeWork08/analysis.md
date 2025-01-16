## Анализ данных с помощью аналитических функций ##

**Доля каждого товара заказа в общей сумме всех заказов данного поставщика**
```
select c.c_custkey, 
       c.c_name, 
       o.o_orderkey,
       o.o_orderdate,
       l.l_quantity,
       (l.l_quantity / sum(l_quantity) over (partition by l.l_suppkey))::decimal(10,5) quantity_fraction
from customer c 
     join orders o on o.o_custkey = c.c_custkey
     join lineitem l on l.l_orderkey = o.o_orderkey
limit 10;
```

|c_custkey|c_name|o_orderkey|o_orderdate|l_quantity|quantity_fraction|
|---------|------|----------|-----------|----------|-----------------|
|25147|Customer#000025147|7397|1994-05-20|9.00|0.00058|
|24556|Customer#000024556|891590|1992-12-18|9.00|0.00058|
|851|Customer#000000851|1039618|1996-10-05|36.00|0.00232|
|9331|Customer#000009331|1122050|1997-03-03|48.00|0.00309|
|8377|Customer#000008377|684864|1997-11-07|43.00|0.00277|
|9787|Customer#000009787|913315|1993-01-14|2.00|0.00013|
|3374|Customer#000003374|369635|1992-07-07|21.00|0.00135|
|22483|Customer#000022483|1128032|1997-09-19|9.00|0.00058|
|21565|Customer#000021565|600645|1998-03-18|46.00|0.00296|
|20212|Customer#000020212|1145349|1997-06-11|24.00|0.00154|

