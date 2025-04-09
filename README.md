# homelab

Dedicated to maintaining my homelab (and learning new things in the process).

## Provisioning

Use terraform. Go to provisioning folder and do

```sh
terraform apply --auto-approve
```

## Configuring

Use ansible. Go to configuration folder and do

```sh
pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yaml
ansible-playbook playbooks/k3s-server.yaml -i inventory/inventory.yml
```
