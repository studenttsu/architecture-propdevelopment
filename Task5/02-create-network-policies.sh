#!/bin/bash

set -e

echo "Создание сетевых политик для разграничения трафика"
echo "==================================================="

echo ""
echo "Применение сетевых политик из файла non-admin-api-allow.yaml"
kubectl apply -f non-admin-api-allow.yaml

echo ""
echo "Проверка созданных сетевых политик:"
kubectl get networkpolicies -n task5

echo ""
echo "Детальная информация о сетевых политиках:"
echo ""
echo "1. NetworkPolicy: non-admin-api-allow"
kubectl describe networkpolicy non-admin-api-allow -n task5

echo ""
echo "2. NetworkPolicy: admin-api-allow"
kubectl describe networkpolicy admin-api-allow -n task5

echo ""
echo "3. NetworkPolicy: front-end-allow"
kubectl describe networkpolicy front-end-allow -n task5

echo ""
echo "4. NetworkPolicy: admin-front-end-allow"
kubectl describe networkpolicy admin-front-end-allow -n task5

echo ""
echo "Сетевые политики успешно созданы"
echo ""
echo "Следующий шаг: выполните скрипт 03-test-network-policies.sh для проверки работы политик"
