#!/bin/bash

echo "Применение сетевых политик"
kubectl apply -f ../manifests/network-policies.yaml

echo "Проверка политик"
kubectl get networkpolicies -n task5
