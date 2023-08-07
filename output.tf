output "k8_master_security_group" {
  value = openstack_networking_secgroup_v2.k8_master
}

output "k8_worker_security_group" {
  value = openstack_networking_secgroup_v2.k8_worker
}

output "k8_load_balancer_security_group" {
  value = openstack_networking_secgroup_v2.k8_load_balancer
}

output "k8_load_balancer_tunnel_security_group" {
  value = openstack_networking_secgroup_v2.k8_load_balancer_tunnel
}