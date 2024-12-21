## Тестирование производительности при изменении параметров памяти ##   

### Пользователь для тестирования производительности ###
Для тестирования производительности с разными ресурсными группами был создан пользователь gpuser, аналогичный пользователь gpadmin.   
[Скрипт для сознания пользователя gpuser](gpuser.sql).

Пользователю назначается ресурсная группа для "тяжелых" запросов:
```
alter role gpuser resource group rgroup1;
```
Выполняется запрос:
```
select count(*)
from customer c 
     join orders o on o.o_custkey = c.c_custkey
     join lineitem l on l.l_orderkey = o.o_orderkey
```
Время выполнения запроса: 1 сек.

Выполняется очень тяжелый запрос (декартово произведение):
```
select count(*) from lineitem x, lineitem y;
```
Выдается сообщение об ошибке:   
SQL Error [53000]: ERROR: insufficient memory reserved for statement   
                      
Пользователю назначается ресурсная группа для "легких" запросов:
```
alter role gpuser resource group rgroup2;
```
Выполняется тот же запрос.   
Время выполнения запроса: 12 сек.

