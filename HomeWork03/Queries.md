## Запросы ##

**Примечание.** Датасеты в этом и предыдущем домашнем задании проще, чем те, запросы по которым были показаны на занятии.   
Поэтому в этих запросах отсутствуют:   
* Поля LoadDate и конструкции вида "WHERE LoadDate = (select max(LoadDate) from ...)"   
* Поля HashKey и соединения по ним.   
* Таблицы Sattelite...   
   
### Query 1: Retrieve Customer Orders with Order and Customer Details ###   
```
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
### Query 2: Retrieve Detailed Order Information with Line Items ###   
```     
select o.o_orderkey,
       o.o_orderdate,
       l.l_linenumber,
       l.l_quantity,
       l.l_discount
from orders o
     join lineitem l on l.l_orderkey = o.o_orderkey 
```     
### Query 3: Retrieve Supplier and Part Information for Each Supplier-Part Relationship ###   
```     
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
   
