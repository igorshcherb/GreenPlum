## Настройка конфигурационных файлов ##
Обычно для БД разработчиков и тестировщиков конфигурационные файлы настраивают следующим образом:
pg_hba.conf:
```
host all all 0.0.0.0/0 trust
```
postgresql.auto.conf:
```
listen_addresses = '*'
```