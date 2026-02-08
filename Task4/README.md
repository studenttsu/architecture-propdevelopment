# Задание 4. Защита доступа к кластеру Kubernetes

## Описание

Настройка ролевого доступа (RBAC) для пользователей кластера Kubernetes.

## Роли

- **cluster-admin** - полный доступ ко всем ресурсам кластера
- **namespace-admin** - полный доступ к ресурсам в namespace
- **developer** - просмотр и создание deployments, без удаления
- **devops-engineer** - управление инфраструктурой, доступ к secrets
- **viewer** - только чтение ресурсов
- **security-auditor** - чтение всех ресурсов для аудита

Описание в [rbac_roles.md](rbac_roles.md)

## Пользователи

- **developer-ivan** - разработчик
- **devops-maria** - DevOps инженер

## Запуск

```bash
chmod +x init.sh
./init.sh
```

## Проверка

```bash
kubectl --kubeconfig=bin/developer-ivan/developer-ivan-kubeconfig.yaml get pods
kubectl --kubeconfig=bin/devops-maria/devops-maria-kubeconfig.yaml get pods
```