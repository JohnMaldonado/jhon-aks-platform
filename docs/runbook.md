# Runbook

## Deploy (dev)

```bash
cd terraform
terraform init
terraform plan -var-file="../terraform/environments/dev/terraform.tfvars"
terraform apply -auto-approve -var-file="../terraform/environments/dev/terraform.tfvars"
```

## Access cluster

```bash
az aks get-credentials --resource-group jhon-aks-rg --name jhon-aks-cluster
kubectl get nodes
```
