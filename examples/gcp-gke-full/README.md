# GCP GKE Cluster - full example
[![en](https://img.shields.io/badge/lang-en-brightgreen.svg)](README.md) [![kr](https://img.shields.io/badge/lang-kr-brightgreen.svg)](README-kr.md)
-------

This example demonstrates how to provision an GCP GKE cluster and integrate it with VESSL using Terraform.

The code provisions the following resources:
* container.googleapis.com API enabled
* Google VPC Network for host cluster and nodes
* GKE cluster
* GKE node pool

## Prerequisites
* An [GCP](https://console.cloud.google.com/) Account
* A [VESSL](https://vessl.ai/) Account
* [Terraform](https://www.terraform.io/) version 1.3.6 or later

## Setup

### 1. Define Terraform provider configuration

This example uses [Google Cloud Storage](https://developer.hashicorp.com/terraform/language/settings/backends/gcs) as a Terraform backend. However, you can use any other backend supported by Terraform. For more information, refer to the [Terraform backend configuration docs](https://www.terraform.io/docs/language/settings/backends/index.html).

To modify the backend configuration file, navigate to the root directory of this example and open the `terraform.tfbackend` file. Modify the file's contents to match your environment as follows:
```hcl
bucket = "<GCS_BUCKET_TO_STORE_TERRAFORM_STATE>"
prefix = "<TERRAFORM_STATE_FILE_NAME>"
```

Also in the `provider.tf` file, modify the `project` and `region` value in `google` provider block to match your environment as follows:
```hcl
provider "google" {
  project = "<GCP_PROJECT_ID>"
  region  = "us-central1"
}
```

### 2. Set Terraform variables

This example utilizes the Google provider to provision resources and requires the following variables:
* GCP Project ID and region to use
* Name and version of GKE cluster (We recommend using version 1.23 for GKE).

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

### 5. Destroying resources

After you are done with the example, you can destroy the resources by running the following command:
```bash
terraform destroy
```
