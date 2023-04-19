# AWS EKS Cluster - example with existing VPC
[![en](https://img.shields.io/badge/lang-en-brightgreen.svg)](README.md) [![kr](https://img.shields.io/badge/lang-kr-brightgreen.svg)](README-kr.md)
-------

This example demonstrates how to provision an EKS cluster and integrate it with VESSL using Terraform.

The code provisions the following resources on an existing AWS VPC:
* EKS cluster
* Self-managed EKS worker node groups
* Add-on resources installed in EKS cluster
  * AWS Load Balancer Controller: Enables the provisioning of AWS ALB for ingresses managed by VESSL.
  * Cluster Autoscaler: Scales worker nodes based on cluster resource demand.
  * EBS CSI Driver: Utilizes EBS volumes for persistent storage.
  * NVIDIA GPU Operator: Enables the usage of GPU instances as worker nodes.
* VESSL cluster agent to connect with VESSL API server as a remote control plane.


## Prerequisites
* An [AWS](https://console.aws.amazon.com/console/home) Account
* A [VESSL](https://vessl.ai/) Account
* [Terraform](https://www.terraform.io/) version 1.3.6 or later

## Setup

### 1. Define Terraform backend configuration

This example uses AWS S3 as a Terraform backend. However, you can use any other backend supported by Terraform. For more information, refer to the [Terraform backend configuration docs](https://www.terraform.io/docs/language/settings/backends/index.html).

To modify the backend configuration file, navigate to the root directory of this example and open the `terraform.tfbackend` file. Modify the file's contents to match your environment as follows:
```hcl
region = "<AWS_REGION_HERE>"
bucket = "<AWS_BUCKET_TO_STORE_TERRAFORM_STATE>"
key    = "<TERRAFORM_STATE_FILE_NAME>"
```

### 2. Set Terraform variables

This example utilizes the AWS provider to provision resources and requires the following variables:
* AWS profile and region to use
* VPC ID and subnets to use
* Name and version of EKS cluster (We recommend using version 1.23 for EKS).
* IAM role authorized as `system:master` in the cluster
* VESSL agent access token obtained from the VESSL cluster dashboard

To modify the variable file, navigate to the root directory of this example and open the `terraform.tfvars` file.

> Note: You should keep sensitive information safe such as the `vessl_agent_access_token` in the production environemt. You can pass them through another method such as passing as environment variables or using Terraform Cloud. For more information, refer to the  [Terraform sensitive variables document](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables#set-values-with-variables).

### 3. Initialize Terraform

Navigate to the root directory of this example and run the following command to initialize Terraform:
```bash
terraform init -backend-config=terraform.tfbackend
```

### 4. Provision resources

Navigate to the same directory and run the following command to provision resources using Terraform:
```bash
terraform apply
```

### 5. Verify cluster has connected to VESSL

Go to https://vessl.ai/{your-organization-name}/clusters to verify that the cluster has connected to VESSL. When cluster has connected successfully, you can see the cluster name and the number of nodes in the cluster dashboard.

If the cluster doesn't show up in the dashboard, you can check the logs of the VESSL agent to see if there are any errors. To check the logs, you must first be able to connect to a provisioned Kubernetes cluster.

Run the following command to obtain the kubeconfig to connect to the cluster:
```bash
aws eks --region <AWS_REGION_HERE> update-kubeconfig --name <EKS_CLUSTER_NAME_HERE>
```

Once you have the Kubeconfig, run the following [kubectl](https://kubernetes.io/docs/reference/kubectl/) command:
```bash
# Replace 'vessl' with the namespace you specified in the 'terraform.tfvars' file
kubectl logs -f --tail=30 deployment/vessl-cluster-agent -n vessl
```

### 6. Add a new node group

To include a new node group in your EKS cluster, you can modify the `main.tf` file and add the `eks-self-managed-node-group` module.

For instance, to add a new node group that uses GPU instance types such as `g4dn.xlarge`, you can add the following code to the `main.tf` file:

```hcl
module "eks_node_group_gpu_t4" {
  for_each = local.availability_zone_subnets

  source = "github.com/vessl-ai/vessl-cloud-integration/modules/eks-self-managed-node-group"

  instance_type = "g4dn.large"
  min_size      = 0
  max_size      = 10

  cluster_name                       = module.eks.cluster_name
  cluster_version                    = module.eks.cluster_version
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data

  security_group_ids = [
    module.eks.cluster_primary_security_group_id,
    module.eks.cluster_security_group_id,
  ]
  availability_zone        = each.key
  subnet_ids               = each.value
  iam_instance_profile_arn = module.eks.cluster_node_iam_instance_profile_arn

  node_template_labels = {
    "app.vessl.ai/v1.t4-1.mem-13" : "true",
    "nvidia.com/gpu.product" : "Tesla-T4",
    "k8s.amazonaws.com/accelerator" : "nvidia-tesla-t4"
  }
  node_template_resources = {
    "nvidia.com/gpu" : "1",
    "ephemeral-storage" : "100Gi"
  }
  tags = var.tags
}
```

Note that `instance_type`, `node_template_labels`, and `node_template_resources` are modified to match the GPU instance type used in EKS and node labels used by cluster autoscaler.

### 7. Destroying resources

After you are done with the example, you can destroy the resources by running the following command:
```bash
terraform destroy
```
