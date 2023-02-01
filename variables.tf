variable "namespace" {
  description = "Namespace to create the resources under"
  type = string
}

variable "masters_api_port" {
  description = "Http port of the api on the k8 masters"
  type = number
  default = 6443
}

variable "workers_ingress_http_port" {
  description = "Http port of the ingress on the k8 workers"
  type = number
  default = 30000
}

variable "workers_ingress_https_port" {
  description = "Https port of the ingress on the k8 workers"
  type = number
  default = 30001
}