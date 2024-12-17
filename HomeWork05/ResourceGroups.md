## Настройка Resource Groups ##   
   
### Ресурсные группы, созданные по умолчанию ###   
При создании Arenadata DB 7.2 с помощью Arenadata Cluster Manager и bundles создаются следующие ресурсные группы:
```
select * from gp_toolkit.gp_resgroup_config;
|groupid|groupname|concurrency|cpu_max_percent|cpu_weight|cpuset|memory_limit|min_cost|io_limit|
|-------|---------|-----------|---------------|----------|------|------------|--------|--------|
|6437|default_group|20|20|100|-1|-1|500|-1|
|6438|admin_group|10|10|100|-1|-1|500|-1|
|6441|system_group|0|10|100|-1|-1|500|-1|
```
