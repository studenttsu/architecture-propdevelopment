#!/bin/bash

echo "Создание namespace"
kubectl create namespace task5 --dry-run=client -o yaml | kubectl apply -f -

echo "Развертывание сервисов"
kubectl run front-end-app --image=nginx --labels=role=front-end --expose --port=80 -n task5
kubectl run back-end-api-app --image=nginx --labels=role=back-end-api --expose --port=80 -n task5
kubectl run admin-front-end-app --image=nginx --labels=role=admin-front-end --expose --port=80 -n task5
kubectl run admin-back-end-api-app --image=nginx --labels=role=admin-back-end-api --expose --port=80 -n task5

echo "Готово"
kubectl get pods -n task5
