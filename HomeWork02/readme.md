## Домашнее задание № 2 ##   
# SQL в Greenplum #   
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
4. Составил запрос на соединение 4 таблиц из датасета.    
   Замерил время выполнения.    
5. Настроил партиционирование таблиц по списку и периоду.   
6. Составил запрос на соединение 4 таблиц из датасета с применением фильтров по партициям.    
   Замерил время выполнения.   
   Сравнил с результатом из первого пункта.   
   

        
        
