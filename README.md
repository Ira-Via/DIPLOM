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
5. [Резервное копирование данных](#title5):
   - Настройка автоматизированное резервное копирование баз данных и файловой системы.
   - Использование Yandex Cloud Storage для хранения резервных копий.
6. [Управление безопасностью](#title6):
   - Настройка IAM  для управления доступом.
   - Обеспечение безопасности секретов, используя хранилища для секретов.
7. [Тестирование отказоустойчивости](#title7):
   - Тестирование на случай сбоев и аварий.
   - Оценка времи восстановления и доступность системы после сбоя.
8. [Оптимизация и улучшение инфраструктуры](#title8):
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

## <a id="title3">3. Настройка мониторинга</a>

## <a id="title4">4. Сбор логов</a>

## <a id="title5">5. Резервное копирование данных</a>

## <a id="title6">6. Управление безопасностью</a>

## <a id="title7">7. Тестирование отказоустойчивости</a>

## <a id="title8">8. Оптимизация и улучшение инфраструктуры</a>
