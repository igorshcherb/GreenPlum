## Клонирование и настройка виртуальных машин ##

- Замена сетевых имен после клонирования виртуальных машин:  
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
- Распределение памяти между виртуальными машинами:
    
|ВМ|Объем памяти (Гб)|   
|---------|-------------|   
|ADCM|4|   
|master|8|   
|segment-1|8|   
|segment-2|8|   
   
