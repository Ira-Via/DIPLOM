# DIPLOM
# Дипломная работа по профессии «Системный администратор» Васяева Ирина
### План дипломной работы по профессии «Системный администратор» Васяева Ирина
1. [Проектирование архитектуры](#title1):
   - Определяем основные компоненты инфраструктуры
   - Выбираем подход
2. [Создание окружения](#title2):
   - Настройка VPC для изоляции ресурсов.
   - Создание балансировщик нагрузки для распределения трафика.
3. [Настройка мониторинга](#title3):
   - Использование Yandex Monitoring или сторонние инструменты.
   - Настройка алерты для отслеживания состояния системы.
4. [Сбор логов](#title4):
   - Определение стратегии сбора и хранения логов.
   - Использование Yandex Log Storage или интегрирование ELK-стек для аналитики.
5. [Настройка сети](#title5):
   - Разворачиваем VPC с публичной и приватной подсетями, разместив серверы web и Elasticsearch в приватных подсетях, а Zabbix, Kibana и application load balancer — в публичной.
   - Настройка Security Groups для ограничения входящего трафика, установика bastion host с открытым только SSH портом для подключения к приватным серверам через ProxyCommand, а также обеспечьте исходящий доступ в интернет для внутренних ВМ через NAT-шлюз.
6. [Резервное копирование данных](#title6):
   - Настройка автоматизированное резервное копирование баз данных и файловой системы.
   - Использование Yandex Cloud Storage для хранения резервных копий.
7. [Управление безопасностью](#title7):
   - Настройка IAM  для управления доступом.
   - Обеспечение безопасности секретов, используя хранилища для секретов.
8. [Тестирование отказоустойчивости](#title8):
   - Тестирование на случай сбоев и аварий.
   - Оценка времи восстановления и доступность системы после сбоя.
9. [Оптимизация и улучшение инфраструктуры](#title9):
   - На основе собранных данных и тестирования определяем возможности для улучшения.
   - Периодически пересматривание архитектуры и стратегии мониторинга, резервного копирования и безопасности.
## <a id="title1">1. Проектирование архитектуры</a>
1. Определение основных компонентов инфраструктуры
Для начала необходимо определить, какие компоненты будут включены в вашу инфраструктуру. Это могут быть:
- Виртуальные машины (ВМ): минимальные конфигурации, как указано в условии (2 ядра, 2-4 Гб памяти, 10 HDD).
- Сеть: настройка VPC, подсетей и маршрутизации.
- Безопасность: группы безопасности, правила фаервола.
- Мониторинг и логирование: инструменты для отслеживания состояния ВМ и логов.
2. Выбор подхода
С учетом требований, вы будете использовать Terraform для создания и управления инфраструктурой, а Ansible для автоматизации конфигурации ВМ.
- Terraform: создаст необходимые ресурсы в облаке (например, в Yandex Cloud).
- Ansible: будет использоваться для установки и настройки программного обеспечения на созданных ВМ.
3. Создание конфигурации Terraform
Создайте файл main.tf, в котором опишите необходимые ресурсы. Пример конфигурации для создания одной ВМ:
```
provider "yandex" {
  token     = "<YOUR_YANDEX_TOKEN>"
  cloud_id = "<YOUR_CLOUD_ID>"
  folder_id = "<YOUR_FOLDER_ID>"
}

resource "yandex_compute_instance" "example" {
  name        = "example"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    disk_id = yandex_compute_disk.example.id
  }
  network_interface {
    subnet_id = "<YOUR_SUBNET_ID>"
    nat       = true
  }
  metadata = {
    hostname = "example"
  }
}

resource "yandex_compute_disk" "example" {
  name   = "example-disk"
  type   = "network-ssd"
  size   = 10
}
```
4. Настройка Ansible
Создайте файл inventory.yml, используя FQDN имена ВМ:
```
all:
  hosts:
    example.ru-central1.internal:
```
Затем создайте плейбук playbook.yml для настройки ВМ:
```
- hosts: all
  tasks:
    - name: Установка необходимых пакетов
      apt:
        name: "{{ item }}"
        state: present
      loop:
        - nginx
        - git
```
5. Превращение прерываемых ВМ в постоянно работающие
Перед сдачей работы, измените настройки ВМ в Terraform, чтобы они стали постоянными. Это может включать изменение типа ВМ с прерываемого на стандартный или изменение конфигурации в облачном провайдере.
6. Тестирование и проверка
После развертывания инфраструктуры с помощью Terraform и настройки с помощью Ansible, убедитесь, что все работает корректно:
- Проверьте доступность ВМ по FQDN.
- Убедитесь, что установленные пакеты работают.
- Проверьте, что ВМ работают постоянно.
## <a id="title2">2. Создание окружения</a>
1. Настройка VPC
Для начала создайте VPC, который будет изолировать ваши ресурсы. В файле main.tf добавьте следующие ресурсы:
```
resource "yandex_vpc_network" "my_network" {
  name = "my-network"
}

resource "yandex_vpc_subnet" "my_subnet" {
  name           = "my-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my_network.id
  v4_cidr_block  = "192.168.0.0/24"
}
```
Создайте аналогичную подсеть в другой зоне, например, ru-central1-b.
2. Создание ВМ
Создайте две ВМ в разных зонах, используя одинаковую конфигурацию:
```
resource "yandex_compute_instance" "web_server_a" {
  name        = "web-server-a"
  zone        = "ru-central1-a"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "<YOUR_IMAGE_ID>"
      size     = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.my_subnet.id
    nat       = false
  }
  metadata = {
    hostname = "web-server-a"
  }
}

resource "yandex_compute_instance" "web_server_b" {
  name        = "web-server-b"
  zone        = "ru-central1-b"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = "<YOUR_IMAGE_ID>"
      size     = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.my_subnet.id
    nat       = false
  }
  metadata = {
    hostname = "web-server-b"
  }
}
```
3. Настройка Ansible
Создайте inventory.yml, используя FQDN имена:
```
all:
  hosts:
    web-server-a.ru-central1.internal:
    web-server-b.ru-central1.internal:
Создайте плейбук playbook.yml для установки Nginx и копирования статических файлов:

- hosts: all
  tasks:
    - name: Установка Nginx
      apt:
        name: nginx
        state: present

    - name: Копирование статических файлов
      copy:
        src: /path/to/your/static/files/
        dest: /var/www/html/
```
4. Настройка балансировщика нагрузки
Добавьте ресурсы для балансировщика нагрузки в main.tf:
```
resource "yandex_lb_network_load_balancer" "my_lb" {
  name = "my-load-balancer"
  region = "ru-central1"
  
  listener {
    name = "listener-1"
    port = 80
    protocol = "TCP"
  }

  backend_group {
    name = "backend-group"
    target_group_id = yandex_lb_target_group.my_target_group.id
  }
}

resource "yandex_lb_target_group" "my_target_group" {
  name = "my-target-group"

  healthcheck {
    interval = 5
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
    protocol = "HTTP"
    port = 80
    path = "/"
  }

  backend {
    target_id = yandex_compute_instance.web_server_a.id
    port = 80
  }

  backend {
    target_id = yandex_compute_instance.web_server_b.id
    port = 80
  }
}

resource "yandex_lb_http_router" "my_http_router" {
  name = "my-http-router"

  rule {
    path = "/"
    backend_group_id = yandex_lb_target_group.my_target_group.id
  }
}
```
5. Тестирование
После развертывания всех ресурсов и настройки Nginx, протестируйте сайт с помощью curl:
```
curl -v http://<PUBLIC_IP_LOAD_BALANCER>:80
```
## <a id="title3">3. Настройка мониторинга</a>
1. Развертывание Zabbix на ВМ
- Создайте ВМ:
  - Выберите подходящую платформу (например, AWS, GCP, Azure или локальный сервер).
  - Установите операционную систему (рекомендуется использовать Ubuntu или CentOS).
- Установите Zabbix Server:
  - Обновите систему:
```
sudo apt update && sudo apt upgrade -y
```
  - Установите необходимые пакеты:
```
sudo apt install wget curl gnupg2 -y
```
  - Добавьте репозиторий Zabbix:
```
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix/zabbix-release_6.0-2+ubuntu20.04_all.deb
sudo dpkg -i zabbix-release_6.0-2+ubuntu20.04_all.deb
sudo apt update
```
  - Установите Zabbix Server, веб-интерфейс и базу данных (например, PostgreSQL):
```
sudo apt install zabbix-server-pgsql zabbix-frontend-php zabbix-agent -y
```
  - Настройте базу данных и пользователя для Zabbix.
- Настройка конфигурации Zabbix:
  - Отредактируйте файл конфигурации Zabbix Server:
```
sudo nano /etc/zabbix/zabbix_server.conf
```
  - Укажите параметры подключения к базе данных.
- Запустите Zabbix Server:
```
sudo systemctl start zabbix-server
sudo systemctl enable zabbix-server
```
2. Установка Zabbix Agent на другие ВМ
- Установите Zabbix Agent:
  - На каждой целевой ВМ выполните:
```
sudo apt install zabbix-agent -y
```
- Настройте Zabbix Agent:
  - Отредактируйте файл конфигурации агента:
```
sudo nano /etc/zabbix/zabbix_agentd.conf
```
- Укажите IP-адрес Zabbix Server в параметре Server и ServerActive.
  - Запустите Zabbix Agent:
```
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent
```
3. Настройка дешбордов и алертов
- Добавьте хосты в Zabbix:  
В веб-интерфейсе Zabbix перейдите в раздел Configuration > Hosts и добавьте ваши ВМ как хосты.
- Настройка шаблонов:  
Используйте встроенные шаблоны для мониторинга CPU, RAM, дисков, сети и HTTP-запросов.  
Примените шаблоны к вашим хостам.  
- Создание дешбордов:  
Перейдите в раздел Dashboard и создайте новый дешборд.  
Добавьте виджеты для отображения метрик по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, дисков, сети и HTTP-запросов.
- Настройка алертов:  
В разделе Configuration > Actions создайте новые действия для отправки уведомлений при превышении порогов.  
Установите необходимые thresholds для CPU, RAM и других метрик.
4. Тестирование  
Проверьте работоспособность системы, убедитесь, что метрики отображаются на дешбордах и алерты срабатывают при превышении порогов.
## <a id="title4">4. Сбор логов</a>
1. Создание виртуальных машин (ВМ)
- Создайте две виртуальные машины:
  - ВМ 1: Для Elasticsearch.
  - ВМ 2: Для Kibana и Filebeat.
2. Установка Elasticsearch
- Подключитесь к ВМ 1 через SSH.
- Обновите пакеты:
```
sudo apt update
sudo apt upgrade
```
- Установите Java (Elasticsearch требует Java):
```
sudo apt install openjdk-11-jdk
```
- Добавьте репозиторий Elasticsearch и установите его:
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt install elasticsearch
```
- Запустите и активируйте Elasticsearch:
```
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
```
3. Установка Filebeat на веб-сервер
- Подключитесь к ВМ 2 через SSH.
- Обновите пакеты:
```
sudo apt update
sudo apt upgrade
```
- Добавьте репозиторий Filebeat и установите его:
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt install filebeat
```
- Настройте Filebeat для отправки логов nginx:
  - Откройте файл конфигурации Filebeat:
```
sudo nano /etc/filebeat/filebeat.yml
```
  - Найдите секцию filebeat.inputs и добавьте конфигурацию для nginx:
```
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/nginx/access.log
      - /var/log/nginx/error.log
```
  - Настройте выходные данные для Elasticsearch:
```
output.elasticsearch:
  hosts: ["http://<IP_Elasticsearch_VM>:9200"]
```
- Запустите Filebeat:
```
sudo systemctl start filebeat
sudo systemctl enable filebeat
```
4. Установка Kibana
- Подключитесь к ВМ 2 через SSH.
- Добавьте репозиторий Kibana и установите его:
```
sudo apt update
sudo apt install kibana
```
- Настройте Kibana для подключения к Elasticsearch:
  - Откройте файл конфигурации Kibana:
```
sudo nano /etc/kibana/kibana.yml
```
  - Настройте elasticsearch.hosts:
```
elasticsearch.hosts: ["http://<IP_Elasticsearch_VM>:9200"]
```
- Запустите и активируйте Kibana:
```
sudo systemctl start kibana
sudo systemctl enable kibana
```
5. Доступ к Kibana
- Откройте веб-браузер и перейдите по адресу:
```
http://<IP_Kibana_VM>:5601
```
- Настройте индекс для отображения логов в Kibana.
## <a id="title5">5. Настройка сети</a>

## <a id="title6">6. Резервное копирование данных</a>
1. Создание снимков дисков ВМ
- Войдите в Yandex Cloud Console.
- Перейдите в раздел "Compute Cloud".
- Выберите виртуальные машины, для которых вы хотите создать снимки.
- Создайте снимок для каждой ВМ:
  - Выберите нужную ВМ и перейдите в её настройки.
  - Нажмите на кнопку "Создать снимок".
  - Укажите имя снимка и выберите диск, для которого хотите создать снимок.
  - Нажмите "Создать".
2. Настройка автоматического создания снимков
Для автоматизации процесса создания снимков можно использовать Yandex Cloud Functions или Yandex Cloud Scheduler. Рассмотрим использование Yandex Cloud Scheduler:  
- Создайте функцию для создания снимков:
  - Перейдите в раздел "Yandex Cloud Functions".
  - Нажмите "Создать функцию".
  - Выберите язык программирования (например, Python).
  - Введите код, который будет создавать снимки:
```
import os
import yandexcloud
from yandexcloud import SDK

def create_snapshot(event, context):
    sdk = SDK()
    compute = sdk.client('compute')
    
    # Замените на ID вашей ВМ
    vm_ids = ['<YOUR_VM_ID_1>', '<YOUR_VM_ID_2>']
    
    for vm_id in vm_ids:
        snapshot_name = f'snapshot-{vm_id}-{int(time.time())}'
        compute.create_snapshot(
            folder_id='<YOUR_FOLDER_ID>',
            name=snapshot_name,
            disk_id=vm_id
        )
```
- Настройте триггер для запуска функции:
  - Перейдите в раздел "Yandex Cloud Scheduler".
  - Создайте новую задачу, выбрав вашу функцию.
  - Установите расписание на ежедневное выполнение.
3. Ограничение времени жизни снимков
Чтобы ограничить время жизни снимков, вы можете использовать Yandex Cloud Functions для удаления старых снимков. Вот пример кода для удаления снимков старше недели:
```
import time
from datetime import datetime, timedelta
import yandexcloud
from yandexcloud import SDK

def delete_old_snapshots(event, context):
    sdk = SDK()
    compute = sdk.client('compute')
    
    # Получаем список всех снимков
    snapshots = compute.list_snapshots(folder_id='<YOUR_FOLDER_ID>')
    
    # Устанавливаем дату, старше которой снимки будут удалены
    expiration_date = datetime.now() - timedelta(weeks=1)

    for snapshot in snapshots:
        if snapshot.created_at < expiration_date:
            compute.delete_snapshot(snapshot.id)
```
4. Настройка автоматического удаления старых снимков
- Создайте новую функцию в Yandex Cloud Functions для удаления старых снимков.
- Настройте триггер для запуска этой функции, например, раз в неделю.
5. Хранение резервных копий в Yandex Cloud Storage
Если вы хотите дополнительно хранить резервные копии в Yandex Cloud Storage, вы можете использовать команду yc storage cp для копирования файлов или снимков в облачное хранилище. Например:
```
yc storage cp /path/to/snapshot s3://your-bucket-name/
```
## <a id="title7">7. Управление безопасностью</a>
1. Настройка IAM для управления доступом
- Войдите в Yandex Cloud Console.
- Перейдите в раздел "IAM & управление доступом".
- Создайте роли:
  - Нажмите на "Роли" и затем "Создать роль".
  - Укажите имя роли и добавьте необходимые разрешения для доступа к ресурсам (например, доступ к Compute Cloud, Cloud Storage и другим сервисам).
- Создайте пользователей:
  - Перейдите в раздел "Пользователи".
  - Нажмите "Создать пользователя" и укажите имя пользователя, адрес электронной почты и другие необходимые данные.
- Назначьте роли пользователям:
  - Выберите пользователя и перейдите в его настройки.
  - В разделе "Роли" нажмите "Добавить роль" и выберите ранее созданные роли.
2. Настройка хранилища секретов
- Перейдите в раздел "Secrets Manager" в Yandex Cloud Console.
- Создайте новое хранилище секретов:
  - Нажмите "Создать секрет".
  - Укажите имя секрета и добавьте ключ-значение (например, для хранения паролей, API-ключей и других конфиденциальных данных).
- Настройте доступ к секретам:
  - В разделе "Доступ" укажите, какие пользователи или сервисы могут получить доступ к этому секрету.
  - Выберите роли, которые будут иметь доступ к чтению или изменению секрета.
- Использование секретов в приложениях:
  - Для доступа к секретам в приложениях используйте Yandex Cloud SDK или API, чтобы извлекать секреты по мере необходимости.
3. Применение лучших практик безопасности
- Регулярно пересматривайте права доступа:  
  - Периодически проверяйте назначенные роли и права доступа пользователей, чтобы убедиться, что они соответствуют текущим требованиям.  
- Используйте многофакторную аутентификацию (MFA):  
  - Включите MFA для пользователей, чтобы повысить уровень безопасности при входе в систему.
- Логирование и мониторинг:
  - Настройте логирование доступа и мониторинг активности в Yandex Cloud для отслеживания действий пользователей и обнаружения подозрительной активности.
- Шифрование данных:
  - Убедитесь, что данные, как в хранилище, так и в базе данных, шифруются как при передаче, так и при хранении.
## <a id="title8">8. Тестирование отказоустойчивости</a>

## <a id="title9">9. Оптимизация и улучшение инфраструктуры</a>
