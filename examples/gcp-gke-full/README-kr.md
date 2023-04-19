# GCP GKE Cluster - full example
[![en](https://img.shields.io/badge/lang-en-brightgreen.svg)](README.md) [![kr](https://img.shields.io/badge/lang-kr-brightgreen.svg)](README-kr.md)
-------

이 예제는 Terraform을 사용하여 GCP GKE 클러스터를 프로비저닝하고 이를 VESSL과 통합하는 방법을 보여줍니다.
예제 코드에서는, 이미 존재하는 GCP project에 다음 리소스를 프로비저닝합니다:

이 코드는 다음 리소스를 프로비저닝합니다:
* container.googleapis.com API 활성화
* 호스트 클러스터 및 노드를 위한 Google VPC 네트워크
* GKE 클러스터
* GKE 노드 풀

## Prerequisites
* [AWS](https://console.aws.amazon.com/console/home) 계정
* [VESSL](https://vessl.ai/) 계정
* [Terraform](https://www.terraform.io/) (>= 1.3.6)

## 설정

### 1. Terraform 백엔드 구성 정의

이 예제에서는 [구글 클라우드 스토리지](https://developer.hashicorp.com/terraform/language/settings/backends/gcs)를 Terraform 백엔드로 사용합니다. 하지만 테라폼에서 지원하는 다른 백엔드를 사용할 수 있습니다. 자세한 내용은 [Terraform 백엔드 구성 문서](https://www.terraform.io/docs/language/settings/backends/index.html)를 참고하세요.

백엔드 구성 파일을 수정하려면 이 예제의 루트 디렉토리로 이동하여 `terraform.tfbackend` 파일을 엽니다. 파일의 내용을 다음과 같이 사용자 환경에 맞게 수정합니다:
```hcl
bucket = "<GCS_BUCKET_TO_STORE_TERRAFORM_STATE>"
prefix = "<TERRAFORM_STATE_FILE_NAME>"
```

또한, `provider.tf` 파일을 열어 `project` 와 `region` 변수를 사용자 환경에 맞게 수정합니다:
```hcl
provider "google" {
  project = "<GCP_PROJECT_ID>"
  region  = "<GCP_REGION>"
}
```

### 2. Terraform 변수 설정

이 예제에서는 리소스를 프로비저닝하기 위해 Google 제공자를 활용하며, 다음 변수가 필요합니다:
* 사용할 GCP 프로젝트 ID 및 지역
* GKE 클러스터의 이름과 버전(GKE의 경우 1.23 버전 사용을 권장합니다).

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
