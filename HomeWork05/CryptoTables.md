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

Задание значения параметра shared_preload_libraries:   
```
$ su gpadmin
$ cd /usr/lib/gpdb/bin
$ source /usr/lib/gpdb/greenplum_path.sh
$ export COORDINATOR_DATA_DIRECTORY=/data1/master/gpseg-1
$ python3 gpconfig -c shared_preload_libraries -v '$libdir/pgcrypto'
$ python3 gpstop -ra 
```
### Получение зашифрованного пароля ###   
```
select crypt('pass', gen_salt('md5')) as cryptpwd; 
```
Получено значение: $1$WLGc27a9$g5x0O./rAwreF0eEpuXDF.   

### Создание таблицы и шифрование в ней данных ###   
```
create table t1(id int8, txt text) distributed by (id);
insert into t1(id) (select s from generate_series(1, 100) s);
update t1 set txt = pgp_sym_encrypt(id::varchar, '$1$WLGc27a9$g5x0O./rAwreF0eEpuXDF.');
```
В результате в столбец txt таблицы записаны зашифрованные идентификаторы из столбца id:
```
select * from t1 order by id limit 10;
```
|id|txt|
|--|---|
|1|\xc30d04070302c9eba64f3d2551f46ed232010e1562e662436cefc1f64881ad5967d9df822d6a18d34d6f892ed6aa3568b683374068c45e9bf8f2c6ef05be81fd7cf2b8|
|2|\xc30d0407030265de6ec5df24ad3864d232011de02b5577967793f11f35e4194beb6c52cd55fb4369f82d0944b17ab8ae9e43735df988f4d6a67238cfc95367ffb701e4|
|3|\xc30d04070302a5a0a12590de6f8377d2320190b987149e8871831fcac5576fca98ec85f42afa4f1f8bf0ea622003974d2172d988503365f415afee0fb24a7719300eaf|
|4|\xc30d04070302dc980414b039477978d23201d61179e144ac5d857c3292218adcf95051cfc241586a424b24e132c62c686e87c00778afe4a25fa57d2d3f4d8f4297ef11|
|5|\xc30d0407030210bf402a5f79cd836bd232011c3d260bd644f6911280c5f0c9f1c4cda7a4f15cbee04d281e1aec6a7fe20d3ce50d08e0738bb243bed385a5e261e8bc8c|
|6|\xc30d04070302d1a51a0b0dcd965576d23201e5897e0963ec8cb18c90ece3405a8d6822817541477e8c4cd3a403852d97cab9d2718131324fe48a8837d9dd3283fcc2a9|
|7|\xc30d040703024cc3ba5f9e03a2397fd2320188ad5be687aff038810de5ff4737eb8500bb09ce9710f7ae79a5aa680733b42f8691a2fcd9ad41cba1bf43e1fdf282eafc|
|8|\xc30d04070302a69dcba305e1654965d23201cf875a811367777884578f097e6c6a716d59e7895a74c3479e712c86236c25af79545394b851b6021209ab36dfb1214b45|
|9|\xc30d0407030206756eb1ae69211175d232015ac8843438603ff476add90fd2ab6d32949766bb963ccf4e2fc8115a7154710c71e466127b5a5ff5f07b82b15630c91b17|
|10|\xc30d04070302f68002d8e4c978c76dd233010047019f39956af9bb45ddca64a0ec4bf5768c31745ba483a37989d6c5f903c8e4930b55b0f202411dd124beafd298e7d23d|
