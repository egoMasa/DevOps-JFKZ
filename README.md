# DevOps---JFKZ

```
cd ~/devops/terraform/
terraform init
terraform plan
terraform apply

---

ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.150'
ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.151'
ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.152'
ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.153'

---

cd ~/devops/ansible/
ansible-playbook -i inventory.ini deploy_k8s_master.yml
ansible-playbook -i inventory.ini deploy_k8s_workers.yml
ansible-playbook -i inventory.ini deploy_db.yml

---

cd ~/devops/k8s/
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
kubectl -n metallb-system rollout status deploy/controller
kubectl -n metallb-system rollout status ds/speaker
kubectl label node tf-k8s-node-1 metallb-speaker=true --overwrite
kubectl label node tf-k8s-node-2 metallb-speaker=true --overwrite
kubectl label node tf-k8s-master metallb-speaker=false --overwrite
kubectl -n metallb-system patch ds speaker --type='merge' -p '{
  "spec": {
    "template": {
      "spec": {
        "nodeSelector": {
          "metallb-speaker": "true"
        }
      }
    }
  }
}'
kubectl -n metallb-system rollout restart ds/speaker
kubectl apply -f metallb-manifest.yaml

---

cd ~/devops/k8s/
kubectl apply -f nginx-manifest.yaml

---

cd ~/devops/k8s/
kubectl apply -f wikijs-manifest.yaml

---

URL : http://wikijs.lab:80
```
