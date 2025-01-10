## Создание Single-Node кластера Cloudberry v1.5.1 (песочница) ##

Клонирование шаблона ВМ.   
   
Скачивание репозитория Cloudberry:   
```
git clone https://github.com/apache/cloudberry-bootcamp.git
```

Запуск установки:   
```
cd cloudberry-bootcamp/000-cbdb-sandbox
sudo chmod +x ./run.sh
sudo ./run.sh
```

Соединение с Docker-контейнером:   
```
sudo docker exec -it $(sudo docker ps -q) /bin/bash
```

Запуск psql в контейнере:   
```
$ psql
```

Проверка версии БД:   
```
select version();
```
```
 PostgreSQL 14.4 (Cloudberry Database 1.0.0 build dev) on x86_64-pc-linux-gnu, compiled by gcc (GCC) 11.5.0 20240719 (Red Hat 11.5.0-2), 64-bit compiled on Jan 8 2025 21:23:36 (with assert checking)
```

Проверка конфигурации кластера:   
```
select * from gp_segment_configuration order by dbid;
```
  
| dbid | content | role | preferred_role | mode | status | port  | hostname | address |            datadir             | warehouseid |
|------|---------|------|----------------|------|--------|-------|----------|---------|--------------------------------|-------------|
|    1 |      -1 | p    | p              | n    | u      |  5432 | mdw      | mdw     | /data0/database/master/gpseg-1 |           0 |
|    2 |       0 | p    | p              | s    | u      | 40000 | mdw      | mdw     | /data0/database/primary/gpseg0 |           0 |
|    3 |       1 | p    | p              | s    | u      | 40001 | mdw      | mdw     | /data0/database/primary/gpseg1 |           0 |
|    4 |       2 | p    | p              | s    | u      | 40002 | mdw      | mdw     | /data0/database/primary/gpseg2 |           0 |
|    5 |       0 | m    | m              | s    | u      | 50000 | mdw      | mdw     | /data0/database/mirror/gpseg0  |           0 |
|    6 |       1 | m    | m              | s    | u      | 50001 | mdw      | mdw     | /data0/database/mirror/gpseg1  |           0 |
|    7 |       2 | m    | m              | s    | u      | 50002 | mdw      | mdw     | /data0/database/mirror/gpseg2  |           0 |


