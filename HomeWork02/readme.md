### Домашнее задание № 2 ###   
## SQL в Greenplum ##   
1. Выполнил предварительную подготовку файлов:   
   * В файлы для загрузки с помощью DBeaver-а добавил первую строку, содержащую имена колонок, иначе DBeaver добавлял в таблицы столбцы с заголовками, соответствующими значениям из первой строки файла.   
   * Из файлов для загрузки с помощью COPY и GPFDIST убрал разделители столбцов из концов строк, иначе возникала ошибка:   
     ERROR: extra data after last expected column.   
   * Из всех файлов убрал последние пустые строки, иначе они воспринимались как строки таблицы со всеми значениями NULL.   
2. Создал БД test_datasets и таблицы в ней.   
3. Загрузил данные в таблицы:   
   3.1. В таблицу nation с помощью COPY:   
   ```
   psql -h 192.168.2.141 -U gpadmin -d test_datasets   
   \copy nation from 'c:\temp\nation.tbl' WITH (FORMAT csv, DELIMITER '|');
   ```   
   3.2. В таблицы region, lineitem, orders и partsupp с помощью GPFDIST:
```
cd /usr/lib/gpdb/bin/    
sudo /lib64/ld-linux-x86-64.so.2 ./gpfdist -d /var/load_files/ -p 8081 -l /home/gpadmin/log/gpfdist8081.log   
    
CREATE external TABLE region_ext ( R_REGIONKEY INTEGER, R_NAME CHAR(25),R_COMMENT text) 
  location ('gpfdist://192.168.2.142:8081/region.tbl') format 'CSV' (DELIMITER '|');
select * from region_ext; 
insert into region (select * from region_ext);

CREATE external TABLE lineitem_ext ( L_ORDERKEY BIGINT, L_PARTKEY INT, L_SUPPKEY INT, 
    L_LINENUMBER INTEGER, L_QUANTITY DECIMAL(15, 2), L_EXTENDEDPRICE DECIMAL(15, 2), 
    L_DISCOUNT DECIMAL(15, 2), L_TAX DECIMAL(15, 2), L_RETURNFLAG CHAR(1), L_LINESTATUS CHAR(1), 
    L_SHIPDATE DATE, L_COMMITDATE DATE, L_RECEIPTDATE DATE, L_SHIPINSTRUCT CHAR(25), 
    L_SHIPMODE CHAR(10), L_COMMENT text) 
  location ('gpfdist://192.168.2.142:8081/lineitem.tbl') format 'CSV' (DELIMITER '|');
insert into lineitem (select * from lineitem_ext);

CREATE external TABLE orders_ext ( O_ORDERKEY BIGINT, O_CUSTKEY INT, O_ORDERSTATUS CHAR(1), 
    O_TOTALPRICE DECIMAL(15, 2), O_ORDERDATE DATE, O_ORDERPRIORITY CHAR(15), O_CLERK CHAR(15), 
    O_SHIPPRIORITY INTEGER,O_COMMENT text) 
 location ('gpfdist://192.168.2.142:8081/orders.tbl') format 'CSV' (DELIMITER '|');
insert into orders (select * from orders_ext);

CREATE external TABLE partsupp_ext ( PS_PARTKEY INT, PS_SUPPKEY INT, PS_AVAILQTY INTEGER, 
    PS_SUPPLYCOST DECIMAL(15, 2),PS_COMMENT text) 
  location ('gpfdist://192.168.2.142:8081/partsupp.tbl') format 'CSV' (DELIMITER '|');
insert into partsupp (select * from partsupp_ext);
```   
   3.3. В таблицы customer, part и supplier с помощью DBeaver-а:   
        Разделитель столбцов: |   
        Использовать мультивставку значений: 500.   
            
4. Создал таблицу без партиций и заполнил ее данными:   
```
CREATE TABLE lineitem_wo_parti (
    L_ORDERKEY BIGINT,
    L_PARTKEY INT,
    L_SUPPKEY INT,
    L_LINENUMBER INTEGER,
    L_QUANTITY DECIMAL(15, 2),
    L_EXTENDEDPRICE DECIMAL(15, 2),
    L_DISCOUNT DECIMAL(15, 2),
    L_TAX DECIMAL(15, 2),
    L_RETURNFLAG CHAR(1),
    L_LINESTATUS CHAR(1),
    L_SHIPDATE DATE,
    L_COMMITDATE DATE,
    L_RECEIPTDATE DATE,
    L_SHIPINSTRUCT CHAR(25),
    L_SHIPMODE CHAR(10),
    L_COMMENT VARCHAR(44)
) WITH (
    appendonly = true,
    orientation = column,
    compresstype = ZSTD
) 
DISTRIBUTED BY (L_ORDERKEY, L_LINENUMBER);

insert into lineitem_wo_parti (select * from lineitem);
```   
5. Составил запрос на соединение 3 таблиц из датасета.
```
select count(*)
  from lineitem_wo_parti lit
  left join orders ord on ord.o_orderkey = lit.l_orderkey
  left join supplier supp on supp.s_suppkey = lit.l_suppkey
  where l_shipdate = date'1992-01-15'
    and l_shipmode = 'RAIL';
```
   Замерил время выполнения: 0,760s.   
   
6. Настроил партиционирование таблицы по списку и периоду.   
```
CREATE TABLE lineitem_parti (
    L_ORDERKEY BIGINT,
    L_PARTKEY INT,
    L_SUPPKEY INT,
    L_LINENUMBER INTEGER,
    L_QUANTITY DECIMAL(15, 2),
    L_EXTENDEDPRICE DECIMAL(15, 2),
    L_DISCOUNT DECIMAL(15, 2),
    L_TAX DECIMAL(15, 2),
    L_RETURNFLAG CHAR(1),
    L_LINESTATUS CHAR(1),
    L_SHIPDATE DATE,
    L_COMMITDATE DATE,
    L_RECEIPTDATE DATE,
    L_SHIPINSTRUCT CHAR(25),
    L_SHIPMODE CHAR(10),
    L_COMMENT VARCHAR(44)
) WITH (
    appendonly = true,
    orientation = column,
    compresstype = ZSTD
) 
DISTRIBUTED BY (L_ORDERKEY, L_LINENUMBER) 
PARTITION BY RANGE (L_SHIPDATE)
SUBPARTITION BY LIST(L_SHIPMODE)
SUBPARTITION TEMPLATE 
  (SUBPARTITION RAIL    VALUES('RAIL'),
   SUBPARTITION SHIP    VALUES('SHIP'),
   SUBPARTITION FOB     VALUES('FOB'),     
   SUBPARTITION TRUCK   VALUES('TRUCK'),    
   SUBPARTITION AIR     VALUES('AIR'),    
   SUBPARTITION REG_AIR VALUES('REG AIR'),  
   SUBPARTITION MAIL    VALUES('MAIL'),
   DEFAULT SUBPARTITION OTHER_SHIPMODES)
  (START('1992-01-01') INCLUSIVE END ('1998-12-31') INCLUSIVE EVERY (30), DEFAULT PARTITION OTHERS);  

insert into lineitem_parti (select * from lineitem); 
```
7. Составил запрос на соединение 3 таблиц из датасета с применением фильтров по партициям.
```
select count(*)
  from lineitem_parti lit
  left join orders ord on ord.o_orderkey = lit.l_orderkey
  left join supplier supp on supp.s_suppkey = lit.l_suppkey
  where l_shipdate = date'1992-01-15'
    and l_shipmode = 'RAIL';
```
   Замерил время выполнения: 0,225s.   
   Сравнил с результатом из первого пункта: время выполнения уменьшилось в 3,37 раза.   
   

        
        
