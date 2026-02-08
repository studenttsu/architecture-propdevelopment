#!/bin/bash

echo "Тест 1: front-end -> back-end-api (должен работать)"
kubectl run test-1 --rm -i -t --image=alpine --labels=role=front-end -n task5 -- sh -c "wget -qO- --timeout=2 http://back-end-api-app" && echo "OK" || echo "FAIL"

echo ""
echo "Тест 2: admin-front-end -> admin-back-end-api (должен работать)"
kubectl run test-2 --rm -i -t --image=alpine --labels=role=admin-front-end -n task5 -- sh -c "wget -qO- --timeout=2 http://admin-back-end-api-app" && echo "OK" || echo "FAIL"

echo ""
echo "Тест 3: front-end -> admin-back-end-api (должен быть заблокирован)"
kubectl run test-3 --rm -i -t --image=alpine --labels=role=front-end -n task5 -- sh -c "wget -qO- --timeout=2 http://admin-back-end-api-app" && echo "FAIL" || echo "OK (заблокирован)"
