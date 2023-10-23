# AWS EKS Cluster - 존재하는 VPC에 프로비저닝 예제
[![en](https://img.shields.io/badge/lang-en-brightgreen.svg)](README.md) [![kr](https://img.shields.io/badge/lang-kr-brightgreen.svg)](README-kr.md)
-------

이 예제는 기존 AWS VPC에서 EKS 클러스터를 프로비저닝하고 Terraform을 사용하여 클러스터를 VESSL에 통합하는 방법을 보여줍니다.

예제 코드에서는, 이미 존재하는 AWS VPC에 다음 리소스를 프로비저닝합니다:
* EKS 클러스터
* 자체 관리형(Self-managed) EKS 워커 노드 그룹
* EKS 클러스터에 설치된 애드온 리소스
  * 자세한 내용은 https://registry.terraform.io/modules/vessl-ai/vessl-eks-addons/aws/latest 에서 확인하실 수 있습니다.
* VESSL Cluster Agent: 클러스터를 원격 컨트롤 플레인인 VESSL API 서버와 연결합니다.
  * 자세한 내용은 https://github.com/vessl-ai/helm-charts 에서 확인하실 수 있습니다.

## Prerequisites
* [AWS](https://console.aws.amazon.com/console/home) 계정
* [VESSL](https://vessl.ai/) 계정
* [Terraform](https://www.terraform.io/) (>= 1.3.6)

## 설정

### 1. Terraform 백엔드 구성 정의

이 예제에서는 [Local Terraform Backend](https://developer.hashicorp.com/terraform/language/settings/backends/local)를 사용합니다. Local Terraform Backend는 Terraform 상태 파일을 로컬 디스크에 저장하며 추후 손쉽게 AWS S3나 Terraform Cloud 등 remote backend로 손쉽게 마이그레이션 할 수 있습니다.


### 2. AWS 인증 설정
provider.tf 에 AWS 인정 정보를 설정합니다.
AWS CLI를 사용하여 `~/.aws` 에 설정된 인증 정보를 사용할 수 있습니다.
```hcl
provider "aws" {
  profile = "<AWS_PROFILE>"
  region  = "<AWS_REGION>"
}
```
또는 profile, region을 코드에 설정하지 않고 환경변수로 설정할 수도 있습니다.
```hcl
provider "aws" {}
```
```bash
export AWS_REGION=<AWS_REGION>
export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
export AWS_SESSION_TOKEN=<AWS_SESSION_TOKEN>
terraform apply
```


### 3. Terraform 변수 설정

이 예제에서는 AWS Terraform provider를 활용하여 리소스를 프로비저닝합니다. 다음 값을 변수로 설정해야 합니다:
* 사용할 VPC 및 Subnet의 ID
* EKS 클러스터의 이름과 Kubernetes 버전 (현 예제에서는 Kubernetes 버전으로 1.25를 사용합니다)
* 클러스터에서 `system:master`로 권한을 부여할 IAM role
* VESSL 클러스터 대시보드에서 획득한 VESSL agent용 로그인 토큰

변수를 설정하려면 이 예제의 루트 디렉터리로 이동하여 `terraform.tfvars.example` 파일을 `terraform.tfvars`로 복사하고 수정합니다.

> 참고: 프로덕션 환경에서는 `vessl_agent_access_token`과 같은 민감한 정보를 안전하게 보관해야 합니다. 환경 변수로 전달하거나 테라폼 클라우드를 사용하는 등 다른 방법을 통해 전달할 수 있습니다. 자세한 내용은 [Terraform 민감 변수 문서](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables#set-values-with-variables)를 참고하세요.

### 4. Terraform 초기화

이 예제의 루트 디렉토리로 이동하여 다음 명령을 실행하여 Terraform을 초기화합니다:
```bash
terraform init
```

### 5. 리소스 프로비저닝

동일한 디렉토리에서 다음 명령을 실행하여 Terraform을 사용하여 리소스를 프로비저닝합니다:
```bash
terraform apply
```

### 6. VESSL Organization에 클러스터 연결하기

먼저 VESSL CLI를 설치 후 로그인합니다:
```bash
# virtualenv에서 설치하는 것을 권장합니다.
pip install vessl
vessl configure
```

다음 명령어를 실행하여 클러스터에 연결할 kubeconfig를 획득합니다:
```bash
aws eks --region <AWS_REGION_HERE> update-kubeconfig --name <EKS_CLUSTER_NAME_HERE>
```

Kubeconfig를 획득했다면, vessl CLI를 사용하여 클러스터를 VESSL Organization에 연결할 수 있습니다:
```bash
vessl cluster create
```

### 7. 클러스터 연결 확인하기
https://vessl.ai/{organizationName}/clusters 에서 클러스터가 연결되었는지 확인할 수 있습니다.

만약 연결되지 않는다면 클러스터 내 vessl-agent pod log를 확인해주세요.

### 8. 리소스 삭제

예제를 완료한 후 다음 명령어를 실행하여 리소스를 삭제할 수 있습니다:
```bash
terraform destroy
```
