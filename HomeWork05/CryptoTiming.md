## Замеры времени шифрования и дешифрования данных ##
   
### Создание таблицы (100000 строк) ###
```
create table t2(id int8, txt text) distributed by (id);
insert into t2(id) (select s from generate_series(1, 100000) s);
```
### Время шифрования данных в таблице ###   
```
update t2 set txt = pgp_sym_encrypt(id::varchar, '$1$WLGc27a9$g5x0O./rAwreF0eEpuXDF.');
```
Время выполнения: 1m 50s.   
Обработка одной строки: 0.0011s   
   
### Время выполнения запросов ###
**Без дешифровки** данных:
```
explain analyze (select * from t2);
```
Execution Time: 356.501 ms   
   
**С дешифровкой** данных:
```
explain analyze (select id, pgp_sym_decrypt(txt::bytea, '$1$WLGc27a9$g5x0O./rAwreF0eEpuXDF.') as decrypt_txt from t1);
```
Execution Time: 107898.947 ms

**Выводы:**
1. Время шифрования данных составляет 0.0011s на одну строку.
2. Запрос с дешифровкой данных выполняется в 300 раз медленне, чем без дешифровки. Это можно объяснить слабым процессором на тестовом компьютере.
