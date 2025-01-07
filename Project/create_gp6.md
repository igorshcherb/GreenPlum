## Создание Single-Node кластера Greenplum 6 ##

Скачивание образа "песочницы" Greenplum 6:   
https://disk.yandex.ru/d/ruXcxej6je-cJw   
или https://disk.yandex.ru/d/-flsw0qr5mRJcg   

Импортировние файла формата ova в VirtualBox.   

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
SSH:   
* Хост/IP: 192.168.2.16   
* Порт: 22   
* Пользователь/пароль: gpadmin/gpadmin
    
