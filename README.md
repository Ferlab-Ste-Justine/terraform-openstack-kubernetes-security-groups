# About

This is a terraform module that provisions security groups meant to restrict network access to a Kubernetes cluster.

The following security groups are created:
- **worker**: Security group for kubernete workers nodes. It can access other workers and masters on any port.
- **master**: Security group for kubernete masters nodes. It can access other workers and masters on any port.
- **load_balancer**: Security group for a kubernetes load balancer. It can access the api port (default to 6443) on the masters and ingress ports (default to 30000 and 30001) on the workers. It opens up port 6443 (masters api) and ports 80 and 443 (workers ingress http and https accesses) for outside access.
- **load_balancer_tunnel**: Similar to the load balancer above, except that only port 22 is open for outside access. It is expected that external users will open an ssh tunnel on this load balancer and access the master api (6443) or workers ingress (80 and 443) via the localhost address of this load balancer.

Additionally, you can pass a list of groups that will fulfill each of the following roles:
- **bastion**: Security groups that will have access to the etcd servers on port **22** as well as icmp traffic.
- **master_client**: Security groups that will have direct access to the kubernetes master nodes on their master api port (defaults to **6443**).
- **worker_client**: Security groups that will have direct access to the kubernetes workers on the usual nodeport range (**30000** to **32768**) as well as the designed ingress nodeports (default to **30000** and **30001**).
- **metrics_server**: Security groups that will have access to the master and worker nodes on port **9100** as well as icmp traffic.

# Usage

## Variables

The module takes the following variables as input:

- **masters_api_port**: Http port of the api on the k8 masters. Defaults to 6443.
- **workers_ingress_http_port**: Http ingress nodeport on the kubernetes workers. Defaults to 30000.
- **workers_ingress_https_port**: Https ingress nodeport on the kubernetes workers. Defaults to 30001.
- **master_group_name**: Name to give the the security groups that is created for the k8 master nodes.
- **worker_group_name**: Name to give the the security groups that is created for the k8 worker nodes.
- **load_balancer_group_name**: Name to give the the security groups that is created for the load balancer nodes.
- **load_balancer_tunnel_group_name**: Name to give the the security groups that is created for the load balancer tunnel nodes.
- **master_client_groups**: Array of existing security groups for master clients. Elements should be of type **networking_secgroup_v2** (resource or data)
- **worker_client_groups**: Array of existing security groups for worker clients. Elements should be of type **networking_secgroup_v2** (resource or data)
- **bastion_groups**: Array of existing security groups for bastion. Elements should be of type **networking_secgroup_v2** (resource or data)
- **metrics_server_groups**: Array of existing security groups for metric server. Elements should be of type **networking_secgroup_v2** (resource or data)

## Output

The module outputs the following variables as output:

- **k8_master_security_group**: Security group for Kubernetes master nodes.
- **k8_worker_security_group**: Security group for Kubernetes worker nodes.
- **k8_load_balancer_security_group**: Security group for a Kubernetes load balancer.
- **k8_load_balancer_tunnel_security_group**: Security group for a Kubernetes tunneled load balancer.

Each output variable contains a resource of type openstack_networking_secgroup_v2.