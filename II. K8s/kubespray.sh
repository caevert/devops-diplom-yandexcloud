###https://habr.com/ru/companies/domclick/articles/682364/

sudo apt-get update -y
#sudo apt install software-properties-common
#sudo add-apt-repository ppa:deadsnakes/ppa
#sudo apt-get update -y
#sudo apt-get install git pip python3.9 -y

#sudo -i
#curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#python3.9 get-pip.py

sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev -y
wget https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tgz
tar -xvf Python-3.9.7.tgz
cd Python-3.9.7/
./configure --enable-optimizations
make
sudo make altinstall
pip3.9 install -r requirements.txt
git tag
git checkout v2.10.0
pip3.9 install -r requirements.txt
cp -rfp inventory/sample inventory/mycluster
declare -a IPS=(192.168.200.5 192.168.100.24 192.168.10.30)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3.9 contrib/inventory_builder/inventory.py ${IPS[@]}

# RETURN TO USER
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray/
pip3.9 install -r requirements.txt

# Copy ``inventory/sample`` as ``inventory/mycluster``
cp -rfp inventory/sample inventory/mycluster

# Update Ansible inventory file with inventory builder
declare -a IPS=(192.168.200.5 192.168.100.24 192.168.10.30)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3.9 contrib/inventory_builder/inventory.py ${IPS[@]}

# Copy private ssh key to ansible host
scp -i ~/.ssh/yandex yandex yc-user@51.250.76.222:.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa

ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v &


mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config


# if you faced problem with "Unable to connect to the server: x509: certificate is valid for XXX, not for XXX"
# then add "supplementary_addresses_in_ssl_keys" ips for file in inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
supplementary_addresses_in_ssl_keys: [1.1.1.1, 2.2.2.2]