#!/bin/bash

echo "Применение ролей..."
kubectl apply -f ../manifests/roles.yaml

echo "Применение привязок ролей..."
kubectl apply -f ../manifests/rolebindings.yaml

echo "RBAC настроен"
