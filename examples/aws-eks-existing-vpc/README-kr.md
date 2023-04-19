# AWS EKS Cluster - 존재하는 VPC에 프로비저닝 예제
[![en](https://img.shields.io/badge/lang-en-brightgreen.svg)](README.md) [![kr](https://img.shields.io/badge/lang-kr-brightgreen.svg)](README-kr.md)
-------

이 예제는 기존 AWS VPC에서 EKS 클러스터를 프로비저닝하고 Terraform을 사용하여 클러스터를 VESSL에 통합하는 방법을 보여줍니다.

예제 코드에서는, 이미 존재하는 AWS VPC에 다음 리소스를 프로비저닝합니다:
* EKS 클러스터
* 자체 관리형(Self-managed) EKS 워커 노드 그룹
* EKS 클러스터에 설치된 애드온 리소스
  * AWS Load Balancer Controller: VESSL을 통해 정의한 Ingress들에 대해 AWS Application Load Balancer를 프로비저닝합니다.
  * Cluster Autoscaler: 클러스터 자원의 수요에 따라 워커 노드를 확장합니다.
  * EBS CSI Driver: EBS 볼륨을 영구 스토리지로 사용합니다.
  * NVIDIA GPU Operator: GPU 인스턴스를 워커 노드로 사용할 수 있도록 합니다.
* VESSL Cluster Agent: 클러스터를 원격 컨트롤 플레인인 VESSL API 서버와 연결합니다.

## Prerequisites
* [AWS](https://console.aws.amazon.com/console/home) 계정
* [VESSL](https://vessl.ai/) 계정
* [Terraform](https://www.terraform.io/) (>= 1.3.6)

## 설정

### 1. Terraform 백엔드 구성 정의

이 예제에서는 AWS S3를 Terraform 백엔드로 사용합니다. 하지만 Terraform에서 지원하는 다른 백엔드를 사용할 수 있습니다. 자세한 내용은 [Terraform 백엔드 구성 문서](https://www.terraform.io/docs/language/settings/backends/index.html)를 참고하세요.

백엔드 구성 파일을 수정하려면 이 예제의 루트 디렉토리로 이동하여 `terraform.tfbackend` 파일을 엽니다. 파일의 내용을 다음과 같이 사용자 환경에 맞게 수정합니다:
```hcl
region = "<AWS_REGION_HERE>"
bucket = "<AWS_BUCKET_TO_STORE_TERRAFORM_STATE>"
key = "<테라폼_상태_파일_이름>"
```

### 2. Terraform 변수 설정

이 예제에서는 AWS Terraform proider를 활용하여 리소스를 프로비저닝합니다. 다음 값을 변수로 설정해야 합니다:
* 사용할 AWS 프로필 및 리전
* 사용할 VPC 및 Subnet의 ID
* EKS 클러스터의 이름과 Kubernetes 버전 (현 예제에서는 Kubernetes 버전으로 1.23을 사용합니다)
* 클러스터에서 `system:master`로 권한을 부여할 IAM 역할
* VESSL 클러스터 대시보드에서 획득한 VESSL agent용 로그인 토큰

변수를 설정하려면 이 예제의 루트 디렉터리로 이동하여 `terraform.tfvars` 파일을 수정합니다.

> 참고: 프로덕션 환경에서는 `vessl_agent_access_token`과 같은 민감한 정보를 안전하게 보관해야 합니다. 환경 변수로 전달하거나 테라폼 클라우드를 사용하는 등 다른 방법을 통해 전달할 수 있습니다. 자세한 내용은 [Terraform 민감 변수 문서](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables#set-values-with-variables)를 참고하세요.

### 3. Terraform 초기화

이 예제의 루트 디렉토리로 이동하여 다음 명령을 실행하여 Terraform을 초기화합니다:
```bash
terraform init -backend-config=terraform.tfbackend
```

### 4. 리소스 프로비저닝

동일한 디렉토리에서 다음 명령을 실행하여 Terraform을 사용하여 리소스를 프로비저닝합니다:
```bash
terraform apply
```

### 5. 클러스터가 VESSL에 연결되었는지 확인하기

https://vessl.ai/{organization-name}/clusters로 이동하여 클러스터가 VESSL에 연결되었는지 확인합니다. 클러스터가 성공적으로 연결되면 클러스터 대시보드에서 클러스터의 각종 정보를 확인할 수 있습니다.

클러스터가 대시보드에 표시되지 않는 경우, VESSL 에이전트의 로그를 확인하여 오류가 있는지 확인할 수 있습니다. 로그를 확인하려면, 프로비전된 Kubernetes 클러스터에 먼저 연결할 수 있어야 합니다.

다음 명령어를 실행하여 클러스터에 연결할 kubeconfig를 획득합니다:
```bash
aws eks --region <AWS_REGION_HERE> update-kubeconfig --name <EKS_CLUSTER_NAME_HERE>
```

Kubeconfig를 획득했다면, 다음 [kubectl](https://kubernetes.io/docs/reference/kubectl/) 명령어를 실행합니다:
```bash
# 'vessl'을 'terraform.tfvars' 파일에 지정한 네임스페이스로 바꿉니다.
kubectl logs -f --tail=30 deployment/vessl-cluster-agent -n vessl
```

### 6. 새 노드 그룹 추가

EKS 클러스터에 새 노드 그룹을 추가하려면 `main.tf` 파일을 수정하여 `eks-self-managed-node-group` 모듈을 추가하면 됩니다.

예를 들어, `g4dn.xlarge`와 같은 GPU 인스턴스 유형을 사용하는 새 노드 그룹을 추가하려면 `main.tf` 파일에 다음 코드를 추가하면 됩니다:

```hcl
module "eks_node_group_gpu_t4" {
  for_each = local.availability_zone_subnets

  source = "github.com/vessl-ai/vessl-cloud-integration//modules/eks-self-managed-node-group?ref=0.1.1"

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

`instance_type`, `node_template_labels`, `node_template_resources` 과 같은 필드가 수정되었음에 주목해주세요. 해당 정보는 EKS에서 사용할 GPU 인스턴스 타입과, Kubernetes의 Cluster Autoscaler에서 사용할 노드 라벨에 대응됩니다.

### 7. 리소스 삭제

예제를 완료한 후 다음 명령어를 실행하여 리소스를 삭제할 수 있습니다:
```bash
terraform destroy
```
