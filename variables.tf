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

variable "k8_master_name" {
  description = "Name for kubernetes master security group"
  type        = string
}

variable "k8_worker_name" {
  description = "Name for kubernetes worker security group"
  type        = string
}

variable "k8_load_balancer_name" {
  description = "Name for kubernetes load balancer security group"
  type        = string
}

variable "k8_load_balancer_tunnel_name" {
  description = "Name for kubernetes load balancer tunnel security group"
  type        = string
}

variable "k8_bastion_name" {
  description = "Name of kubernetes bastion security group"
  type        = string
}

variable "k8_master_client_groups" {
  description = "List of kubernetes master client security groups"
  type = list(object({
    name = string
    id   = string
  }))
  default = []
}

variable "k8_bastion_groups" {
  description = "List of kubernetes bastion security groups"
  type = list(object({
    name = string
    id   = string
  }))
  default = []
}

variable "k8_worker_client_groups" {
  description = "List of kubernetes worker client security groups"
  type = list(object({
    name = string
    id   = string
  }))
  default = []
}