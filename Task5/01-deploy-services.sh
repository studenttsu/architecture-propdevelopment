#!/bin/bash

set -e

echo "Развертывание четырех сервисов в кластере Kubernetes"
echo "====================================================="

echo ""
echo "Создание namespace для задания"
kubectl create namespace task5 --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Развертывание сервиса: front-end-app"
kubectl run front-end-app --image=nginx --labels=role=front-end --expose --port=80 -n task5

echo ""
echo "Развертывание сервиса: back-end-api-app"
kubectl run back-end-api-app --image=nginx --labels=role=back-end-api --expose --port=80 -n task5

echo ""
echo "Развертывание сервиса: admin-front-end-app"
kubectl run admin-front-end-app --image=nginx --labels=role=admin-front-end --expose --port=80 -n task5

echo ""
echo "Развертывание сервиса: admin-back-end-api-app"
kubectl run admin-back-end-api-app --image=nginx --labels=role=admin-back-end-api --expose --port=80 -n task5

echo ""
echo "Ожидание готовности подов..."
sleep 5

echo ""
echo "Проверка статуса подов:"
kubectl get pods -n task5 -o wide

echo ""
echo "Проверка сервисов:"
kubectl get svc -n task5

echo ""
echo "Все сервисы успешно развернуты"
echo ""
echo "Следующий шаг: выполните скрипт 02-create-network-policies.sh для создания сетевых политик"
