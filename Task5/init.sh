#!/bin/bash

echo "Настройка сетевых политик Kubernetes"
echo "====================================="

cd bin

echo ""
echo "Шаг 1: Развертывание сервисов"
./deploy-services.sh

echo ""
echo "Шаг 2: Применение сетевых политик"
./apply-policies.sh

echo ""
echo "Шаг 3: Тестирование (опционально)"
echo "Запустите: cd bin && ./test-policies.sh"

cd ..
echo ""
echo "Готово"
