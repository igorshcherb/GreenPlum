## Запуск мониторинга на кластере Arenadata DB 7.2 ##   
   
### Подготовка дополнительного хоста ###   
Чтобы установить мониторинг для кластера Arenadata DB 7.2 требуется дополнительный хост.   
Не получилось добавить хост для мониторинга в кластер с двумя сегмент-хостами - не хватило оперативной памяти.   
Поэтому мониторинг был добавлен в кластер с одним сегмент-хостом. 
Имя хоста мониторинга: monitoring.
Этот хост нужно зарегистрировать В ADCM: Hosts -> Create host
* Hostprovider: SSH
* Name: monitoring

### Загрузка и установка бандла мониторинга ###   
Бандл мониторинга adcm_cluster_monitoring_v4.1.0-1_community.tgz загружаентся со страницы   
[https://network.arenadata.io/arenadata-monitoring](https://network.arenadata.io/arenadata-monitoring)   
Установка бандла в ADCM:   
Bundles -> Upload bundle -> Выбрать загруженный файл с локального диска -> Открыть   

### Создание и настройка кластера мониторинга в ADCM ###   
Clusters -> Create cluster => Create    
* Product: Monitoring   
* Product version: 4.1.0-1_community   
* Cluster name: Monitoring cluster (например)
   
На странице кластера: Services -> Add service
* Diamond
* Graphana
* Graphite

На странице кластера: Hosts -> Add hosts

