## Создание Single-Node кластера Greenplum 6 ##

Скачивание образа "песочницы" Greenplum 6:   
https://disk.yandex.ru/d/ruXcxej6je-cJw   
или https://disk.yandex.ru/d/-flsw0qr5mRJcg   

Импортировние файла формата ova в VirtualBox.   

Изменение настройки сети:   
Тип подключения: Сетевой мост   
   
Запуск образа: логин/пароль gpadmin/gpadmin.   
   
Определение IP-адреса ВМ:  
```
ip a   
```
У меня - 192.168.2.16.
   
Запуск консоли в хостовой ОС (Windows):   
```
$ssh gpadmin@192.168.2.16
```
Выполнение команд в консоли:   
```
$ gpstart   
$ pxf start
```
   
Соединение DBeaver-а в хостовой ОС (Windows) с GP в "песочнице":   
* Хост: 192.168.2.16   
* Порт: 55433   
* База данных: postgres   
* Пользователь/пароль: gpadmin/gpadmin   
**SSH:**   
* Хост/IP: 192.168.2.16   
* Порт: 22   
* Пользователь/пароль: gpadmin/gpadmin
      
Загрузка данных - аналогично Arenadata DB. Тип jsonb пришлось везде заменить на text.   

```   
select version();
```
```
PostgreSQL 9.4.26 (Greenplum Database 6.23.0 build commit:5b5e432f35f92a40c18dffe4e5bca94790aae83c Open Source) on x86_64-unknown-linux-gnu, compiled by gcc (GCC) 6.4.0, 64-bit compiled on Dec 20 2022 08:02:23
```

```
select * from gp_segment_configuration;
```
   
|dbid|content|role|preferred_role|mode|status|port|hostname|address|datadir|
|----|-------|----|--------------|----|------|----|--------|-------|-------|
|1|-1|p|p|n|u|55433|localhost|localhost|/gpdata/gpmaster/gpsne-1|
|2|0|p|p|n|u|6000|localhost.localdomain|localhost|/gpdata/gpdata1/gpsne0|
|3|1|p|p|n|u|6001|localhost.localdomain|localhost|/gpdata/gpdata2/gpsne1|
   
Соединение с БД PostgreSQL на этой ВМ:   
Порт: 5432, пользователь: pxf_user/pxf_user   
   
