## Запуск мониторинга на кластере Arenadata DB 7.2 ##   
   
### Подготовка дополнительного хоста ###   
Чтобы установить мониторинг для кластера Arenadata DB 7.2 требуется дополнительный хост.   
Не получилось добавить хост для мониторинга в кластер с двумя сегмент-хостами - не хватило оперативной памяти.   
Поэтому мониторинг был добавлен в кластер с одним сегмент-хостом.   
Имя хоста мониторинга: monitoring.   
IP адрес хоста (у меня): 192.168.2.145.   
Этот хост нужно зарегистрировать В ADCM: Hosts -> Create host   
* Hostprovider: SSH   
* Name: monitoring   
* Параметры хоста: Password, SSH private key, Connection address (IP адрес ВМ).   

### Загрузка и установка бандла мониторинга ###   
Бандл мониторинга adcm_cluster_monitoring_v4.1.0-1_community.tgz загружаентся со страницы   
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

На странице кластера: Hosts -> Add hosts   
Выбрать хост monitoring.   

На странице кластера перейти на закладку Mapping.    
Указать хост monitoring для Graphana, Graphite, Diamond.   
   
На странице кластера перейти на закладку Services. Задать пароль пользователя admin для сервиса Graphana.   
   
На странице кластера выполнить действие "Install".   

Открытие окна Graphite (порт 80 можно не указывать в адресе): http://192.168.2.145   
   
Открытие окна Graphana: http://192.168.2.145:3000

