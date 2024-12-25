## Создание пользователей и настройка ролей с разными уровнями доступа ##   

### Создание пользователя в ADCM ###   
Access manager -> Users -> Create user.   
В окне "Create new user":   
Username: admin2.   
Заполнил поля: Password, Confirm password, Email.   
Поставил галочку "Grant ADCM Administrator's rights".   
   
### Создание группы пользователей в ADCM ###   
Access manager -> Groups -> Create group.    
В окне "Create new users group":   
Groupname: group2.   
Users: admin2.   

### Предоставление прав пользователю через группу в ADCM ###  
Access manager -> Policies -> Create policy.   
В окне "Create new policy":   
Policy name: policy2.   
Role: Cluster Administrator.   
Groups: group2.   
     
В результате пользователь admin2 получил следующие права:   
* Remove service, Upgrade cluster bundle, Remove bundle, Edit object ansible config.   
* **Cluster Action:** Activate standby, Activate standby postprocess, Check, Expand, Init Standby Master, Install, Post upgrade changes, Precheck, Reconfigure parameter archiving, Redistribute, Reinstall, Reinstall statuschecker, Start, Stop, Upgrade, Remove, Upgrade: 4.1.0-1.   
* **Service Action:** Create database, Create role, Disable auto core dump, Enable auto core dump, Enable mirroring, Init cluster, Install ADB, Install diskquota, Install PostGIS, Reconfigure, Reinstall ADB, Reinstall diskquota, Reinstall PostGIS, Run SQL, Start, Stop, Uninstall diskquota, Uninstall PostGIS, Manage tablespace, Delete, Install, Reinstall, Uninstall, Restart, Uninstall Diamond.
   
### Создание схем и таблиц ###   
Пользователем gpadmin были созданы таблицы:
```
create table schema1.t1(id int8, vc varchar) distributed by (id);
insert into schema1.t1 (select s, s::varchar from generate_series(1, 100) s);
```
```
create table schema2.t2(id int8, vc varchar) distributed by (id);
insert into schema2.t2 (select s, s::varchar from generate_series(1, 100) s);
```

### Создание пользователя в БД и предоставление ему прав ###   
Пользователем gpadmin был создан пользователь testuser и ему предоставлены права на схему schema1 и таблицу в этой схеме:   
```
create role testuser 
  with login connection limit -1 
  resource group default_group
  password 'testuser';
grant usage on schema schema1 to testuser;
grant select on schema1.t1 to testuser;
```
Пользователь testuser без ошибок выполняет запрос:   
```
select * from schema1.t1;
```
Но при выполнении следующего запроса:   
```
select * from schema2.t2;
```
возникла ошибка:   
SQL Error [42501]: ERROR: permission denied for schema schema2   
