# About

This is a terraform module that provisions security groups meant to restrict network access to a Kubernetes cluster.

The following security groups are created:
- **bastion**: A security group that can access port 22 on all nodes of the kubernetes cluster and opens port 22 externally.
- **worker**: Security group for kubernete workers nodes. It can access other workers and masters on any port.
- **master**: Security group for kubernete masters nodes. It can access other workers and masters on any port.
- **load_balancer**: Security group for a kubernetes load balancer. It can access the api port (default to 6443) on the masters and ingress ports (default to 30000 and 30001) on the workers. It opens up port 6443 (masters api) and ports 80 and 443 (workers ingress http and https accesses) for outside access.
- **load_balancer_tunnel**: Similar to the load balancer above, except that only port 22 is open for outside access. It is expected that external users will open an ssh tunnel on this load balancer and access the master api (6443) or workers ingress (80 and 443) via the localhost address of this load balancer.
- **master_client**: Will have direct access to the kubernetes master nodes on their master api port (defaults to 6443).
- **worker_client**: Will have direct access to the kubernetes workers on the usual nodeport range (30000 to 32768) as well as the designed ingress nodeports (default to 30000 and 30001).

The **master**, **worker**, **load_balancer** and **load_balancer_tunnel** security groups are self-contained. They can be applied by themselves on vms with no other security groups and the vms will be functional in their role.

The **master_client**, **worker_client** and **bastion** security groups are now expected to be input groups in array format, allowing for more flexibility and customization.

# Usage

## Variables

The module takes the following variables as input:

- **masters_api_port**: Http port of the api on the k8 masters. Defaults to 6443.
- **workers_ingress_http_port**: Http ingress nodeport on the kubernetes workers. Defaults to 30000.
- **workers_ingress_https_port**: Https ingress nodeport on the kubernetes workers. Defaults to 30001.
- **k8_master_client_group_ids**: Array of existing security group IDs for master clients.
- **k8_worker_client_group_ids**: Array of existing security group IDs for worker clients.
- **k8_bastion_group_ids**: Array of existing security group IDs for bastion.

## Output

The module outputs the following variables as output:

- **k8_master_security_group**: Security group for Kubernetes master nodes.
- **k8_worker_security_group**: Security group for Kubernetes worker nodes.
- **k8_load_balancer_security_group**: Security group for a Kubernetes load balancer.
- **k8_load_balancer_tunnel_security_group**: Security group for a Kubernetes tunneled load balancer.

Each output variable contains a resource of type openstack_networking_secgroup_v2.