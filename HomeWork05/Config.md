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
Но возможны более жесткие варианты, например:   
   
pg_hba.conf:   
```
host adb gp_admin 192.168.2.0/24 md5
```
postgresql.auto.conf:   
```
listen_addresses = '192.168.2.141, 192.168.2.70, localhost'
```
