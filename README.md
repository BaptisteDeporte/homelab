# homelab

Dedicated to maintaining my homelab (and learning new things in the process).

## Provisioning

Use terraform. Go to provisioning folder and do

```sh
terraform apply --auto-approve
```

## Deploying

Use ansible. Go to root folder and do

```sh
ansible-playbook k3s.orchestration.site -i inventory/inventory.yml
```
