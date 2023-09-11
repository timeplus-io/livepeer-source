### quick start

add following environment of your timeplus workspace

```bash
export TF_VAR_timeplus_apikey=your_timeplus_api_key
export TF_VAR_timeplus_workspace=your_timeplus_workspace_id
export TF_VAR_timeplus_endpoint=timeplus_cloud_endpoint
export TF_VAR_livepeer_apikey=your_livepeer_apikey
```

run `terraform init` and then `terraform apply` to deploy all resources

run `terraform destroy` to delete all resources