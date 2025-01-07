## Конфигурация кластера Arenadata DB ##   
   
```
select version();
```
```
PostgreSQL 12.12 (Greenplum Database 7.2.0_arenadata5 build 103+git7888a88) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, 64-bit compiled on Sep 16 2024 20:02:13 Bhuvnesh C.
```
   
```
select * from gp_segment_configuration order by dbid;
```
|dbid|content|role|preferred_role|mode|status|port|hostname|address|datadir|
|----|-------|----|--------------|----|------|----|--------|-------|-------|
|1|-1|p|p|n|u|5432|master|master|/data1/master/gpseg-1|
|2|0|p|p|n|u|10000|segment-1|segment-1|/data1/primary/gpseg0|
|3|1|p|p|n|u|10001|segment-1|segment-1|/data1/primary/gpseg1|
|4|2|p|p|n|u|10000|segment-2|segment-2|/data1/primary/gpseg2|
|5|3|p|p|n|u|10001|segment-2|segment-2|/data1/primary/gpseg3|
