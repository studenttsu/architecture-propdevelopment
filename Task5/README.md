# Управление трафиком внутри кластера Kubernetes

## Описание задания

Данное решение реализует разграничение трафика между сервисами в кластере Kubernetes с помощью Network Policies. Задача состоит в том, чтобы изолировать трафик к новым сервисам и запретить другим подам взаимодействовать с ними.

## Архитектура решения

В кластере развернуты четыре сервиса:

1. **front-end-app** (метка: `role=front-end`) - пользовательский интерфейс
2. **back-end-api-app** (метка: `role=back-end-api`) - API для пользовательского интерфейса
3. **admin-front-end-app** (метка: `role=admin-front-end`) - административный интерфейс
4. **admin-back-end-api-app** (метка: `role=admin-back-end-api`) - API для административного интерфейса

## Правила сетевых политик

Сетевые политики настроены следующим образом:

### 1. NetworkPolicy: non-admin-api-allow

Разрешает входящий трафик к `back-end-api` только от подов с меткой `role=front-end`.

```yaml
spec:
  podSelector:
    matchLabels:
      role: back-end-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: front-end
```

**Эффект:** Только `front-end` может обращаться к `back-end-api`.

### 2. NetworkPolicy: admin-api-allow

Разрешает входящий трафик к `admin-back-end-api` только от подов с меткой `role=admin-front-end`.

```yaml
spec:
  podSelector:
    matchLabels:
      role: admin-back-end-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: admin-front-end
```

**Эффект:** Только `admin-front-end` может обращаться к `admin-back-end-api`.

### 3. NetworkPolicy: front-end-allow

Разрешает весь входящий трафик к `front-end`.

```yaml
spec:
  podSelector:
    matchLabels:
      role: front-end
  policyTypes:
  - Ingress
  ingress:
  - {}
```

**Эффект:** `front-end` доступен для всех.

### 4. NetworkPolicy: admin-front-end-allow

Разрешает весь входящий трафик к `admin-front-end`.

```yaml
spec:
  podSelector:
    matchLabels:
      role: admin-front-end
  policyTypes:
  - Ingress
  ingress:
  - {}
```

**Эффект:** `admin-front-end` доступен для всех.

## Матрица доступа

| От \ К | front-end | back-end-api | admin-front-end | admin-back-end-api |
|--------|-----------|--------------|-----------------|-------------------|
| **front-end** | ✓ | ✓ | ✓ | ✗ |
| **back-end-api** | ✓ | ✓ | ✓ | ✗ |
| **admin-front-end** | ✓ | ✗ | ✓ | ✓ |
| **admin-back-end-api** | ✓ | ✗ | ✓ | ✓ |
| **Другие поды** | ✓ | ✗ | ✓ | ✗ |

✓ - доступ разрешен  
✗ - доступ запрещен

## Порядок выполнения

### Предварительные требования

- Установленный и настроенный kubectl
- Доступ к кластеру Kubernetes (Minikube или другой)
- Включенный Network Policy provider (например, Calico, Cilium, или встроенный в Minikube)

Для Minikube убедитесь, что Network Policy включен:
```bash
minikube start --network-plugin=cni --cni=calico
```

### Шаг 1: Развертывание сервисов

```bash
chmod +x 01-deploy-services.sh
./01-deploy-services.sh
```

Скрипт выполняет следующие действия:
- Создает namespace `task5`
- Развертывает четыре пода с образом nginx
- Назначает каждому поду соответствующую метку
- Создает Service для каждого пода
- Проверяет статус развертывания

Результат: четыре работающих пода и четыре сервиса в namespace `task5`.

### Шаг 2: Применение сетевых политик

```bash
chmod +x 02-create-network-policies.sh
./02-create-network-policies.sh
```

Скрипт выполняет следующие действия:
- Применяет файл `non-admin-api-allow.yaml` с четырьмя Network Policies
- Проверяет созданные политики
- Выводит детальную информацию о каждой политике

Результат: четыре активных Network Policy в namespace `task5`.

### Шаг 3: Проверка работы сетевых политик

```bash
chmod +x 03-test-network-policies.sh
./03-test-network-policies.sh
```

Скрипт выполняет пять тестов:

1. **Тест 1:** front-end → back-end-api (должен быть разрешен)
2. **Тест 2:** admin-front-end → admin-back-end-api (должен быть разрешен)
3. **Тест 3:** front-end → admin-back-end-api (должен быть запрещен)
4. **Тест 4:** admin-front-end → back-end-api (должен быть запрещен)
5. **Тест 5:** случайный под → back-end-api (должен быть запрещен)

Ожидаемые результаты: все тесты должны завершиться с SUCCESS.

## Детальное описание файла non-admin-api-allow.yaml

Файл содержит четыре Network Policy:

### 1. non-admin-api-allow

Защищает `back-end-api` от несанкционированного доступа.

- **podSelector:** выбирает поды с меткой `role=back-end-api`
- **policyTypes:** Ingress (входящий трафик)
- **ingress.from:** только от подов с меткой `role=front-end`
- **ports:** TCP порт 80

### 2. admin-api-allow

Защищает `admin-back-end-api` от несанкционированного доступа.

- **podSelector:** выбирает поды с меткой `role=admin-back-end-api`
- **policyTypes:** Ingress (входящий трафик)
- **ingress.from:** только от подов с меткой `role=admin-front-end`
- **ports:** TCP порт 80

### 3. front-end-allow

Разрешает доступ к `front-end` для всех.

- **podSelector:** выбирает поды с меткой `role=front-end`
- **policyTypes:** Ingress (входящий трафик)
- **ingress:** пустой список (разрешает весь трафик)

### 4. admin-front-end-allow

Разрешает доступ к `admin-front-end` для всех.

- **podSelector:** выбирает поды с меткой `role=admin-front-end`
- **policyTypes:** Ingress (входящий трафик)
- **ingress:** пустой список (разрешает весь трафик)

## Принципы работы Network Policies

### Модель по умолчанию

В Kubernetes по умолчанию весь трафик между подами разрешен. Network Policy работает по принципу "белого списка" - если для пода определена хотя бы одна Network Policy, то разрешен только трафик, явно указанный в политиках.

### Селекторы

Network Policy использует селекторы меток для определения:
- К каким подам применяется политика (podSelector)
- От каких подов разрешен трафик (ingress.from.podSelector)
- К каким подам разрешен трафик (egress.to.podSelector)

### Типы политик

- **Ingress:** контролирует входящий трафик к подам
- **Egress:** контролирует исходящий трафик от подов

В данном решении используются только Ingress политики.

## Безопасность

### Преимущества данного подхода

1. **Изоляция сервисов:** API сервисы изолированы от прямого доступа
2. **Принцип минимальных привилегий:** каждый сервис имеет доступ только к необходимым ресурсам
3. **Защита от lateral movement:** злоумышленник, получивший доступ к одному поду, не может свободно перемещаться по кластеру
4. **Разделение административных и пользовательских сервисов:** admin API изолирован от обычных пользователей

### Рекомендации

1. **Используйте namespace:** разделяйте окружения (dev, staging, production) по namespace
2. **Применяйте default deny:** создайте политику, запрещающую весь трафик по умолчанию
3. **Логируйте трафик:** используйте инструменты мониторинга для отслеживания сетевого трафика
4. **Регулярно проверяйте политики:** аудит Network Policies должен быть частью процесса безопасности

## Расширение решения

### Добавление Egress политик

Для полного контроля трафика можно добавить Egress политики:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: front-end-egress
  namespace: task5
spec:
  podSelector:
    matchLabels:
      role: front-end
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: back-end-api
    ports:
    - protocol: TCP
      port: 80
  - to:
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
```

### Default Deny политика

Для максимальной безопасности можно создать политику, запрещающую весь трафик по умолчанию:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: task5
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

После применения этой политики нужно будет явно разрешить весь необходимый трафик.

## Устранение неполадок

### Network Policy не работает

**Проблема:** Трафик не блокируется, несмотря на наличие Network Policy.

**Возможные причины:**
1. Network Policy provider не установлен в кластере
2. Network Policy provider не поддерживается CNI плагином

**Решение:**
```bash
# Проверьте, какой CNI плагин используется
kubectl get pods -n kube-system

# Для Minikube убедитесь, что Calico включен
minikube start --network-plugin=cni --cni=calico

# Проверьте статус Network Policies
kubectl get networkpolicies -n task5
```

### Тесты не проходят

**Проблема:** Тесты показывают неожиданные результаты.

**Решение:**
```bash
# Проверьте метки подов
kubectl get pods -n task5 --show-labels

# Проверьте, что поды работают
kubectl get pods -n task5

# Проверьте логи Network Policy provider
kubectl logs -n kube-system -l k8s-app=calico-node
```

### Доступ запрещен там, где должен быть разрешен

**Проблема:** Легитимный трафик блокируется.

**Решение:**
```bash
# Проверьте правильность меток в Network Policy
kubectl describe networkpolicy <policy-name> -n task5

# Проверьте метки подов
kubectl get pod <pod-name> -n task5 --show-labels

# Убедитесь, что порты совпадают
kubectl get svc -n task5
```

## Очистка ресурсов

Для удаления всех созданных ресурсов:

```bash
kubectl delete namespace task5
```

Это удалит namespace и все ресурсы внутри него (поды, сервисы, Network Policies).

## Соответствие требованиям задания

Данное решение полностью соответствует требованиям задания:

1. ✓ Развернуты четыре сервиса в кластере Kubernetes
2. ✓ Назначены метки для сервисов: front-end, back-end-api, admin-front-end, admin-back-end-api
3. ✓ Созданы сетевые политики для разделения трафика между API и UI сервисами
4. ✓ Трафик разрешен в обе стороны между парами: front-end ↔ back-end-api и admin-front-end ↔ admin-back-end-api
5. ✓ Сетевая политика сохранена в файл non-admin-api-allow.yaml
6. ✓ Проверена работа сетевых политик

Решение обеспечивает изоляцию трафика и защиту API сервисов от несанкционированного доступа.
