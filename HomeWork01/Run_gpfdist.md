## Запуск gpfdist ##   
### На хосте standby-1: ###  
Создание каталогов:
Каталоги /var/load_files/, /home/gpadmin/log/
Запуск web-сервера gpfdist:   
```   
sudo /lib64/ld-linux-x86-64.so.2 ./gpfdist -d /var/load_files/ -p 8081 -l /home/gpadmin/log/gpfdist8081.log   
```   
Создание текстового файла:   
Файл t1.txt с числовыми значениями через запятую создан в папке /var/load_files/.   
   
### В DBeaver, в БД ADB: ###   
```   
drop external table if exists gpfdist_t1 ;   
   
create external table gpfdist_t1(c1 integer, c2 integer, p integer)   
  location ('gpfdist://192.168.2.142:8081/t1.txt')   
  format 'TEXT' (DELIMITER=',');   
   
select * from gpfdist_t1;   
```
В результате запроса отразилось содержимое файла t1.txt.   
   
