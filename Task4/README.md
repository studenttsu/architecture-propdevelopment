# Настройка RBAC для кластера Kubernetes PropDevelopment

## Описание

Данное решение реализует ролевой доступ к кластеру Kubernetes для различных групп пользователей компании PropDevelopment в соответствии с принципом минимальных привилегий.

## Структура ролей

В системе определены следующие роли:

1. **cluster-admin** - полный доступ ко всем ресурсам кластера
2. **namespace-admin** - полный доступ к ресурсам в определенном namespace
3. **developer** - чтение и ограниченное обновление ресурсов
4. **devops-engineer** - управление инфраструктурными ресурсами
5. **viewer** - только чтение ресурсов
6. **security-auditor** - чтение всех ресурсов для аудита безопасности

## Созданные пользователи

В рамках данного решения созданы два пользователя:

1. **developer-ivan** - разработчик, роль: developer
2. **devops-maria** - DevOps-инженер, роль: devops-engineer

## Порядок выполнения скриптов

### Предварительные требования

- Установленный и настроенный kubectl
- Доступ к кластеру Kubernetes с правами администратора
- Установленный OpenSSL
- Операционная система Linux или macOS (для Windows используйте WSL или Git Bash)

### Шаг 1: Создание пользователей

```bash
chmod +x 01-create-users.sh
./01-create-users.sh
```

Скрипт выполняет следующие действия:
- Генерирует приватный ключ для каждого пользователя
- Создает запрос на подпись сертификата (CSR)
- Отправляет CSR в Kubernetes API
- Одобряет CSR
- Получает подписанный сертификат

Результат: для каждого пользователя создается директория с ключами и сертификатами.

### Шаг 2: Создание kubeconfig файлов

```bash
chmod +x 02-create-kubeconfig.sh
./02-create-kubeconfig.sh
```

Скрипт выполняет следующие действия:
- Получает информацию о кластере из текущего kubeconfig
- Создает kubeconfig файл для каждого пользователя
- Настраивает контекст для работы с кластером

Результат: для каждого пользователя создается файл `<username>-kubeconfig.yaml`.

### Шаг 3: Создание ролей

```bash
chmod +x 03-create-roles.sh
./03-create-roles.sh
```

Скрипт создает следующие роли:
- Role: developer (в namespace default)
- Role: devops-engineer (в namespace default)
- Role: viewer (в namespace default)
- ClusterRole: security-auditor (на уровне кластера)

### Шаг 4: Привязка пользователей к ролям

```bash
chmod +x 04-bind-users-to-roles.sh
./04-bind-users-to-roles.sh
```

Скрипт создает RoleBinding для связывания пользователей с ролями:
- developer-ivan → developer
- devops-maria → devops-engineer

### Шаг 5: Проверка доступа

Проверка прав пользователя developer-ivan:

```bash
# Просмотр pods (должно работать)
kubectl --kubeconfig=developer-ivan/developer-ivan-kubeconfig.yaml get pods

# Создание deployment (должно работать)
kubectl --kubeconfig=developer-ivan/developer-ivan-kubeconfig.yaml create deployment test --image=nginx

# Удаление deployment (должно быть запрещено)
kubectl --kubeconfig=developer-ivan/developer-ivan-kubeconfig.yaml delete deployment test
```

Проверка прав пользователя devops-maria:

```bash
# Просмотр pods (должно работать)
kubectl --kubeconfig=devops-maria/devops-maria-kubeconfig.yaml get pods

# Создание deployment (должно работать)
kubectl --kubeconfig=devops-maria/devops-maria-kubeconfig.yaml create deployment test --image=nginx

# Удаление deployment (должно работать)
kubectl --kubeconfig=devops-maria/devops-maria-kubeconfig.yaml delete deployment test

# Просмотр secrets (должно работать)
kubectl --kubeconfig=devops-maria/devops-maria-kubeconfig.yaml get secrets
```

## Детальное описание прав ролей

### Роль: developer

Права:
- Просмотр: pods, services, configmaps, events, deployments, replicasets, statefulsets
- Создание/обновление: deployments, replicasets, statefulsets
- Запрещено: удаление ресурсов, доступ к secrets

Группы пользователей: разработчики, бизнес-аналитики

### Роль: devops-engineer

Права:
- Полный доступ к: pods, services, configmaps, secrets, persistentvolumeclaims, deployments, replicasets, statefulsets, daemonsets, ingresses, networkpolicies, jobs, cronjobs
- Просмотр: events

Группы пользователей: DevOps-инженеры, инженеры по эксплуатации

### Роль: viewer

Права:
- Только просмотр: pods, services, configmaps, events, deployments, replicasets, statefulsets, ingresses

Группы пользователей: менеджеры проектов, аналитики BI, специалисты по ИБ

### ClusterRole: security-auditor

Права:
- Просмотр всех ресурсов кластера
- Просмотр RBAC политик
- Просмотр network policies
- Просмотр pod security policies

Группы пользователей: специалисты по информационной безопасности

## Безопасность

### Рекомендации по безопасности

1. **Хранение сертификатов**
   - Сертификаты и ключи пользователей должны храниться в защищенном месте
   - Не передавайте приватные ключи по незащищенным каналам
   - Регулярно ротируйте сертификаты (рекомендуется раз в год)

2. **Управление доступом**
   - Регулярно проверяйте и обновляйте список пользователей
   - Удаляйте доступ для уволенных сотрудников
   - Используйте принцип минимальных привилегий

3. **Аудит**
   - Включите аудит логирование в Kubernetes
   - Регулярно проверяйте логи доступа
   - Мониторьте подозрительную активность

4. **Namespace изоляция**
   - Используйте отдельные namespace для разных окружений (dev, staging, production)
   - Настройте Network Policies для изоляции трафика
   - Ограничьте доступ к production namespace

## Расширение решения

### Добавление нового пользователя

1. Добавьте имя пользователя в массив USERS в скриптах 01 и 02
2. Выполните скрипты 01 и 02 заново
3. Создайте RoleBinding для нового пользователя в скрипте 04

### Создание роли для нового namespace

```bash
kubectl create namespace production

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: production
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "services", "configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
EOF

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-ivan-production-binding
  namespace: production
subjects:
- kind: User
  name: developer-ivan
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
EOF
```

## Устранение неполадок

### Ошибка: certificate signing request not found

Проблема: CSR не был создан или уже был удален.

Решение:
```bash
kubectl get csr
kubectl delete csr <username>
./01-create-users.sh
```

### Ошибка: forbidden: User cannot create resource

Проблема: у пользователя нет прав на выполнение операции.

Решение: проверьте привязку пользователя к роли и права роли.

```bash
kubectl get rolebinding -n default
kubectl describe role <role-name> -n default
```

### Ошибка: unable to connect to the server

Проблема: неправильная конфигурация kubeconfig.

Решение: проверьте параметры кластера в kubeconfig файле.

```bash
kubectl --kubeconfig=<username>/<username>-kubeconfig.yaml config view
```

## Соответствие требованиям задания

Данное решение полностью соответствует требованиям задания:

1. Поднят пустой Minikube (предполагается выполнение на локальной машине)
2. Определены все роли и их полномочия при работе с Kubernetes
3. Подготовлены скрипты для создания минимум двух пользователей (developer-ivan, devops-maria)
4. Подготовлены скрипты для создания ролей в соответствии с RBAC
5. Подготовлены скрипты для связывания пользователей с ролями
6. Заполнена таблица с ролями, правами и группами пользователей

Все скрипты готовы к выполнению и отражают решения, полученные в результате работы над предыдущими заданиями.
