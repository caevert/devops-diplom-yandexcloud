###https://habr.com/ru/companies/domclick/articles/682364/

https://elatov.github.io/2022/10/using-kubespray-to-install-kubernetes/

sudo apt-get update -y
#sudo apt install software-properties-common
#sudo add-apt-repository ppa:deadsnakes/ppa
#sudo apt-get update -y
#sudo apt-get install git pip python3.9 -y



sudo apt install git software-properties-common build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev -y
wget https://www.python.org/ftp/python/3.9.19/Python-3.9.19.tgz
tar -xvf Python-3.9.19.tgz
cd Python-3.9.19/
./configure --enable-optimizations
make
sudo make altinstall

sudo -i
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.9 get-pip.py

# RETURN TO USER
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray/
git tag
git checkout v2.14.0
pip3.9 install -r requirements.txt

# Copy ``inventory/sample`` as ``inventory/mycluster``
cp -rfp inventory/sample inventory/mycluster

# Update Ansible inventory file with inventory builder
declare -a IPS=(192.168.100.22 192.168.10.29 192.168.200.23)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3.9 contrib/inventory_builder/inventory.py ${IPS[@]}

# Copy private ssh key to ansible host
scp -i ~/.ssh/yandex yandex ubuntu@158.160.169.171:.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa

ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v &


mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config


# if you faced problem with "Unable to connect to the server: x509: certificate is valid for XXX, not for XXX"
# then add "supplementary_addresses_in_ssl_keys" ips for file in inventory/sample/group_vars/k8s-cluster/k8s-cluster.yml
#supplementary_addresses_in_ssl_keys: [1.1.1.1, 2.2.2.2]

#https://elatov.github.io/2022/10/using-kubespray-to-install-kubernetes/

sudo apt install git software-properties-common build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev -y
wget https://www.python.org/ftp/python/3.9.19/Python-3.9.19.tgz
tar -xvf Python-3.9.19.tgz
cd Python-3.9.19/
./configure --enable-optimizations
make
sudo make altinstall

sudo -i
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.9 get-pip.py

sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sudo -i
git clone --branch v2.20.0 https://github.com/kubernetes-sigs/kubespray
cd kubespray/
sudo pip3 install -U -r requirements.txt
cp -rfp inventory/sample inventory/home
declare -a IPS=(192.168.100.22 192.168.10.29 192.168.200.23)
CONFIG_FILE=inventory/home/hosts.yaml python3.9 contrib/inventory_builder/inventory.py ${IPS[@]}
ansible-playbook -i inventory/home/hosts.yaml  --become --become-user=root cluster.yml
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
kubectl get pods -A
