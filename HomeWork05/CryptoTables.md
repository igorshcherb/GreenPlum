## Настройка шифрования данных на уровне таблиц ##   
   
### Добавление расширения pgcrypto ###   
```
create extension pgcrypto;
```
```
select oid, extname, extversion from pg_extension where extname = 'pgcrypto';
```
|oid|extname|extversion|
|---|-------|----------|
|24854|pgcrypto|1.3|
```
$ su gpadmin
$ cd /usr/lib/gpdb/bin
$ source /usr/lib/gpdb/greenplum_path.sh
$ export COORDINATOR_DATA_DIRECTORY=/data1/master/gpseg-1
$ python3 gpconfig -c shared_preload_libraries -v '$libdir/pgcrypto'
$ python3 gpstop -ra 
```
