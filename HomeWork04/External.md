## Настройка и тестирование внешних таблиц для загрузки данных ##   
   
### 1. Таблицы для загрузки данных из файлов ###   

В предыдущих домашних заданих были созданы внешние таблицы для загрузки данных из файлов с помощью gpfdist.

### 2. Таблица для загрузки данных из БД Postgres ###   

Создание внешней таблицы для загрузки данных из БД Postgres с помощью pxf.
```
create external table contract_types_pxf(id integer, type_name varchar(100))   
     location ('pxf://contract_types?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.32:5432/postgres&USER=postgres&PASS=p')   
     format 'CUSTOM' (FORMATTER='pxfwritable_import');
```
Загрузка данных:
```
insert into contract_types (select * from contract_types_pxf); 
```
   

