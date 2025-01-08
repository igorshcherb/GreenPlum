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

