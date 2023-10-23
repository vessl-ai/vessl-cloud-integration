provider "aws" {}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# # Caveat: Use data source instead of module output, since k8s provider isn't receiving a configuration from module output
# # See also:
# # - https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1280#issuecomment-804499461
# # - https://github.com/hashicorp/terraform/issues/24886
# data "aws_eks_cluster" "eks" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "eks" {
#   name = module.eks.cluster_name
# }

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  # host                   = data.aws_eks_cluster.eks.endpoint
  # cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  # token                  = data.aws_eks_cluster_auth.eks.token


  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--region", data.aws_region.current.name, "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    # host                   = data.aws_eks_cluster.eks.endpoint
    # cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    # token                  = data.aws_eks_cluster_auth.eks.token

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--region", data.aws_region.current.name, "--cluster-name", module.eks.cluster_name]
    }
  }
}


terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.50"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }
  }

  backend "local" {}
}
