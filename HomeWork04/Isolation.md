## Транзакционные запросы с разными уровнями изоляции ##   
   
### Уровень изоляции read committed ###   

1. В DBeaver открыл 2 сессии и перевел их в "Режим транзакций (ручной коммит)".
2. В первой сессии выполнил:
```
set transaction isolation level read committed;
insert into region values (5, 'SOUTH AMERICA', 'continent');
select * from region where r_name = 'SOUTH AMERICA'; -- <-- запрос вернул строку
```
3. Во второй сессии выполнил:
```
set transaction isolation level read committed;
select * from region where r_name = 'SOUTH AMERICA'; -- <-- запрос не вернул строку
```
4. В первой сессии выполнил:
```
commit;
```
5. Во второй сессии выполнил:
```
select * from region where r_name = 'SOUTH AMERICA'; -- <-- запрос вернул строку
```


### Выводы ###   
1. В режиме изоляции read committed запрос видит изменения других сессий, зафиксированные на момент начала запроса.
2. В режиме изоляции serializable запрос видит изменения других сессий, зафиксированные на момент начала транзакции.
