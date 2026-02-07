#!/bin/bash

set -e

echo "Привязка пользователей к ролям"
echo "==============================="

echo ""
echo "Привязка пользователя developer-ivan к роли developer"

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-ivan-binding
  namespace: default
subjects:
- kind: User
  name: developer-ivan
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Пользователь developer-ivan привязан к роли developer"

echo ""
echo "Привязка пользователя devops-maria к роли devops-engineer"

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devops-maria-binding
  namespace: default
subjects:
- kind: User
  name: devops-maria
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: devops-engineer
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Пользователь devops-maria привязан к роли devops-engineer"

echo ""
echo "Все привязки успешно созданы"
echo ""
echo "Настройка RBAC завершена!"
echo ""
echo "Проверка доступа:"
echo "  kubectl --kubeconfig=developer-ivan/developer-ivan-kubeconfig.yaml get pods"
echo "  kubectl --kubeconfig=devops-maria/devops-maria-kubeconfig.yaml get pods"
