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
select * from gp_segment_configuration;
```
   
### Запуск кластера ###
```
source /usr/local/cloudberrydb/greenplum_path.sh
export COORDINATOR_DATA_DIRECTORY=/home/gpadmin/cloudberrydb/gpAux/gpdemo/datadirs/qddir/demoDataDir-1   
python3 gpstart
```











