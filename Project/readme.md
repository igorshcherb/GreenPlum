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
* [ER-диаграмма "Авиаперевозки"](Air_Flow_ER.jpg)
* [Схема БД "Авиаперевозки"](air_db_schema.jpg) 
* [Создание таблиц PostgreSQL](create_Postgres_tables.sql)   
   
**Загрузка данных в MPP-кластеры**   
* [Создание внешних таблиц](create_ext_tables.sql)   
* [Создание и заполнение таблиц MPP-кластеров](create_adb_tables.sql)   
   
[**Запуск Single-Node кластера Greenplum 6.23 (песочница)**](create_gp6.md)   
   
[**Запуск Single-Node кластера Cloudberry v1.5.1 (песочница)**](create_cloudberry.md)    

**Single-Node кластер Cloudberry v1.6**   
* [Создание Single-Node кластера Cloudberry v1.6 (из исходников)](create_cloudberry16.md)   
* [Установка PXF для кластера Cloudberry](Install_Cloudberry_PXF.md)   

**Single-Node кластер Arenadata DB 6.27**   
* [Создание Single-Node кластера Arenadata DB 6.27 (из исходников)](create_arenadata_6.md)
* [Установка PXF для кластера Arenadata](Install_Arenadata_PXF.md)
   
**Планы выполнения запросов**   
* [Планы запросов в PostgreSQL](Postgres_queries.sql)
* [Планы запросов в Arenadata DB](Arenadata_queries.sql)
* [Планы запросов в Cloudberry Database](Cloudberry_queries.sql)
* [Планы запросов в Greenplum6](Greenplum6_queries.sql)
   
**Разбор методов оптимизации некоторых сложных и интересных запросов**
* [В PostgreSQL 17 запросы, в планах выполнения которых есть initPlan, могут использовать параллельные процессы (workers) для выполнения initPlan](Opt_initPlan.md)
* [Index Scan](Opt_IndexScan.md)
