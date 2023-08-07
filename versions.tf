terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.0.0, < 2.0.0"
    }
  }
  required_version = ">= 1.2.0"
}