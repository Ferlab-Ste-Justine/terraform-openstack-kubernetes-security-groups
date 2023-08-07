# Security Groups
resource "openstack_networking_secgroup_v2" "k8_master" {
  name                 = var.k8_master_name
  description          = "Security group for kubernetes master"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "k8_worker" {
  name                 = var.k8_worker_name
  description          = "Security group for kubernetes workers"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "k8_load_balancer" {
  name                 = var.k8_load_balancer_name
  description          = "Security group for kubernetes load balancer"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "k8_load_balancer_tunnel" {
  name                 = var.k8_load_balancer_tunnel_name
  description          = "Security group for kubernetes tunneled load balancer"
  delete_default_rules = true
}

locals {
  outgoing_access_groups = flatten([
    openstack_networking_secgroup_v2.k8_master,
    openstack_networking_secgroup_v2.k8_worker,
    openstack_networking_secgroup_v2.k8_load_balancer,
    openstack_networking_secgroup_v2.k8_load_balancer_tunnel,
    var.k8_master_client_group_ids,
    var.k8_worker_client_group_ids,
    var.k8_bastion_group_ids
  ])
  kubernetes_nodes_full_access_groups = [
    openstack_networking_secgroup_v2.k8_master,
    openstack_networking_secgroup_v2.k8_worker
  ]
  kubernetes_master_api_access_groups = flatten([
    openstack_networking_secgroup_v2.k8_load_balancer,
    openstack_networking_secgroup_v2.k8_load_balancer_tunnel,
    var.k8_master_client_group_ids,
    var.k8_bastion_group_ids
  ])
  kubernetes_worker_ingress_access_groups = flatten([
    openstack_networking_secgroup_v2.k8_load_balancer,
    openstack_networking_secgroup_v2.k8_load_balancer_tunnel,
    var.k8_worker_client_group_ids
  ])
  bastion_ssh_accessible_groups = [
    openstack_networking_secgroup_v2.k8_master,
    openstack_networking_secgroup_v2.k8_worker,
    openstack_networking_secgroup_v2.k8_load_balancer,
    openstack_networking_secgroup_v2.k8_load_balancer_tunnel
  ]
  externally_ssh_accessible_groups = flatten([
    var.k8_bastion_group_ids,
    openstack_networking_secgroup_v2.k8_load_balancer_tunnel
  ])
}

//Allow all v4 and v6 outbound traffic
resource "openstack_networking_secgroup_rule_v2" "outgoing_v4" {
  for_each = {
    for group in local.outgoing_access_groups : group.name => group
  }

  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = each.value.id
}

resource "openstack_networking_secgroup_rule_v2" "outgoing_v6" {
  for_each = {
    for group in local.outgoing_access_groups : group.name => group
  }

  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = each.value.id
}

//Allow all traffic between masters and workers
resource "openstack_networking_secgroup_rule_v2" "k8_master_full_access" {
  for_each = {
    for group in local.kubernetes_nodes_full_access_groups : group.name => group
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id  = each.value.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "k8_worker_full_access" {
  for_each = {
    for group in local.kubernetes_nodes_full_access_groups : group.name => group
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id  = each.value.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

//Allow masters api traffic from allowed groups
resource "openstack_networking_secgroup_rule_v2" "api_groups_k8_master_icmp_access_v4" {
  for_each = {
    for group in local.kubernetes_master_api_access_groups : group.name => group if group.name != "${var.namespace}-kubernetes-bastion"
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id  = each.value.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "api_groups_k8_master_icmp_access_v6" {
  for_each = {
    for group in local.kubernetes_master_api_access_groups : group.name => group if group.name != "${var.namespace}-kubernetes-bastion"
  }

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id  = each.value.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

resource "openstack_networking_secgroup_rule_v2" "api_groups_k8_master_api_access" {
  for_each = {
    for group in local.kubernetes_master_api_access_groups : group.name => group
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.masters_api_port
  port_range_max    = var.masters_api_port
  remote_group_id  = each.value.id
  security_group_id = openstack_networking_secgroup_v2.k8_master.id
}

//Allow workers ingress traffic from allowed groups
resource "openstack_networking_secgroup_rule_v2" "ingress_groups_k8_worker_icmp_access_v4" {
  for_each = {
    for group in local.kubernetes_worker_ingress_access_groups : group.name => group if group.name != "${var.namespace}-kubernetes-bastion"
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id  = each.value.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "ingress_groups_k8_worker_icmp_access_v6" {
  for_each = {
    for group in local.kubernetes_worker_ingress_access_groups : group.name => group if group.name != "${var.namespace}-kubernetes-bastion"
  }

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id  = each.value.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "ingress_groups_k8_worker_http_access" {
  for_each = {
    for group in local.kubernetes_worker_ingress_access_groups : group.name => group
  }
  
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.workers_ingress_http_port
  port_range_max    = var.workers_ingress_http_port
  remote_group_id   = each.value.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

resource "openstack_networking_secgroup_rule_v2" "ingress_groups_k8_worker_https_access" {
  for_each = {
    for group in local.kubernetes_worker_ingress_access_groups : group.name => group
  }
  
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.workers_ingress_https_port
  port_range_max    = var.workers_ingress_https_port
  remote_group_id   = each.value.id
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}

//Allow bastion ssh traffic to accessible groups
resource "openstack_networking_secgroup_rule_v2" "bastion_ssh_accessible_groups_icmp_access_v4" {
  for_each = {
    for group in local.bastion_ssh_accessible_groups : group.name => group
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"

  dynamic "remote_group_id" {
    for_each = var.bastion_group_ids
    content {
      remote_group_id   = remote_group_id.value
      security_group_id = each.value.id
    }
  }
}

resource "openstack_networking_secgroup_rule_v2" "bastion_ssh_accessible_groups_icmp_access_v6" {
  for_each = {
    for group in local.bastion_ssh_accessible_groups : group.name => group
  }

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"

  dynamic "remote_group_id" {
    for_each = var.bastion_group_ids
    content {
      remote_group_id   = remote_group_id.value
      security_group_id = each.value.id
    }
  }
}

resource "openstack_networking_secgroup_rule_v2" "bastion_ssh_accessible_groups_ssh_access" {
  for_each = {
    for group in local.bastion_ssh_accessible_groups : group.name => group
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22

  dynamic "remote_group_id" {
    for_each = var.bastion_group_ids
    content {
      remote_group_id   = remote_group_id.value
      security_group_id = each.value.id
    }
  }
}

//Allow external ssh traffic on accessible groups
resource "openstack_networking_secgroup_rule_v2" "externally_ssh_accessible_groups_ssh_access" {
  for_each = {
    for group in local.externally_ssh_accessible_groups : group.name => group
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = each.value.id
}

resource "openstack_networking_secgroup_rule_v2" "externally_ssh_accessible_groups_icmp_access_v4" {
  for_each = {
    for group in local.externally_ssh_accessible_groups : group.name => group
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = each.value.id
}

resource "openstack_networking_secgroup_rule_v2" "externally_ssh_accessible_groups_icmp_access_v6" {
  for_each = {
    for group in local.externally_ssh_accessible_groups : group.name => group
  }

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_ip_prefix  = "::/0"
  security_group_id = each.value.id
}

//Allow external traffic on the load balancer for the api, ingress and icmp
resource "openstack_networking_secgroup_rule_v2" "lb_api_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_ingress_http_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_ingress_https_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_icmp_external_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_icmp_external_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_ip_prefix  = "::/0"
  security_group_id = openstack_networking_secgroup_v2.k8_load_balancer.id
}

//Allow all nodeport inbound traffic from worker clients
resource "openstack_networking_secgroup_rule_v2" "k8_worker_client_access" {
  for_each          = { for idx, id in var.k8_worker_client_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32768
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.k8_worker.id
}