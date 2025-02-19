## Создание Single-Node кластера Arenadata DB 6.27 (из исходников) ##
```
git clone https://github.com/arenadata/gpdb.git --recurse-submodules

Переименовал /home/admn/gpdb в /home/admn/gpdb_src

Appropriate linux steps for getting your system ready for GPDB
--------------------------------------------------------------
For Ubuntu (versions 20.04 or 22.04):
-------------------------------------

cd ./gpdb_src

Install dependencies using README.ubuntu.bash script:
sudo ./README.ubuntu.bash

Create symbolic link to Python 2 in /usr/bin:
sudo ln -s python2 /usr/bin/python

Ensure that your system supports American English with an internationally compatible character encoding scheme. To do this, run:
sudo locale-gen "en_US.UTF-8"

Common Platform Tasks:
----------------------

1. Create gpadmin and setup ssh keys
# Requires gpdb clone to be named gpdb_src
sudo ./concourse/scripts/setup_gpadmin_user.bash

2. Verify that you can ssh to your machine name without a password
ssh <hostname of your machine>  # e.g., ssh briarwood

ssh Arena627

3. Set up your system configuration:
sudo bash -c 'cat >> /etc/sysctl.conf <<-EOF
kernel.shmmax = 500000000
kernel.shmmni = 4096
kernel.shmall = 4000000000
kernel.sem = 500 1024000 200 4096
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.conf.all.arp_filter = 1
net.ipv4.ip_local_port_range = 1025 65535
net.core.netdev_max_backlog = 10000
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
vm.overcommit_memory = 2
EOF'
sudo sysctl -p # Apply settings

4. Change user and system limits:
sudo bash -c 'cat >> /etc/security/limits.conf <<-EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 131072
* hard nproc 131072
EOF'
su - $USER # Apply settings

5. Make sure that you download yaml and psutil as submodules. To do this, use git clone --recurse-submodules when downloading the source code. If you want to update the submodules, run:

cd gpdb_src
git submodule update --init --recursive --force

Build the database
------------------

# Configure build environment to install at /usr/local/gpdb
./configure --with-perl --with-python --with-libxml --with-gssapi --prefix=/usr/local/gpdb

# Compile and install
make -j8
sudo make -j8 install

# Bring in greenplum environment into your running shell
source /usr/local/gpdb/greenplum_path.sh
```
**Установка psutil для Python2 (!)**
```
apt install python-pip
pip2 install --upgrade psutil
```
```
# Start demo cluster
make create-demo-cluster
# (gpdemo-env.sh contains __PGPORT__ and __MASTER_DATA_DIRECTORY__ values)
source gpAux/gpdemo/gpdemo-env.sh
```
**Запуск и остановка кластера**
```
cd /usr/local/gpdb/bin
source /usr/local/gpdb/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/home/admn/gpdb_src/gpAux/gpdemo/datadirs/qddir/demoDataDir-1
python2 gpstart
python2 gpstop
```
**Запуск psql на мастере**
```
psql postgres
```
**Создинение с DBeaver**   
* Хост (у меня): 192.168.2.18   
* Порт: 6000   
* База данных: postgres   
* Пользователь/пароль (у меня): admn/admn
```
cd /home/admn/gpdb_src/gpAux/gpdemo/datadirs/qddir/demoDataDir-1
```
В файл pg_hba.conf добавил строку:   
host     all            all         0.0.0.0/0           trust   
   
```
select version();
```
```
PostgreSQL 9.4.26 (Greenplum Database 6.27.1_arenadata59+dev.1.gcbb3338b74 build dev) on x86_64-unknown-linux-gnu, compiled by gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, 64-bit compiled on Jan 11 2025 20:48:33
```
```
select * from gp_segment_configuration order by content, dbid;
```
|dbid|content|role|preferred_role|mode|status|port|hostname|address|datadir|
|----|-------|----|--------------|----|------|----|--------|-------|-------|
|1|-1|p|p|n|u|6000|Arena627|Arena627|/home/admn/gpdb_src/gpAux/gpdemo/datadirs/qddir/demoDataDir-1|
|2|0|p|p|s|u|6002|Arena627|Arena627|/home/admn/gpdb_src/gpAux/gpdemo/datadirs/dbfast1/demoDataDir0|
|5|0|m|m|s|u|6005|Arena627|Arena627|/home/admn/gpdb_src/gpAux/gpdemo/datadirs/dbfast_mirror1/demoDataDir0|
|3|1|p|p|s|u|6003|Arena627|Arena627|/home/admn/gpdb_src/gpAux/gpdemo/datadirs/dbfast2/demoDataDir1|
|6|1|m|m|s|u|6006|Arena627|Arena627|/home/admn/gpdb_src/gpAux/gpdemo/datadirs/dbfast_mirror2/demoDataDir1|
|4|2|p|p|s|u|6004|Arena627|Arena627|/home/admn/gpdb_src/gpAux/gpdemo/datadirs/dbfast3/demoDataDir2|
|7|2|m|m|s|u|6007|Arena627|Arena627|/home/admn/gpdb_src/gpAux/gpdemo/datadirs/dbfast_mirror3/demoDataDir2|

