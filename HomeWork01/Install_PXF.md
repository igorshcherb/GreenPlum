## Установка PXF - Platform Extension Framework ##   
В Arenadata Cluster Manager:   
1. В кластер ADB Cluster добавить сервис PXF.   
2. Запустить сервис ADB.   
3. На сервисе PXF выполнить действия (actions): Install, Start.
   
В БД Postgres (у меня она установлена в хостовой ОС - Windows) создать и заполнить таблицу:   
```   
   create table t1 (c1 integer, c2 integer, p integer);   
   insert into t1 (c1, c2, p) (select s, s, s from generate_series(1, 1000, 1) s);   
```
В БД ADB создать внешнюю таблицу:   
```   
   create external table pxf_jdbc_postgres_t1(c1 integer, c2 integer, p integer)   
     location ('pxf://t1?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.32:5432/postgres&USER=postgres&PASS=p')   
     format 'CUSTOM' (FORMATTER='pxfwritable_import');   
```   
В БД ADB с помощью запроса к внешней таблице получить данные из БД Postgres:   
   select * from pxf_jdbc_postgres_t1;   
