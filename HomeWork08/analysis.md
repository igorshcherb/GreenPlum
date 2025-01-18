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
   
**Скидки по заказу, минимальная и максимальная скидка по поставщику**
```
select c.c_custkey, 
       c.c_name, 
       o.o_orderkey,
       o.o_orderdate,
       l.l_discount,
       min(l.l_discount) over (partition by l.l_suppkey) min_discount,
       max(l.l_discount) over (partition by l.l_suppkey) max_discount
from customer c 
     join orders o on o.o_custkey = c.c_custkey
     join lineitem l on l.l_orderkey = o.o_orderkey
limit 10;
```
   
|c_custkey|c_name|o_orderkey|o_orderdate|l_discount|min_discount|max_discount|
|---------|------|----------|-----------|----------|------------|------------|
|29692|Customer#000029692|374535|1994-06-03|0.02|0.00|0.10|
|22732|Customer#000022732|78530|1996-09-04|0.08|0.00|0.10|
|3742|Customer#000003742|490369|1994-12-14|0.01|0.00|0.10|
|12871|Customer#000012871|786148|1995-09-12|0.07|0.00|0.10|
|23755|Customer#000023755|927683|1997-04-08|0.00|0.00|0.10|
|24629|Customer#000024629|686375|1992-05-19|0.06|0.00|0.10|
|17080|Customer#000017080|646629|1992-11-04|0.09|0.00|0.10|
|17035|Customer#000017035|838759|1992-12-10|0.06|0.00|0.10|
|23251|Customer#000023251|119427|1992-07-22|0.00|0.00|0.10|
|5089|Customer#000005089|547970|1998-03-11|0.07|0.00|0.10|

**Суммы заказов по месяцам**

```   
select to_char(o_orderdate, 'yyyy-mm') mnth,
       to_char(sum(o_totalprice), '999999999999D00') tot_sum
from   orders
group by to_char(o_orderdate, 'yyyy-mm')
order by 1
limit 10;  
```

|mnth|tot_sum|
|----|-------|
|1992-01|    560265768,45|
|1992-02|    525668085,35|
|1992-03|    556487879,10|
|1992-04|    538676572,66|
|1992-05|    534093869,05|
|1992-06|    543755610,48|
|1992-07|    560873309,98|
|1992-08|    557718823,36|
|1992-09|    526647815,62|
|1992-10|    568315847,02|

**Суммы заказов с указанием минимальной и максимальной суммы заказа за месяц**

```   
with lst as (
  select o_custkey custkey, 
         to_char(o_orderdate, 'yyyy-mm') mnth,
         o_totalprice totalprice
  from   orders
  )
select custkey,
       mnth,
       totalprice,
       first_value(totalprice) over(partition by (custkey, mnth) order by totalprice 
         rows between unbounded preceding and unbounded following) min_totalprice,
       last_value(totalprice) over(partition by (custkey, mnth) order by totalprice 
         rows between unbounded preceding and unbounded following) max_totalprice
from   lst
order by 1, 2, 3
limit 10;
```

|custkey|mnth|totalprice|min_totalprice|max_totalprice|
|-------|----|----------|--------------|--------------|
|1|1992-04|80996.13|80996.13|271888.65|
|1|1992-04|271888.65|80996.13|271888.65|
|1|1994-12|24322.31|24322.31|24322.31|
|1|1995-03|211025.78|211025.78|211025.78|
|1|1995-07|253717.07|253717.07|253717.07|
|1|1995-11|245942.90|245942.90|245942.90|
|1|1996-05|69254.79|69254.79|69254.79|
|1|1996-06|139753.75|139753.75|139753.75|
|1|1996-12|14436.36|14436.36|61491.18|
|1|1996-12|61491.18|14436.36|61491.18|


