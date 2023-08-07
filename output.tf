output "member_group" {
  value = openstack_networking_secgroup_v2.kubernetes_member
  worker = openstack_networking_secgroup_v2.k8_worker
  master = openstack_networking_secgroup_v2.k8_master
  load_balancer = openstack_networking_secgroup_v2.k8_load_balancer
  load_balancer_tunnel = openstack_networking_secgroup_v2.k8_load_balancer_tunnel
}