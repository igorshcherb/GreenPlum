## Сбой и восстановление сегмент-хоста ##   
   
### Имитация сбоя сегмент-хоста ###   
Для имитации сбоя сегмент-хоста был выбран самый простой вариант - выключение виртуальной машины segment-2.

### Конфигурация сегментов после сбоя ###
Сразу после сбоя конфигурация сегментов выглядела следующим образом:   
|dbid|content|role|preferred_role|mode|status|port|hostname|address|datadir|
|----|-------|----|--------------|----|------|----|--------|-------|-------|
|1|-1|p|p|n|u|5432|master|master|/data1/master/gpseg-1|
|10|-1|m|m|s|u|5432|standby|standby|/data1/master/gpseg-1|
|2|0|p|p|n|u|10000|segment-1|segment-1|/data1/primary/gpseg0|
|6|0|m|m|n|d|10500|segment-2|segment-2|/data1/mirror/gpseg0|
|3|1|p|p|n|u|10001|segment-1|segment-1|/data1/primary/gpseg1|
|7|1|m|m|n|d|10501|segment-2|segment-2|/data1/mirror/gpseg1|
|8|2|p|m|n|u|10500|segment-1|segment-1|/data1/mirror/gpseg2|
|4|2|m|p|n|d|10000|segment-2|segment-2|/data1/primary/gpseg2|
|9|3|p|m|n|u|10501|segment-1|segment-1|/data1/mirror/gpseg3|
|5|3|m|p|n|d|10001|segment-2|segment-2|/data1/primary/gpseg3|

### Восстановление кластера ###   
Восстановление кластера выполнялось в два этапа.   
1. Собственно восстановление:   
```
$ cd /usr/lib/gpdb/bin
$ su gpadmin
$ source /usr/lib/gpdb/greenplum_path.sh
$ export COORDINATOR_DATA_DIRECTORY=/data1/master/gpseg-1
$ python3 gprecoverseg
```
После этого конфигурация сегментов была такая:   
|dbid|content|role|preferred_role|mode|status|port|hostname|address|datadir|
|----|-------|----|--------------|----|------|----|--------|-------|-------|
|1|-1|p|p|n|u|5432|master|master|/data1/master/gpseg-1|
|10|-1|m|m|s|u|5432|standby|standby|/data1/master/gpseg-1|
|2|0|p|p|s|u|10000|segment-1|segment-1|/data1/primary/gpseg0|
|6|0|m|m|s|u|10500|segment-2|segment-2|/data1/mirror/gpseg0|
|3|1|p|p|s|u|10001|segment-1|segment-1|/data1/primary/gpseg1|
|7|1|m|m|s|u|10501|segment-2|segment-2|/data1/mirror/gpseg1|
|8|2|p|m|s|u|10500|segment-1|segment-1|/data1/mirror/gpseg2|
|4|2|m|p|s|u|10000|segment-2|segment-2|/data1/primary/gpseg2|
|9|3|p|m|s|u|10501|segment-1|segment-1|/data1/mirror/gpseg3|
|5|3|m|p|s|u|10001|segment-2|segment-2|/data1/primary/gpseg3|

2. Ребалансировка:
```
$ python3 gprecoverseg -r
```
После этого конфигурация сегментов вернулась к первоначальному виду:   
|dbid|content|role|preferred_role|mode|status|port|hostname|address|datadir|
|----|-------|----|--------------|----|------|----|--------|-------|-------|
|1|-1|p|p|n|u|5432|master|master|/data1/master/gpseg-1|
|10|-1|m|m|s|u|5432|standby|standby|/data1/master/gpseg-1|
|2|0|p|p|s|u|10000|segment-1|segment-1|/data1/primary/gpseg0|
|6|0|m|m|s|u|10500|segment-2|segment-2|/data1/mirror/gpseg0|
|3|1|p|p|s|u|10001|segment-1|segment-1|/data1/primary/gpseg1|
|7|1|m|m|s|u|10501|segment-2|segment-2|/data1/mirror/gpseg1|
|4|2|p|p|s|u|10000|segment-2|segment-2|/data1/primary/gpseg2|
|8|2|m|m|s|u|10500|segment-1|segment-1|/data1/mirror/gpseg2|
|5|3|p|p|s|u|10001|segment-2|segment-2|/data1/primary/gpseg3|
|9|3|m|m|s|u|10501|segment-1|segment-1|/data1/mirror/gpseg3|

### Распределение данных между сегментами ###      
Все это время картина распределения данных таблицы между сегментами была одна и та же. Только под номерами 0..3 выступали разные экземпляры Postgres.
```
select distinct gp_segment_id from t1 order by 1;
```
|gp_segment_id|
|-------------|
|0|
|1|
|2|
|3|

### Синхронизация зеркал ###
После восстановления кластера восстановилась синхронизация зеркал:
```
$ python3 gpstate -m
```
```
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:-Starting gpstate with args: -m
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 7.2.0_arenadata5 build 103+git7888a88'
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:-coordinator Greenplum Version: 'PostgreSQL 12.12 (Greenplum Database 7.2.0_arenadata5 build 103+git7888a88) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, 64-bit compiled on Sep 16 2024 20:02:13 Bhuvnesh C.'
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:-Obtaining Segment details from coordinator...
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:--------------------------------------------------------------
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:--Current GPDB mirror list and status
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:--Type = Group
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:--------------------------------------------------------------
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:-   Mirror      Datadir                Port    Status    Data Status    
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:-   segment-2   /data1/mirror/gpseg0   10500   Passive   Synchronized
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:-   segment-2   /data1/mirror/gpseg1   10501   Passive   Synchronized
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:-   segment-1   /data1/mirror/gpseg2   10500   Passive   Synchronized
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:-   segment-1   /data1/mirror/gpseg3   10501   Passive   Synchronized
20241223:12:23:14:208233 gpstate:master:gpadmin-[INFO]:--------------------------------------------------------------
```
   
Все сегменты работают хорошо:
```
$ python3 gpstate -e
```
```
20241223:12:27:28:211479 gpstate:master:gpadmin-[INFO]:-Starting gpstate with args: -e
20241223:12:27:28:211479 gpstate:master:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 7.2.0_arenadata5 build 103+git7888a88'
20241223:12:27:28:211479 gpstate:master:gpadmin-[INFO]:-coordinator Greenplum Version: 'PostgreSQL 12.12 (Greenplum Database 7.2.0_arenadata5 build 103+git7888a88) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, 64-bit compiled on Sep 16 2024 20:02:13 Bhuvnesh C.'
20241223:12:27:28:211479 gpstate:master:gpadmin-[INFO]:-Obtaining Segment details from coordinator...
20241223:12:27:28:211479 gpstate:master:gpadmin-[INFO]:-Gathering data from segments...
20241223:12:27:28:211479 gpstate:master:gpadmin-[INFO]:-----------------------------------------------------
20241223:12:27:28:211479 gpstate:master:gpadmin-[INFO]:-Segment Mirroring Status Report
20241223:12:27:28:211479 gpstate:master:gpadmin-[INFO]:-----------------------------------------------------
20241223:12:27:28:211479 gpstate:master:gpadmin-[INFO]:-All segments are running normally
```
