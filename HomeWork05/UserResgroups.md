## Ресурсные группы пользователей ##   
Ресурсные группы по типам пользователей:   
* администраторы   
  ```
  create resource group rg1 with (cpu_weight=500, concurrency=10, cpu_max_percent=10, memory_limit=100);
  ```  
* технические пользователи   
  ```
  create resource group rg2 with (cpu_weight=300, concurrency=10, cpu_max_percent=10, memory_limit=100);
  ```
* бизнес-пользователи   
  ```
  create resource group rg3 with (cpu_weight=100, concurrency=100, cpu_max_percent=30, memory_limit=2000);
  ```
Для    
