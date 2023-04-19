# VESSL Cloud 연동 예제
[![en](https://img.shields.io/badge/lang-en-brightgreen.svg)](README.md) [![kr](https://img.shields.io/badge/lang-kr-brightgreen.svg)](README-kr.md)
-----

이 프로젝트는 [Terraform](https://terraform.io/)으로 구현된 클라우드 서비스에서의 [Kubernetes](https://kubernetes.io/) cluster 패턴 모듈과, 해당 모듈을 사용해서 클러스터를 프로비저닝하고 [VESSL](https://vessl.ai/)과 연동하는 예제에 대해 다룹니다. 이 예제를 사용하여 완전한 Kubernetes 클러스터를 구성하고 관리하며, VESSL을 통해 연동하여 컨테이너화된 ML workload를 클러스터 위에서 쉽게 수행할 수 있습니다.

아래 예제들을 참고해주세요:

**Amazon Web Services**
* [AWS EKS - 존재하는 VPC에 클러스터 프로비저닝](examples/aws-eks-existing-vpc)

**Google Cloud Platform**
* [GCP GKE - VPC Network에 클러스터 프로비저닝](examples/gcp-gke-full)
