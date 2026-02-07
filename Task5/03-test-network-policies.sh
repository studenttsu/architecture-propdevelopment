#!/bin/bash

set -e

echo "Проверка работы сетевых политик"
echo "================================"

echo ""
echo "Тест 1: Проверка доступа от front-end к back-end-api (должен быть разрешен)"
echo "----------------------------------------------------------------------------"
kubectl run test-frontend-to-backend --rm -i -t --image=alpine --labels=role=front-end -n task5 -- sh -c "wget -qO- --timeout=2 http://back-end-api-app" && echo "SUCCESS: front-end может обращаться к back-end-api" || echo "FAILED: front-end не может обращаться к back-end-api"

echo ""
echo "Тест 2: Проверка доступа от admin-front-end к admin-back-end-api (должен быть разрешен)"
echo "--------------------------------------------------------------------------------------"
kubectl run test-adminfrontend-to-adminbackend --rm -i -t --image=alpine --labels=role=admin-front-end -n task5 -- sh -c "wget -qO- --timeout=2 http://admin-back-end-api-app" && echo "SUCCESS: admin-front-end может обращаться к admin-back-end-api" || echo "FAILED: admin-front-end не может обращаться к admin-back-end-api"

echo ""
echo "Тест 3: Проверка доступа от front-end к admin-back-end-api (должен быть запрещен)"
echo "---------------------------------------------------------------------------------"
kubectl run test-frontend-to-adminbackend --rm -i -t --image=alpine --labels=role=front-end -n task5 -- sh -c "wget -qO- --timeout=2 http://admin-back-end-api-app" && echo "FAILED: front-end может обращаться к admin-back-end-api (не должен!)" || echo "SUCCESS: front-end не может обращаться к admin-back-end-api (как и ожидалось)"

echo ""
echo "Тест 4: Проверка доступа от admin-front-end к back-end-api (должен быть запрещен)"
echo "---------------------------------------------------------------------------------"
kubectl run test-adminfrontend-to-backend --rm -i -t --image=alpine --labels=role=admin-front-end -n task5 -- sh -c "wget -qO- --timeout=2 http://back-end-api-app" && echo "FAILED: admin-front-end может обращаться к back-end-api (не должен!)" || echo "SUCCESS: admin-front-end не может обращаться к back-end-api (как и ожидалось)"

echo ""
echo "Тест 5: Проверка доступа от случайного пода к back-end-api (должен быть запрещен)"
echo "--------------------------------------------------------------------------------"
kubectl run test-random-to-backend --rm -i -t --image=alpine -n task5 -- sh -c "wget -qO- --timeout=2 http://back-end-api-app" && echo "FAILED: случайный под может обращаться к back-end-api (не должен!)" || echo "SUCCESS: случайный под не может обращаться к back-end-api (как и ожидалось)"

echo ""
echo "Проверка завершена"
echo ""
echo "Ожидаемые результаты:"
echo "  - Тест 1: SUCCESS (front-end → back-end-api разрешен)"
echo "  - Тест 2: SUCCESS (admin-front-end → admin-back-end-api разрешен)"
echo "  - Тест 3: SUCCESS (front-end → admin-back-end-api запрещен)"
echo "  - Тест 4: SUCCESS (admin-front-end → back-end-api запрещен)"
echo "  - Тест 5: SUCCESS (случайный под → back-end-api запрещен)"
