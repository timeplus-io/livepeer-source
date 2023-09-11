### quick start

add following environment of your timeplus workspace

```bash
export TF_VAR_apikey=your_timeplus_api_key
export TF_VAR_workspace=your_timeplus_workspace_id
export TF_VAR_endpoint=timeplus_cloud_endpoint
```

update the `replace_with_your_livepeer_api_key` in the `main.tf` with your livepeer api key

run `terraform init` and then `terraform apply` to deploy all resources

run `terraform destroy` to delete all resources