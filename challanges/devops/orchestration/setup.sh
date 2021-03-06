#!/bin/bash

git reset --hard
git clean -f -d
  
kubectl delete -f k8s/smaster.yaml 2>/dev/null
kubectl delete -f k8s/sminion.yaml 2>/dev/null 


kubectl create -f k8s/smaster.yaml
kubectl create -f k8s/sminion.yaml

kubectl rollout status StatefulSet/sminion && kubectl rollout status StatefulSet/smaster
kubectl get --no-headers=true pods -l name=sminion -o custom-columns=:metadata.name | xargs -I {} kubectl exec {} -- sh -c  'echo "master: smaster-0.smaster.default.svc.cluster.local">/etc/salt/minion'
kubectl get --no-headers=true pods -l name=sminion -o custom-columns=:metadata.name | xargs -I {} kubectl exec {} -- sh -c '/etc/init.d/salt-minion restart && sleep 5 && /etc/init.d/salt-minion status'

kubectl exec smaster-0 -- salt-key -L
kubectl exec -it smaster-0 -- salt-key -A -y
