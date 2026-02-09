# DevOps---JFKZ

```
cd /devops/terraform/
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate terraform.tfstate.backup
rm -rf .terraform .terraform.lock.hcl
terraform init
terraform plan
terraform apply

---

ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.150'
ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.151'
ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.152'
ssh-keygen -f '/home/jeremy/.ssh/known_hosts' -R '192.168.122.153'

---

cd /devops/ansible/
ansible-playbook -i inventory.ini 1-deploy-k8s-master.yaml
ansible-playbook -i inventory.ini 2-deploy-k8s-workers.yaml
ansible-playbook -i inventory.ini 3-deploy-db-postgres.yaml
ansible-playbook -i inventory.ini 4-deploy-metallb.yaml
ansible-playbook -i inventory.ini 5-deploy-ingress-nginx.yaml
ansible-playbook -i inventory.ini 6-deploy-metrics-server.yaml
ansible-playbook -i inventory.ini 7-deploy-wikijs-init.yaml

- EMAIL : test@gmail.com
- Password : azerty123
- URL : http://wikijs.lab
  
ansible-playbook -i inventory.ini 8-deploy-wikijs-scale.yaml

--- Vérifications 
ssh ansible@192.168.122.150
kubectl get nodes,pods,svc,ingress,ep,pvc,hpa -A
```
