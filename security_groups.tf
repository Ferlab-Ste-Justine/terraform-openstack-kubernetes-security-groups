resource "openstack_networking_secgroup_v2" "kubernetes_member" {
   name                 = var.member_group_name
   description          = "Security group for kubernetes members"
   delete_default_rules = true
 }

# Allow all outbound traffic from kubernetes members
resource "openstack_networking_secgroup_rule_v2" "etcd_member_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "etcd_member_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}


//Allow external traffic on the load balancer for the api, ingress and icmp
resource "openstack_networking_secgroup_rule_v2" "lb_api_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_ingress_http_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_ingress_https_external" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_icmp_external_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "lb_icmp_external_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_ip_prefix  = "::/0"
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

//Allow all nodeport inbound traffic from worker clients
resource "openstack_networking_secgroup_rule_v2" "k8_worker_client_access" {
  for_each          = { for idx, id in var.k8_worker_client_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32768
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

//Allow all traffic between masters and workers
resource "openstack_networking_secgroup_rule_v2" "k8_master_worker_full_access" {
  for_each          = { for idx, id in var.kubernetes_nodes_full_access_groups_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

//Allow masters api traffic from allowed groups
resource "openstack_networking_secgroup_rule_v2" "api_groups_k8_master_icmp_access_v4" {
  for_each          = { for idx, id in var.kubernetes_master_api_access_groups_ids : idx => id }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id  = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "api_groups_k8_master_icmp_access_v6" {
  for_each          = { for idx, id in var.kubernetes_master_api_access_groups_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "api_groups_k8_master_api_access" {
  for_each          = { for idx, id in var.kubernetes_master_api_access_groups_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.masters_api_port
  port_range_max    = var.masters_api_port
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

//Allow workers ingress traffic from allowed groups
resource "openstack_networking_secgroup_rule_v2" "ingress_groups_k8_worker_icmp_access_v4" {
  for_each          = { for idx, id in var.kubernetes_worker_ingress_access_groups_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "ingress_groups_k8_worker_icmp_access_v6" {
  for_each          = { for idx, id in var.kubernetes_worker_ingress_access_groups_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "ingress_groups_k8_worker_http_access" {
  for_each          = { for idx, id in var.kubernetes_worker_ingress_access_groups_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.workers_ingress_http_port
  port_range_max    = var.workers_ingress_http_port
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "ingress_groups_k8_worker_https_access" {
  for_each          = { for idx, id in var.kubernetes_worker_ingress_access_groups_ids : idx => id }  
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.workers_ingress_https_port
  port_range_max    = var.workers_ingress_https_port
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

//Allow bastion ssh traffic to accessible groups
resource "openstack_networking_secgroup_rule_v2" "bastion_ssh_accessible_group_ids_icmp_access_v4" {
  for_each          = { for idx, id in var.bastion_ssh_accessible_group_ids : idx => id } 
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_ssh_accessible_group_ids_icmp_access_v6" {
  for_each          = { for idx, id in var.bastion_ssh_accessible_group_ids : idx => id } 
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_ssh_accessible_group_ids_ssh_access" {
  for_each          = { for idx, id in var.bastion_ssh_accessible_group_ids : idx => id } 
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.kubernetes_member.id
}

//Allow external ssh traffic on accessible groups
resource "openstack_networking_secgroup_rule_v2" "externally_ssh_accessible_groups_ids_ssh_access" {
  for_each          = { for idx, id in var.externally_ssh_accessible_groups_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = each.value
}

resource "openstack_networking_secgroup_rule_v2" "externally_ssh_accessible_groups_ids_icmp_access_v4" {
  for_each          = { for idx, id in var.externally_ssh_accessible_groups_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = each.value
}

resource "openstack_networking_secgroup_rule_v2" "externally_ssh_accessible_groups_ids_icmp_access_v6" {
  for_each          = { for idx, id in var.externally_ssh_accessible_groups_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_ip_prefix  = "::/0"
  security_group_id = each.value
}