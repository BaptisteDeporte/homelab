# homelab

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
