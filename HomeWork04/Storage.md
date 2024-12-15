## Настройка параметров хранения таблиц ##

### 1. Типы хранения ###   

В предыдущих домашних заданиях были созданы appendoptimized-таблицы с колоночной ориентацией и сжатием. Это основной тип хранения.   
   
Если в запросах используются все колонки таблицы, то для таблицы можно выбрать строчную ориентацию, например:   
```
CREATE TABLE region_2 (
    R_REGIONKEY INTEGER,
    R_NAME VARCHAR(25)
) WITH (appendoptimized = true, orientation = row) 
DISTRIBUTED BY (R_REGIONKEY);
```

### 2. Типы таблиц ### 

Кроме обычных таблиц, существуют temp, unlogged и external таблицы.   
   
Temp-таблицы существуют в рамках одной сессии или транзакции и могут быть использованы, в частности, для хранения промежуточных результатов вычислений, например:   
```
CREATE TEMPORARY TABLE orders_selected (
    O_ORDERKEY BIGINT,
    O_CUSTKEY INT,
    O_ORDERSTATUS CHAR(1),
    O_TOTALPRICE DECIMAL(15, 2),
    O_ORDERDATE DATE,
    O_ORDERPRIORITY CHAR(15),
    O_CLERK CHAR(15),
    O_SHIPPRIORITY INTEGER,
    O_COMMENT VARCHAR(79)
) WITH (
    appendonly = true,
    orientation = column,
    compresstype = ZSTD
) 
DISTRIBUTED BY (O_ORDERKEY);
```

Unlogged-таблицы на реплицируются на mirror-сегменты. В них можно хранить данные, которые не страшно потерять в случае сбоя.
Например, таблица для хранения промежуточных результатов вычислений, которая может потребоваться в нескольких сессиях:







