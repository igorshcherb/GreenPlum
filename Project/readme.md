## <div align="center"> Проектная работа по курсу "Greenplum для разработчиков и архитекторов баз данных" <div align="center"> ##
   
# <div align="center"> Оптимизация сложных запросов в MPP-кластерах: </div> #
# <div align="center"> Greenplum, Arenadata DB, Cloudberry Database </div> #
   
**Цель проекта:**   
Разбор методов оптимизации сложных запросов в MPP-кластерах.   
   
**Задачи проекта:**   
1. Собрать методы оптимизации запросов из разных источников.   
2. Подготовить стенды MPP-кластеров: Greenplum, Arenadata DB, Cloudberry Database.   
3. Разобрать методы оптимизации на различных примерах.  
4. Проанализировать планы выполнения запросов.   

[Презентация PDF](Project_Optimization.pdf) [PPTX](Project_Optimization.pptx)    

**Создание Multi-Node кластера Arenadata DB 7.2 с помощью ADCM и бандлов**   
* [Создание шаблона виртуальных машин в VirtualBox](VMTemplate.md)   
* [Клонирование и настройка виртуальных машин](VMClone.md)   
* [Установка Arenadata DB 7.2](InstallArenadata7.2.md)   
* [Установка PXF - Platform Extension Framework](Install_PXF.md)
* [Конфигурация кластера Arenadata DB](arenadata_config.md)   

**Загрузка данных в БД PostgreSQL**   
* [Источники БД "Авиаперевозки"](air_db.md)
* [Схема БД "Авиаперевозки"](air_db_schema.jpg) 
* [Создание таблиц PostgreSQL](create_Postgres_tables.sql)   
   
**Загрузка данных в ADB**   
* [Создание внешних таблиц](create_ext_tables.sql)   
* [Создание и заполнение таблиц ADB](create_adb_tables.sql)   
   
[**Создание Single-Node кластера Greenplum 6.23 (песочница)**](create_gp6.md)
   
[**Создание Single-Node кластера Cloudberry v1.5.1 (песочница)**](create_cloudberry.md)   
   
[**Создание Single-Node кластера Cloudberry v1.6 (из исходников)**](create_cloudberry16.md)  
