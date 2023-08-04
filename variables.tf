variable "member_group_name" {
  description = "Name to give to the security group of kubernetes server"
  type = string
  default = ""
}

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

variable "k8_worker_client_ids" {
  description = "Id of direct client of kubernetes masters"
  type = list(string)
  default = []
}

variable "kubernetes_nodes_full_access_groups_ids" {
  description = "Id of kubernetes master and worker groups"
  type = list(string)
  default = []
}

variable "kubernetes_master_api_access_groups_ids" {
  description = "Id of kubernetes master components groups"
  type = list(string)
  default = []
}

variable "kubernetes_worker_ingress_access_groups_ids" {
  description = "Id of kubernetes worker ingress groups"
  type = list(string)
  default = []
}

variable "bastion_ssh_accessible_group_ids" {
  description = "Id of bastion security groups"
  type = list(string)
  default = []
}

variable "externally_ssh_accessible_groups_ids" {
  description = "Id of externally ssh accessible groups"
  type = list(string)
  default = []
}