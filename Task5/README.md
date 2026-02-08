# Задание 5. Управление трафиком внутри кластера Kubernetes

## Описание

Разграничение трафика между сервисами с помощью Network Policies.

## Сервисы

- **front-end-app** - пользовательский интерфейс
- **back-end-api-app** - API для пользователей
- **admin-front-end-app** - административный интерфейс
- **admin-back-end-api-app** - API для администраторов

## Правила

- front-end может обращаться к back-end-api
- admin-front-end может обращаться к admin-back-end-api
- Остальной трафик между API запрещен

## Запуск

```bash
chmod +x init.sh
./init.sh
```

## Тестирование

```bash
cd bin
./test-policies.sh
```