## Запуск мониторинга на кластере Arenadata DB 7.2 ##   
   
### Подготовка дополнительного хоста ###   
Имя хоста мониторинга: monitoring.   
IP адрес хоста (у меня): 192.168.2.145.   
Этот хост был зарегистрирован в ADCM:   
Hosts -> Create host   
* Hostprovider: SSH   
* Name: monitoring   
* Параметры хоста: Password, SSH private key, Connection address (IP адрес ВМ).   

### Загрузка и установка бандла мониторинга ###   
Бандл мониторинга adcm_cluster_monitoring_v4.1.0-1_community.tgz загружается со страницы   
https://network.arenadata.io/arenadata-monitoring   
Установка бандла в ADCM:   
Bundles -> Upload bundle -> Выбрать загруженный файл с локального диска -> Открыть   

### Создание и настройка кластера мониторинга в ADCM ###   
Clusters -> Create cluster -> Create    
* Product: Monitoring   
* Product version: 4.1.0-1_community   
* Cluster name: Monitoring cluster (например)
   
На странице кластера: Services -> Add service
* Diamond
* Graphana
* Graphite

На странице кластера Monitoring: Hosts -> Add hosts   
Выбрать хост monitoring.   

На странице кластера Monitoring перейти на закладку Mapping.    
Указать хост monitoring для Graphana, Graphite, Diamond.   
   
На странице кластера Monitoring перейти на закладку Services. Задать пароль пользователя admin для сервиса Graphana. 

На странице кластера ADB перейти на закладку Import и выполнить импорт кластера Monitoring с сервисами Graphana, Graphite.
   
На странице кластера Monitoring выполнить действие "Install".  
   
**Примечание.** В сответствии с документацией, подключение Grafana к Arenadata DB 7.2 выполняется напрямую, а не через Prometheus.   
   
### Открытие окон мониторинга ###   
Открытие окна Graphite (порт 80 можно не указывать в адресе): http://192.168.2.145   
   
Открытие окна Graphana (порт 3000): http://192.168.2.145:3000
   
### Примеры мониторинга ###     

Для примера - мониторинг выполнения одного "тяжелого" запроса и нескольких "легких":   
[Graphite](Graphite.jpg)   
[Graphana](ArenadataSystemMetrics.jpg)   
   
Еще пример мониторинга Graphana:   
[Graphana. Пример 2.](ArenadataSystemMetrics_2.jpg)   
   
**Дополнение.** Если поставить мониторинг на хост ADCM (у меня 192.168.2.140), то тоже все работает. Получается, дополнительную виртуальную машину можно исключить.   
   
