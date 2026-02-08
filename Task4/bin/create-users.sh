#!/bin/bash

USERS=("developer-ivan" "devops-maria")

for USER in "${USERS[@]}"; do
    echo "Создание пользователя: $USER"
    
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
done

echo "Пользователи созданы"
