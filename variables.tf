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

variable "master_group_name" {
  description = "Name for kubernetes master security group"
  type        = string
}

variable "worker_group_name" {
  description = "Name for kubernetes worker security group"
  type        = string
}

variable "load_balancer_group_name" {
  description = "Name for kubernetes load balancer security group"
  type        = string
}

variable "load_balancer_tunnel_group_name" {
  description = "Name for kubernetes load balancer tunnel security group"
  type        = string
}

variable "bastion_groups" {
  description = "List of kubernetes bastion security groups"
  type = list(object({
    name = string
    id   = string
  }))
  default = []
}

variable "metrics_server_groups" {
  description = "List of kubernetes metric servers security groups"
  type = list(object({
    name = string
    id   = string
  }))
  default = []
}

variable "master_client_groups" {
  description = "List of kubernetes master client security groups"
  type = list(object({
    name = string
    id   = string
  }))
  default = []
}

variable "worker_client_groups" {
  description = "List of kubernetes worker client security groups"
  type = list(object({
    name = string
    id   = string
  }))
  default = []
}