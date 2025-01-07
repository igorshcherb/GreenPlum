## Клонирование и настройка виртуальных машин ##

- замена сетевых имен после клонирования виртуальных машин:  
  $ sudo nano /etc/hostname  
  ADCM, master, segment-1, segment-1.   
- IP-адреса хостов:   
   ADCM      192.168.2.150   
   master    192.168.2.151   
   segment-1 192.168.2.153
   segment-2 192.168.2.154   
- Задание статических IP:   
  $ sudo nano /etc/netplan/01-network-manager-all.yaml
```   
network:   
  version: 2   
  renderer: NetworkManager   
  ethernets:   
   enp0s3:   
     dhcp4: no   
     addresses: [192.168.2.151/24]   
     gateway4: 192.168.2.1   
     nameservers:   
         addresses: [192.168.2.1,192.168.2.1]   
```
- Разрешение заходить по SSH под root:   
$ sudo nano /etc/ssh/sshd_config   
PermitRootLogin yes   
PasswordAuthentication yes   
$ systemctl restart ssh || systemctl restart sshd
   
