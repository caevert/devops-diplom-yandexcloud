sudo apt update
sudo apt install git docker.io software-properties-common build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev -y
1
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
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
exit
cd ..
git clone --branch v2.20.0 https://github.com/kubernetes-sigs/kubespray
cd kubespray/
sudo pip3 install -U -r requirements.txt
cp -rfp inventory/sample inventory/mycluster
declare -a IPS=(192.168.10.100 192.168.200.17 192.168.100.17)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3.9 contrib/inventory_builder/inventory.py ${IPS[@]}

Откройте сгенерированный inventory/mycluster/hosts.yaml файл и настройте его так, чтобы controller-0, controller-1 и controller-2 были узлами плоскости управления, а worker-0, worker-1 и worker-2 были рабочими узлами. 
Также обновите ip на соответствующий локальный IP VPC и удалите access_ip.

Основная конфигурация кластера хранится в inventory/mycluster/group_vars/k8s_cluster/k8s_cluster.yml. 
В этом файле мы обновим supplementary_addresses_in_ssl_keys список IP-адресов узлов контроллера. 
Таким образом, мы сможем получить доступ к серверу API Kubernetes как администратор из-за пределов сети VPC. 
Вы также можете видеть, что kube_network_pluginпо умолчанию установлено значение «calico». 
Если установить значение «cloud», на момент тестирования оно не работало на GCP.

scp -i ~/.ssh/yandex yandex ubuntu@158.160.169.171:.ssh/id_rsa
sudo chmod 600 ~/.ssh/id_rsa
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml


mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
kubectl get pods -A
# curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo update

# systemctl start docker

# echo 'KUBELET_EXTRA_ARGS="--node-ip=158.160.165.96"' > /etc/sysconfig/kubelet

# # add --kubernetes-version, --pod-network-cidr and --token options if needed
# kubeadm init --control-plane-endpoint "158.160.165.96:16443" --apiserver-advertise-address "158.160.165.96" \
# --ignore-preflight-errors=DirAvailable--var-lib-etcd

# cp kubernetes/admin.conf ~/.kube/config

# # Verify resutl
# kubectl cluster-info

# # wait for some time and delete old node
# sleep 120
# kubectl get nodes --sort-by=.metadata.creationTimestamp
# kubectl delete node $(kubectl get nodes -o jsonpath='{.items[?(@.status.conditions[0].status=="Unknown")].metadata.name}')



#Сохраняем секреты для доступа к Yandex Container Registry и пулла образов
https://yandex.cloud/ru/docs/container-registry/operations/authentication

kubectl create secret generic docker-yc \
  --namespace=myapp \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson