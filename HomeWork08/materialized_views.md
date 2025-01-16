## Создание материализованных представленй ##

```
-- 1
-- drop materialized view q1;
create materialized view q1 as
select c.c_custkey, 
       c.c_name, 
       c.c_address, 
       c.c_phone,
       o.o_orderkey,
       o.o_orderdate,
       o.o_totalprice
from orders o
     join customer c on c.c_custkey = o.o_custkey
distributed by (c_custkey, o_orderkey);

refresh materialized view q1;
     
-- 2
-- drop materialized view q2;
create materialized view q2 as    
select o.o_orderkey,
       o.o_orderdate,
       l.l_linenumber,
       l.l_quantity,
       l.l_discount
from orders o
     join lineitem l on l.l_orderkey = o.o_orderkey
distributed by (o_orderkey, l_linenumber);

refresh materialized view q2;
    
-- 3
-- drop materialized view q3; 
create materialized view q3 as 
select s.s_suppkey,
       s.s_name,
       s.s_address,
       p.p_partkey,
       p.p_name
from partsupp ps
     join supplier s on s.s_suppkey = ps.ps_suppkey
     join part p on p.p_partkey = ps.ps_partkey
distributed by (s_suppkey, p_partkey);

refresh materialized view q3;
     
-- 4
-- drop materialized view q4;
create materialized view q4 as     
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
distributed by (c_custkey, o_orderkey, l_linenumber);

refresh materialized view q4;
     
-- 5
-- drop materialized view q5;
create materialized view q5 as     
select s.s_suppkey,
       s.s_name,
       s.s_address,
       p.p_partkey,
       p.p_name
from partsupp ps
     join supplier s on s.s_suppkey = ps.ps_suppkey
     join part p on p.p_partkey = ps.ps_partkey
distributed by (s_suppkey, p_partkey);

create unique index q5_suppkey on q5 (s_suppkey, p_partkey);

refresh materialized view q5;
```
