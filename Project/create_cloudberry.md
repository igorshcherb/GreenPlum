## Создание Single-Node кластера Cloudberry v1.5.1 ##

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

