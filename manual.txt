# Verify hostname on Master,Compute,Infra
hostname -f
# Verify hostname of each machine is pingable from Master,Compute,Infra
ping osmaster.192.168.189.139.nip.io
# Install Openshift Packages on Master,Compute,Infra
yum install -y wget git zile net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct openssl-devel httpd-tools  python-cryptography python2-pip python-devel python-passlib java-1.8.0-openjdk-headless "@Development Tools"
yum update
# Modify 'NetworkManager.conf' file on Master,Compute,Infra
vi /etc/NetworkManager/NetworkManager.conf
-----------------------------------------------------------------
[main]
#plugins=ifcfg-rh,ibft
dns=none
----------------------------------------------------------------
# Modify 'ifcfg-ens33' file on Master,Compute,Infra
cd /etc/sysconfig/network-scripts/
vi ifcfg-ens33
-----------------------------------------------------------------
PEERDNS="yes"
DNS1="8.8.8.8"
--------------------------------------------------------------------------
# Restart NetworkManager service on Master,Compute,Infra
systemctl restart NetworkManager 
# Modify 'resolv.conf' file on Master,Compute,Infra
vi /etc/resolv.conf
-----------------------------------------------------------------------------
search nip.io
nameserver 8.8.8.8
------------------------------------------------------
# Restart NetworkManager service on Master,Compute,Infra
systemctl restart NetworkManager
--------------------------------------------
# Reboot Master,Compute,Infra
reboot
---------------------------------------------------------------
# Install and enable epel 7 on Master,Compute,Infra
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
-------------------------------------------------------------
# Install docker on Master,Compute,Infra
yum install docker-1.13.1
docker version
# Configure persistent storage for Docker on Master,Compute,Infra
lsblk
vi /etc/sysconfig/docker-storage-setup 
----------------------------------------------------------------
DEVS=/dev/sdb
VG=docker-vgo
--------------------------------------------------------
# Enable docker & start service on Master,Compute,Infra
systemctl enable docker.service --now
systemctl status docker.service
------------------------------------------------------------
# Install ansible on Master machine
yum install ansible
ansible --version
# If ansible version is less than 2.4 or 2.8 then remove, install ansible 2.7 from package
yum remove ansible
rpm -Uvh https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.7.10-1.el7.ans.noarch.rpm
ansible --version
---------------------------------------------------------------
# Generate SSH Key on master machine and copy key on Compute and Infra
ssh-keygen
for host in 192.168.189.142 \
            192.168.189.141 \
			192.168.189.140; \
      do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; \
done
----------------------------------------------------------------------------------------------
# Create inventory.ini on master machine. get sample from git
vi inventory.ini
# Clone Openshift Origin source code
git clone https://github.com/openshift/openshift-ansible.git
# Checkout Origin 3.11 release 
cd openshift-ansible && git fetch && git checkout release-3.11 && cd ..
-----------------------------------------------------
# confirm selinux setting on Master,Compute,Infra
vi /etc/selinux/config
SELINUX=enforcing
SELINUXTYPE=targeted
-----------------------------------------------------------------------------------------
# Excute playbook on master machine
ansible-playbook -i inventory.ini openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i inventory.ini openshift-ansible/playbooks/deploy_cluster.yml
---------------------------------------------------------------------------------
# Reset password of system admin on master machine
htpasswd -c /etc/origin/master/htpasswd admin
