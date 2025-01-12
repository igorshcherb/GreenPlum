## Установка PXF для кластера Arenadata ##  

```
su gpadmin

mkdir -p ~/workspace
cd ~/workspace

# ! В инструкции: git clone https://github.com/greenplum-db/pxf.git
sudo git clone https://github.com/arenadata/pxf.git

# !
source /usr/local/gpdb/greenplum_path.sh

# !
sudo apt install default-jre
java -version

# !
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

Скопировал go1.23.4.linux-amd64.tar.gz в /usr/local

rm -rf /usr/local/go
cd /usr/local
sudo tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

export GOPATH=$HOME/go
export GOPROXY=https://proxy.golang.org
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

go install github.com/onsi/ginkgo/v2/ginkgo@latest

sudo apt install openjdk-17-jdk openjdk-17-jre
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

cd ~/workspace/pxf

# Compile & Test PXF
make

# Only run unit tests -- ошибки из-за попытки подсоединиться по порту 5432
make test

su gpadmin
sudo mkdir -p ~/pxf-base
sudo mkdir -p /usr/local/pxf
sudo mkdir -p ~/workspace/pxf

export GPHOME=/usr/local/gpdb
export PXF_HOME=/usr/local/pxf
export PXF_BASE=${HOME}/pxf-base
sudo chown -R admn:admn "${GPHOME}" "${PXF_HOME}"

# ! Запускал под admn
source /usr/local/gpdb/greenplum_path.sh

make -C ~/workspace/pxf install

export PATH=/usr/local/pxf/bin:$PATH

cd /home/admn/workspace/pxf/server/build/stage/bin

su admn
sudo mkdir -p ~/pxf-base
sudo mkdir -p /usr/local/pxf
sudo mkdir -p ~/workspace/pxf

# export PXF_BASE=/home/gpadmin/pxf-base
export PXF_BASE=/home/admn/pxf-base

/bin/bash pxf prepare

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

/bin/bash pxf start
```
В DBeaver:   
```
create extension pxf;
```

