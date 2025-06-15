# Provisioning

Provisioning part of the infra. Use Terraform.

## Setup

- Need a proxmox user dedidacted to terraform (cf. [this tutorial](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#api-token-authentication))
- Need a terraform dedicated ssh key (and the according public key on proxmox nodes) (cf. [this tutorial](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#ssh-user))

## Todo

- Automated setup (ansible ?)
