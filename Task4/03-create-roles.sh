#!/bin/bash

set -e

echo "Создание ролей в Kubernetes"
echo "============================"

echo ""
echo "Создание роли: developer"

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "services", "configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "list", "watch"]
EOF

echo "Роль developer создана"

echo ""
echo "Создание роли: devops-engineer"

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: devops-engineer
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "services", "configmaps", "secrets", "persistentvolumeclaims"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses", "networkpolicies"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "list", "watch"]
EOF

echo "Роль devops-engineer создана"

echo ""
echo "Создание роли: viewer"

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: viewer
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "services", "configmaps", "events"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]
EOF

echo "Роль viewer создана"

echo ""
echo "Создание ClusterRole: security-auditor"

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-auditor
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets", "events", "namespaces"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies", "ingresses"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["policy"]
  resources: ["podsecuritypolicies"]
  verbs: ["get", "list", "watch"]
EOF

echo "ClusterRole security-auditor создана"

echo ""
echo "Все роли успешно созданы"
echo ""
echo "Следующий шаг: выполните скрипт 04-bind-users-to-roles.sh для привязки пользователей к ролям"
