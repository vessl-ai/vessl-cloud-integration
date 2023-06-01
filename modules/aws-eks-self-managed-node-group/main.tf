data "aws_region" "current" {}
locals {
  node_group_name = var.node_group_name == null ? "${var.cluster_name}-${var.instance_type}-${var.availability_zone}" : var.node_group_name
}

# ----------------------------
# EKS self-managed node groups
# ----------------------------
module "node_group" {
  source = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"

  name                 = local.node_group_name
  launch_template_name = local.node_group_name
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  bootstrap_extra_args = length(var.node_template_labels) == 0 ? "" : join(" ", [
    "--kubelet-extra-args",
    "--node-labels=${join(",", [for k, v in var.node_template_labels : "${k}=${v}"])}",
    length(var.taints) == 0 ? "" : "--register-with-taints=${join(",", var.taints)}",
  ])

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  cluster_endpoint    = var.cluster_endpoint
  cluster_auth_base64 = var.cluster_certificate_authority_data

  subnet_ids = var.subnet_ids

  create_iam_instance_profile = false
  iam_instance_profile_arn    = var.iam_instance_profile_arn

  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  vpc_security_group_ids = var.security_group_ids

  min_size     = var.min_size
  max_size     = var.max_size
  desired_size = var.desired_size

  # Pre-propagate necessary k8s node labels to autoscaling group tags in order to implement scale-to-zero
  # https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-scale-a-node-group-to-0
  autoscaling_group_tags = merge(
    {
      for k, v in var.node_template_labels : "k8s.io/cluster-autoscaler/node-template/label/${k}" => "${v}"
    },
    {
      for k, v in var.node_template_resources : "k8s.io/cluster-autoscaler/node-template/resources/${k}" => "${v}"
    },
    {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${var.cluster_name}" : "owned",
      "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/region"    = data.aws_region.current.name
      "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/zone"      = var.availability_zone
      "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/instance-type" = var.instance_type
    },
  )

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 100
        volume_type           = "gp3"
        iops                  = 3000 # Baseline
        throughput            = 125  # Baseline
        delete_on_termination = true
      }
    }
  }

  tags = merge(var.tags, {
    Name = local.node_group_name
  })
}
