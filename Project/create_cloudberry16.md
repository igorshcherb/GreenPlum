## Создание Single-Node кластера Cloudberry v1.6 (из исходников) ##
   
```
$ sudo nano /etc/hostname
```
Cloudberry16   
   
<Перезагрузка>   

```   
$ hostname
```
Cloudberry16
   
```
$ sudo -i
$ passwd
```

### Шаг 1. Клонирование репозитория GitHub ###
   
```
$ git clone https://github.com/cloudberrydb/cloudberrydb.git
```
   
### Шаг 2. Установка зависимостей ###
For Ubuntu 18.04 or later   
```
## You need to enter your password to run.
$ sudo ~/cloudberrydb/deploy/build/README.Ubuntu.bash
```
Default Kerberos version 5 realm: default   
Kerberos servers for your realm: default   
Administrative server for your Kerberos realm: default   
   
```
$ export DEBIAN_FRONTEND=noninteractive
```
```   
## Install gcc-10
$ sudo apt install software-properties-common
$ sudo add-apt-repository ppa:ubuntu-toolchain-r/test
$ sudo apt install gcc-10 g++-10
$ sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100
```
   
### Шаг 3. Предварительная настройка платформы ###
```
$ echo -e "/usr/local/lib \n/usr/local/lib64" >> /etc/ld.so.conf
$ ldconfig
```
```
$ useradd -r -m -s /bin/bash gpadmin  # Creates gpadmin user
$ su - gpadmin  # Uses the gpadmin user
$ ssh-keygen  # Creates SSH key
$ cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
$ chmod 600 ~/.ssh/authorized_keys 
$ exit
```
   
### Шаг 4. Сборка Cloudberry Database ###
```
$ cd cloudberrydb
$ ./configure --with-perl --with-python --with-libxml --with-gssapi --prefix=/usr/local/cloudberrydb
```
```
$ make -j8
$ make -j8 install
```
```
$ cd ..
$ cp -r cloudberrydb/ /home/gpadmin/
$ cd /home/gpadmin/
$ chown -R gpadmin:gpadmin cloudberrydb/
$ su - gpadmin
$ cd cloudberrydb/
$ source /usr/local/cloudberrydb/greenplum_path.sh
```
```
$ make create-demo-cluster
```
```
$ source gpAux/gpdemo/gpdemo-env.sh
```
   
### Шаг 5. Проверка кластера ###
```
$ ps -ef | grep postgres
```
```
$ psql -p 7000 postgres
```
```
select version();
```
```
PostgreSQL 14.4 (Cloudberry Database 1.6.0+dev.641.ge36838cea1 build dev) on x8
6_64-pc-linux-gnu, compiled by gcc (Ubuntu 10.5.0-1ubuntu1~22.04) 10.5.0, 64-bit
 compiled on Jan 10 2025 17:45:11
```
```
select * from gp_segment_configuration;
```
| dbid | content | role | preferred_role | mode | status | port |   hostname   |   address    |                                   datadir                                    | warehouseid |
|------|---------|------|----------------|------|--------|------|--------------|--------------|------------------------------------------------------------------------------|-------------|
|    1 |      -1 | p    | p              | n    | u      | 7000 | Cloudberry16 | Cloudberry16 | /home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/qddir/demoDataDir-1         |           0 |
|    8 |      -1 | m    | m              | s    | u      | 7001 | Cloudberry16 | Cloudberry16 | /home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/standby                     |           0 |
|    2 |       0 | p    | p              | s    | u      | 7002 | Cloudberry16 | Cloudberry16 | /home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/dbfast1/demoDataDir0        |           0 |
|    5 |       0 | m    | m              | s    | u      | 7005 | Cloudberry16 | Cloudberry16 | /home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/dbfast_mirror1/demoDataDir0 |           0 |
|    3 |       1 | p    | p              | s    | u      | 7003 | Cloudberry16 | Cloudberry16 | /home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/dbfast2/demoDataDir1        |           0 |
|    6 |       1 | m    | m              | s    | u      | 7006 | Cloudberry16 | Cloudberry16 | /home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/dbfast_mirror2/demoDataDir1 |           0 |
|    4 |       2 | p    | p              | s    | u      | 7004 | Cloudberry16 | Cloudberry16 | /home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/dbfast3/demoDataDir2        |           0 |
|    7 |       2 | m    | m              | s    | u      | 7007 | Cloudberry16 | Cloudberry16 | /home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/dbfast_mirror3/demoDataDir2 |           0 |
   
### Запуск кластера ###
```
$ sudo -i
$ su gpadmin
$ source /usr/local/cloudberrydb/greenplum_path.sh
$ export COORDINATOR_DATA_DIRECTORY=/home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/qddir/demoDataDir-1   
$ python3 gpstart
```
   
### Соединение с DBeaver ###
```
select setting from pg_settings where name = 'listen_addresses';
```
*   
```
cd /home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/qddir/demoDataDir-1
```










