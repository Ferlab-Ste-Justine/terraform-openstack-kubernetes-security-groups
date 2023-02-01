output "groups" {
  value = {
    bastion = openstack_networking_secgroup_v2.k8_bastion
    master_client = openstack_networking_secgroup_v2.k8_master_client
    worker_client = openstack_networking_secgroup_v2.k8_worker_client
    worker = openstack_networking_secgroup_v2.k8_worker
    master = openstack_networking_secgroup_v2.k8_master
    load_balancer = openstack_networking_secgroup_v2.k8_load_balancer
    load_balancer_tunnel = openstack_networking_secgroup_v2.k8_load_balancer_tunnel
  }
}