## Ресурсные группы пользователей ##   
Ресурсные группы по типам пользователей:   
* администраторы   
  ```
  create resource group rg1 with (cpu_weight=500, concurrency=10, cpu_max_percent=10, memory_limit=100);
  create role u11 with login resource group rg1 password 'u';
  create role u12 with login resource group rg1 password 'u';
  ```  
* технические пользователи   
  ```
  create resource group rg2 with (cpu_weight=300, concurrency=10, cpu_max_percent=10, memory_limit=100);
  create role u21 with login resource group rg2 password 'u';
  create role u22 with login resource group rg2 password 'u';
  ```
* бизнес-пользователи   
  ```
  create resource group rg3 with (cpu_weight=100, concurrency=100, cpu_max_percent=30, memory_limit=2000);
  create role u31 with login resource group rg3 password 'u';
  create role u32 with login resource group rg3 password 'u';
  ```
Максимальный приоритет у администраторов, минимальный - у бизнес-пользователей.
Администраторы и технические пользователи выполняют небольшое число запросов (10), бизнес-пользователи - большое число запросов (100).
Бизнес-пользователи выполняют более тяжелые запросы, поэтому им выделяется больше памяти и CPU.
