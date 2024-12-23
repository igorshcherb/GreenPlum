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

2. Ребалансировка
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
   


