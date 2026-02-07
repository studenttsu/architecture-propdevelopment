#!/bin/bash

set -e

echo "Создание пользователей для кластера Kubernetes"
echo "================================================"

USERS=("developer-ivan" "devops-maria")

for USER in "${USERS[@]}"; do
    echo ""
    echo "Создание пользователя: $USER"
    
    if [ -d "$USER" ]; then
        echo "Директория $USER уже существует, пропускаем создание ключей"
    else
        mkdir -p "$USER"
        
        openssl genrsa -out "$USER/$USER.key" 2048
        
        openssl req -new -key "$USER/$USER.key" -out "$USER/$USER.csr" -subj "/CN=$USER/O=propdevelopment"
        
        cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $USER
spec:
  request: $(cat "$USER/$USER.csr" | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
        
        kubectl certificate approve "$USER"
        
        kubectl get csr "$USER" -o jsonpath='{.status.certificate}' | base64 -d > "$USER/$USER.crt"
        
        echo "Сертификат для пользователя $USER создан"
    fi
done

echo ""
echo "Пользователи успешно созданы"
echo ""
echo "Следующий шаг: выполните скрипт 02-create-kubeconfig.sh для создания kubeconfig файлов"
