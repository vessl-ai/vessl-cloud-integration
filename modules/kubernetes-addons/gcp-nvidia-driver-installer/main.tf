data "http" "gcp_gpu_driver_installer" {
  url = "https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml"
}

resource "kubectl_manifest" "gcp_gpu_driver_installer" {
  yaml_body = data.http.gcp_gpu_driver_installer.response_body
}
