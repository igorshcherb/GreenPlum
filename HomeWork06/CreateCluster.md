## Создание кластера с двумя сегмент-хостами ##   

### Распределение памяти между виртуальными машинами ###   
Для проведения экспериментов по восстановлению сегментов после сбоя был создан кластер с двумя сегмент-хостами.   
Всего на компьютере 32 Гб оперативной памяти. Распредение между виртуальными машинами следующее:
|ВМ|Объем памяти (Гб)|
|---------|-------------|
|ADCM|4|
|master|6|
|standby|6|
|segment-1|8|
|segment-2|8|
   
**Примечания**   
1. ADCM приходится выносить на отдельный хост (и выделять ему отдельную память), иначе после перезагрузки хостов в процессе создания кластера возникает ошибка.   
2. Была попытка уменьшить память для master и standby и увеличить ее для сегментов, но при этом начинают возникать ошибки взаимодействия между хостами по SSH-протоколу.   

### Архитектура кластера ###
Количество сегментов в сегмент-хосте: 2.   
Распределение сегментов и зеркал по хостам: групповое зеркалирование (по умолчанию).   
Зеркалирование хоста master: на хосте standby.   
   
### Заполнение кластера данными ###   
Для того, чтобы восстановление после сбоя происходило быстро, была создана всего одна таблица с небольшим объемом данных:   
```
create table t1(id int8, vc varchar(100)) distributed by (id);
insert into t1 (select s, s::varchar from generate_series(1, 100) s);
```
   
### Первоначальная конфигурация кластера ###   
```
select * from gp_segment_configuration order by content, role desc;
```
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


