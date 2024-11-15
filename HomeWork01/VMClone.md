## Клонирование и настройка виртуальных машин ##

- замена сетевых имен после клонирования виртуальных машин:  
  $ sudo nano /etc/hostname  
  ADCM-1  
  и т.д.  
- IP-адреса хостов:   
   ADCM-1    192.168.2.140   
   master-1  192.168.2.141   
   standby-1 192.168.2.142   
   segment-1 192.168.2.143   
- Задание статических IP:   
  $ sudo nano /etc/netplan/01-network-manager-all.yaml   
  ...   
  network:   
  version: 2   
  renderer: NetworkManager   
  ethernets:   
   enp0s3:   
     dhcp4: no   
     addresses: [192.168.2.140/24]   
     gateway4: 192.168.2.1   
     nameservers:   
         addresses: [192.168.2.1,192.168.2.1]   
  ...
- Разрешение заходить по SSH под root:   
$ sudo nano /etc/ssh/sshd_config   
PermitRootLogin yes   
PasswordAuthentication yes   
$ systemctl restart ssh || systemctl restart sshd
   
