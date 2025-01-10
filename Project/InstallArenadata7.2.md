## Установка Arenadata 7.2 ##   

### Установка ADCM ###   

Запуск Docker-а:   
$ sudo systemctl start docker   

Включение Docker-а в качестве системного сервиса:   
$ sudo systemctl enable docker   

Добавление пользователя в группу docker:   
$ sudo usermod -a -G docker $USER   

Скачивание Docker-образа ADCM из Arenadata Docker Registry (version = 2.4):   
$ sudo docker pull hub.arenadata.io/adcm/adcm:2.4   

Создание Docker-контейнера на основе загруженного образа:   
$ sudo docker create --name adcm -p 8000:8000 -v /opt/adcm:/adcm/data hub.arenadata.io/adcm/adcm:2.4   

Запуск ADCM:   
$ sudo docker start adcm   

Настройка автозапуска ADCM (в случае непредвиденных ошибок):   
$ sudo docker update --restart=on-failure adcm   

Проверка статуса Docker-контейнера:   
$ sudo docker container ls   
В столбце STATUS должно выводится значение Up.   

Проверка доступности порта 8000:   
$ sudo netstat -ntpl | grep 8000   

Проверка URL-соединения:   
$ curl http://localhost:8000   

Обращение к ADCM из хостовой ОС (Windows):   
http://192.168.2.140:8000/   
admin/admin   

Установка URL ADCM:   
Settings -> Global Options -> ADCM’s URL: http://192.168.2.140:8000/   

### Подготовка хостов (хостпровайдер SSH) ###   

Загрузка бандла SSH:   
Сайт: https://network.arenadata.io/   
Продукт: Arenadata Cluster Manager   
SSH Common Bundle от версии ADCM 2.0   
Файл: adcm_host_ssh_v2.11-1_community.tgz   
Bundles -> Upload bundle   

Создание хостпровайдера на базе загруженного бандла:   
Hostproviders -> Create provider   
Type: SSH Common   
Version: 2.1-1   
Name: SSH   

Настройка хостпровайдера:   
Hostproviders -> SSH   
Перевести в активное состояние переключатель Show advanced.   
Задать значения параметров: Ssh keys, Password, SSH private key.   
   
Создание хостов:   
Hosts -> Create host   
Hostprovider: SSH   
Name: ADCM (master, segment-1, segment-2)   
   
Задание параметров хоста:   
Параметры: Password, SSH private key, Connection address (IP адрес ВМ).   
   
Операция с хостом:   
Check connection   
   
### Создание и настройка кластера ###   

Загрузка бандла ADB:   
Сайт: https://network.arenadata.io/   
Продукт: Arenadata DB   
Версия ADCM: 2.4   
Файл: adcm_cluster_adb_v7.2.0_arenadata1_b1-1_community.tgz   

Создание кластера:   
Clusters -> Create cluster   
Product: ADB   
Product version: 7.2.0_arenadata1_b1-1 (community)   
Cluster name: ADB Cluster   

Добавление сервиса ADB:   
Выбрать кластер. Вкладка Services -> Add service -> ADB.   
**Configuration -> Main -> Use segment mirroring: false**   
**Configuration -> Advanced -> Number of segments per host: 2**   
**Configuration -> Advanced -> Custom pg_hba section: host all all 0.0.0.0/0 trust**   
Action -> Install
   
Добавление хостов в кластер:   
Выбрать кластер. Вкладка Hosts -> Add host.   
   
Mapping:   
Clasters -> ADB cluster -> Mapping   
Задать хосты для ADB Master, ADB Segment.   

Операции с кластером:   
Precheck   
Install   

### Соединение DBeaver c Master БД: ###   
На хосте master в папке /data1/master/gpseg-1    
в файл pg_hba.conf добавить строку   
host     all            all         0.0.0.0/0           trust   
в файл postgresql.auto.conf добавить строку   
listen_addresses = '*'   
Объект "Соединение" в DBeaver: host: 192.168.2.151, порт: 5432, БД: adb, пользователь: gpadmin/admin.   

### Запуск кластера Arenadata DB в ADCM: ###   
Clusters -> ADB Cluster -> Services -> ADB -> Action: Start   
   
**После установки кластера Arenadata DB можно не запускать ADCM - запуск и остановку кластера выполнять из командной строки.**   
   
### Запуск кластера Arenadata DB из командной строки (на master): ###   
```
$ cd /usr/lib/gpdb/bin
$ su gpadmin
$ source /usr/lib/gpdb/greenplum_path.sh
$ export COORDINATOR_DATA_DIRECTORY=/data1/master/gpseg-1
$ python3 gpstart
```
   
### Остановка кластера Arenadata DB из командной строки (на master): ###   
```
$ cd /usr/lib/gpdb/bin
$ su gpadmin
$ source /usr/lib/gpdb/greenplum_path.sh
$ export COORDINATOR_DATA_DIRECTORY=/data1/master/gpseg-1
$ python3 gpstop
```
