# Create an OSEv3 group that contains the masters, nodes, and etcd groups
[OSEv3:children]
masters
nodes
etcd

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=root
# If ansible_ssh_user is not root, ansible_become must be set to true
ansible_become=true
openshift_master_default_subdomain=master.openshift.com
deployment_type=origin

[nodes:vars]
openshift_disable_check=disk_availability,memory_availability,docker_storage
[masters:vars]
openshift_disable_check=disk_availability,memory_availability,docker_storage
# uncomment the following to enable htpasswd authentication; defaults to DenyAllPasswordIdentityProvider
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

# host group for masters
[masters]
172.16.11.193

# host group for etcd
[etcd]
172.16.11.193

# host group for nodes, includes region info
[nodes]
172.16.11.193  openshift_node_group_name='master.openshift.com'
172.16.11.195  openshift_node_group_name='node.openshift.com'
