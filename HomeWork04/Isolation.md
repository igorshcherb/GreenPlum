## Транзакционные запросы с разными уровнями изоляции ##   
   
### Уровень изоляции read committed (по умолчанию) ###   

1. В DBeaver открыл 2 сессии и перевел их в "Режим транзакций (ручной коммит)".
2. В первой сессии выполнил:
```
set transaction isolation level read committed;
insert into region values (5, 'SOUTH AMERICA', 'continent');
select * from region where r_name = 'SOUTH AMERICA';
```
Запрос вернул строку.
   
3. Во второй сессии выполнил:
```
set transaction isolation level read committed;
select * from region where r_name = 'SOUTH AMERICA';
```
Запрос не вернул строку.
   
4. В первой сессии выполнил:   
```
commit;
```
   
5. Во второй сессии выполнил:   
```
select * from region where r_name = 'SOUTH AMERICA';
```
Запрос вернул строку.   

   
### Уровень изоляции serializable ###   

1. В первой сессии:
   
Удалил строку:   
```
delete from region where r_name = 'SOUTH AMERICA';
commit;
```
Открыл новую транзакцию и добавил строку:   
```
set transaction isolation level serializable;
insert into region values (5, 'SOUTH AMERICA', 'continent');
select * from region where r_name = 'SOUTH AMERICA';
```
2. Во второй сессии выполнил:
```
set transaction isolation level serializable;
select * from region where r_name = 'SOUTH AMERICA';
```
Запрос не вернул строку.
   
4. В первой сессии выполнил:   
```
commit;
```
   
5. Во второй сессии выполнил:   
```
select * from region where r_name = 'SOUTH AMERICA';
```
Запрос не вернул строку. 
   
6. Во второй сессии открыл новую транзакцию и выполнил запрос:   
```
set transaction isolation level serializable;
select * from region where r_name = 'SOUTH AMERICA';
```
Запрос вернул строку.

### Выводы ###   
Анализ поведения системы при конкурентных операциях показывает, что:
1. Запрос видит изменения, сделанные в той же транзакции, даже если они еще не были зафиксированы.
2. В режиме изоляции read committed запрос видит изменения других сессий, зафиксированные на момент начала запроса.
3. В режиме изоляции serializable запрос видит изменения других сессий, зафиксированные на момент начала транзакции.
