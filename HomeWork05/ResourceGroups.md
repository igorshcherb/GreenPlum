## Настройка Resource Groups для разных типов запросов ##   
   
### Ресурсные группы, созданные по умолчанию ###   
При создании Arenadata DB 7.2 с помощью Arenadata Cluster Manager и bundles создаются следующие ресурсные группы:
```
select * from gp_toolkit.gp_resgroup_config;
```
|groupid|groupname|concurrency|cpu_max_percent|cpu_weight|cpuset|memory_limit|min_cost|io_limit|
|-------|---------|-----------|---------------|----------|------|------------|--------|--------|
|6437|default_group|20|20|100|-1|-1|500|-1|
|6438|admin_group|10|10|100|-1|-1|500|-1|
|6441|system_group|0|10|100|-1|-1|500|-1|

### Создание ресурсной группы ### 
Для написания команды создания ресурсной группы Arenadata DB 7.2 воспользовался документацией:   
[CREATE_RESOURCE_GROUP](https://techdocs.broadcom.com/us/en/vmware-tanzu/data-solutions/tanzu-greenplum/7/greenplum-database/ref_guide-sql_commands-CREATE_RESOURCE_GROUP.html)  
CREATE RESOURCE GROUP rg_new WITH (   
CONCURRENCY=<integer>   
CPU_MAX_PERCENT=<integer>    
CPUSET=<coordinator_cores>;<segment_cores>   
CPU_WEIGHT=<integer>   
MEMORY_QUOTA=<integer>   
MIN_COST=<integer>   
IO_LIMIT=' <tablespace_io_limit_spec>   
);   
