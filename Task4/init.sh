#!/bin/bash

echo "Настройка RBAC для Kubernetes"
echo "=============================="

cd bin

echo ""
echo "Шаг 1: Создание пользователей"
./create-users.sh

echo ""
echo "Шаг 2: Создание kubeconfig"
./create-kubeconfig.sh

echo ""
echo "Шаг 3: Применение RBAC"
./apply-rbac.sh

cd ..

echo ""
echo "Готово"
echo "  kubectl --kubeconfig=bin/developer-ivan/developer-ivan-kubeconfig.yaml get pods"
echo "  kubectl --kubeconfig=bin/devops-maria/devops-maria-kubeconfig.yaml get pods"
