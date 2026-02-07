#!/bin/bash

set -e

echo "Создание kubeconfig файлов для пользователей"
echo "============================================="

CLUSTER_NAME="propdevelopment-cluster"
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_CA=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

USERS=("developer-ivan" "devops-maria")

for USER in "${USERS[@]}"; do
    echo ""
    echo "Создание kubeconfig для пользователя: $USER"
    
    KUBECONFIG_FILE="$USER/$USER-kubeconfig.yaml"
    
    kubectl config --kubeconfig="$KUBECONFIG_FILE" set-cluster "$CLUSTER_NAME" \
        --server="$CLUSTER_SERVER" \
        --certificate-authority-data="$CLUSTER_CA" \
        --embed-certs=true
    
    kubectl config --kubeconfig="$KUBECONFIG_FILE" set-credentials "$USER" \
        --client-certificate="$USER/$USER.crt" \
        --client-key="$USER/$USER.key" \
        --embed-certs=true
    
    kubectl config --kubeconfig="$KUBECONFIG_FILE" set-context "$USER@$CLUSTER_NAME" \
        --cluster="$CLUSTER_NAME" \
        --user="$USER"
    
    kubectl config --kubeconfig="$KUBECONFIG_FILE" use-context "$USER@$CLUSTER_NAME"
    
    echo "Kubeconfig для пользователя $USER создан: $KUBECONFIG_FILE"
done

echo ""
echo "Kubeconfig файлы успешно созданы"
echo ""
echo "Следующий шаг: выполните скрипт 03-create-roles.sh для создания ролей"
