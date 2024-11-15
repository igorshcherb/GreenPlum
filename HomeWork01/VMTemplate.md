## Создание шаблона виртуальных машин ##

- Установка Ubuntu 22.04.5.   
  Доменное имя: home1.ru   
  Галочка "Дополнения гостевой ОС"   
  Оборудование: 16 Гб памяти, 4 ЦП, 50 Гб диск. Создать новый виртуальный диск. Нет галочки "Выделить место в полном размере".   
  Проверка версии ОС: $ uname -a   
- Видеопамять: 128 Мб   
- Настройки -> Сеть -> Тип подключения: Сетевой мост   
- Разрешение экрана: Settings -> Displays -> Resolution -> 1920 x 1200.   
- Добавление русского языка: Settings -> Region&Language -> Manage Installed Language -> [Install / Remove Languages] -> русский   
- Добавить русскую раскладку клавиатуры: Settings -> Keyboard -> Input sources -> '+': Russian   
- Устранение ошибки запуска терминала: Settings -> Region&Language -> Login Screen -> Language: English(United States)   
- Добавление значка терминала на панель: Show applications -> Terminal -> Add to favorites   
- Запрет автоматического обновления: Software&Updates -> Updates -> Automatically check for updates: Never   
- Установка параметра буфера обмена в VirtualBox: Настройки -> Общие -> Дополнительно -> Общий буфер обмена: Двунаправленный   
- Установка параметра буфера обмена в окне ВМ: в окне ВМ: Устройства -> Общий буфер обмена: Двунаправленный   
- Убрать выключение экрана: Settings -> Power -> Screen blank: Never   
- Установка дополнений гостевой ОС (требуется для работы буффера обмена и общих папок): в окне ВМ: Устройства ->    
    Подключить образ диска Дополнений гостевой ОС.   
  Через Files открыть папку VBox_GAs_7.0.22, запустить файл autorun.sh, перезапустить ВМ.   
- Добавление общей папки в VirtualBox: остановить ВМ, Настройки -> Общие папки -> Добавить.   
  Имя папки: shared   
  Точка подключения: /home/<user_name>/shared   
  Авто-подключение: Да   
  Запустить ВМ.   
- Добавление пользователя admn в администраторы:   
  $ su root   
  $ nano /etc/sudoers   
  admn ALL=(ALL:ALL)ALL   
  $ exit   
- Задание пароля root-у:   
  $ sudo -i   
  $ sudo passwd   
- Установка Docker-а:   
  $ sudo apt update   
  $ sudo apt-get install docker.io   
- Установка netstat:   
  $ sudo apt install net-tools   
- Установка curl:   
  $ sudo snap install curl   
- Установка ssh:   
  $ sudo apt install openssh-server  
- Установка Midnight Commander   
  sudo apt -y install mc
