export KUBE_MASTER=<KUBE_MASTER>
scp -i shoppingcart_key.pem -r ./k8s ubuntu@$KUBE_MASTER:~/
ssh -i shoppingcart_key.pem ubuntu@$KUBE_MASTER kubectl apply -f k8s/database.yaml
ssh -i shoppingcart_key.pem ubuntu@$KUBE_MASTER kubectl rollout status deployments/workshop-shoppingcart-mysql
ssh -i shoppingcart_key.pem ubuntu@$KUBE_MASTER kubectl apply -f k8s/migrate-production.yaml
ssh -i shoppingcart_key.pem ubuntu@$KUBE_MASTER kubectl wait --for=condition=complete job/migrate-database-production
ssh -i shoppingcart_key.pem ubuntu@$KUBE_MASTER kubectl apply -f k8s/migrate-uat.yaml
ssh -i shoppingcart_key.pem ubuntu@$KUBE_MASTER kubectl wait --for=condition=complete job/migrate-database-uat
ssh -i shoppingcart_key.pem ubuntu@$KUBE_MASTER kubectl apply -f k8s/api.yaml
ssh -i shoppingcart_key.pem ubuntu@$KUBE_MASTER kubectl rollout status deployments/workshop-shoppingcart-api
