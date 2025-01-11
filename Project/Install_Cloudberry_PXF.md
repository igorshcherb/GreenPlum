## Установка PXF для кластера Cloudberry ##
```   
sudo -i
su gpadmin

mkdir -p ~/workspace
cd ~/workspace

git clone https://github.com/cloudberrydb/pxf.git

sudo apt install default-jre
java -version

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

rm -rf /usr/local/go
tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

go install github.com/onsi/ginkgo/ginkgo@latest

sudo apt install curl
curl --version

cd ~/workspace/pxf
# Compile & Test PXF
make
# Only run unit tests
make test

sudo -i
passwd gpadmin
New password: gpadmin

su gpadmin
mkdir -p ~/pxf-base

export GPHOME=/usr/local/cloudberrydb
export PXF_HOME=/usr/local/pxf
export PXF_BASE=${HOME}/pxf-base
chown -R gpadmin:gpadmin "${GPHOME}" "${PXF_HOME}"
make -C ~/workspace/pxf install

export PATH=/usr/local/pxf/bin:$PATH

sudo -i
mkdir -p /usr/local/pxf
chown -R gpadmin:gpadmin /usr/local/pxf

cd /home/gpadmin/workspace/pxf/server/build/stage/pxf/bin
export PXF_BASE=/home/gpadmin/pxf-base
/bin/bash pxf prepare
/bin/bash pxf start
```
В DBeaver:   
```
create extension pxf;
```
**Запуск PXF-сервера**   
```
cd /home/gpadmin/workspace/pxf/server/build/stage/pxf/bin
export PXF_BASE=/home/gpadmin/pxf-base
/bin/bash pxf start
```
**Остановка PXF-сервера**   
```
cd /home/gpadmin/workspace/pxf/server/build/stage/pxf/bin
export PXF_BASE=/home/gpadmin/pxf-base
/bin/bash pxf stop
```


