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
* Remove service
* Upgrade cluster bundle
* Remove bundle
* Edit object ansible config
* Cluster Action: Activate standby
* Cluster Action: Activate standby postprocess
* Cluster Action: Check
* Cluster Action: Expand
* Cluster Action: Init Standby Master
* Cluster Action: Install
* Cluster Action: Post upgrade changes
* Cluster Action: Precheck
* Cluster Action: Reconfigure parameter archiving
* Cluster Action: Redistribute
* Cluster Action: Reinstall
* Cluster Action: Reinstall statuschecker
* Cluster Action: Start
* Cluster Action: Stop
* Cluster Action: Upgrade
* Service Action: Create database
* Service Action: Create role
* Service Action: Disable auto core dump
* Service Action: Enable auto core dump
* Service Action: Enable mirroring
* Service Action: Init cluster
* Service Action: Install ADB
* Service Action: Install diskquota
* Service Action: Install PostGIS
* Service Action: Reconfigure
* Service Action: Reinstall ADB
* Service Action: Reinstall diskquota
* Service Action: Reinstall PostGIS
* Service Action: Run SQL
* Service Action: Start
* Service Action: Stop
* Service Action: Uninstall diskquota
* Service Action: Uninstall PostGIS
* Service Action: Manage tablespace
* Service Action: Delete
* Service Action: Install
* Service Action: Reinstall
* Service Action: Uninstall
* Service Action: Restart
* Cluster Action: Remove
* Cluster Action: Upgrade: 4.1.0-1
* Service Action: Uninstall Diamond
