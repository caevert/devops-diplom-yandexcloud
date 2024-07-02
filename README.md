# Дипломный практикум в Yandex.Cloud

* [Цели:](#цели)
* [Этапы выполнения:](#этапы-выполнения)
  * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
  * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
  * [Создание тестового приложения](#создание-тестового-приложения)
  * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
  * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
* [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
* [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---

## Цели

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---

## Этапы выполнения

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

* Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
* Следует использовать версию [Terraform](https://www.terraform.io/) не старше 1.5.x .

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя

2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  backends/configuration
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)

3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.

[Конфигурация terraform](I.Terraform/)

![Terraform apply](./assets/Terraform%20apply.png)

![Service accounts](./assets/Service%20accounts%20YC.png)

![S3 backend for terraform tfstate in YC Object Storage](./assets/S3%20backend%20tfstate%20YC.png)

![VMS in YC](./assets/VMs%20in%20YC.png)

2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Выбран деплой через kubespray:

```bash
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
[WARNING]: Skipping callback plugin 'ara_default', unable to load

PLAY [localhost] *****************************************************************
Tuesday 02 July 2024  08:45:39 +0000 (0:00:00.103)       0:00:00.103 ********** 

TASK [Check 2.11.0 <= Ansible version < 2.13.0] **********************************
ok: [localhost] => {
    "changed": false,
    "msg": "All assertions passed"
}
Tuesday 02 July 2024  08:45:39 +0000 (0:00:00.027)       0:00:00.130 ********** 

TASK [Check that python netaddr is installed] ************************************
ok: [localhost] => {
    "changed": false,
    "msg": "All assertions passed"
}
Tuesday 02 July 2024  08:45:39 +0000 (0:00:00.078)       0:00:00.209 ********** 

TASK [Check that jinja is not too old (install via pip)] *************************
ok: [localhost] => {
    "changed": false,
    "msg": "All assertions passed"
}
...
Tuesday 02 July 2024  09:46:39 +0000 (0:00:00.065)       0:13:46.912 ********** 
Tuesday 02 July 2024  09:46:39 +0000 (0:00:00.034)       0:13:46.947 ********** 
Tuesday 02 July 2024  09:46:40 +0000 (0:00:00.035)       0:13:46.982 ********** 

PLAY RECAP ***********************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
master                     : ok=757  changed=108  unreachable=0    failed=0    skipped=1264 rescued=0    ignored=8   
worker1                    : ok=541  changed=80   unreachable=0    failed=0    skipped=782  rescued=0    ignored=2   
worker2                    : ok=541  changed=82   unreachable=0    failed=0    skipped=782  rescued=0    ignored=2   

Tuesday 02 July 2024  09:46:40 +0000 (0:00:00.080)       0:13:47.062 ********** 
=============================================================================== 
kubernetes/kubeadm : Join to cluster ------------------------------------- 39.50s
network_plugin/calico : Wait for calico kubeconfig to be created --------- 33.67s
download : download_file | Validate mirrors ------------------------------ 25.93s
kubernetes/control-plane : kubeadm | Initialize first master ------------- 24.01s
download : download_container | Download image if required --------------- 18.69s
download : download_container | Download image if required --------------- 18.16s
etcd : Gen_certs | Write etcd member/admin and kube_control_plane clinet certs to other etcd nodes -- 16.29s
download : download_container | Download image if required --------------- 15.50s
download : download_container | Download image if required --------------- 14.83s
kubernetes/node : install | Copy kubelet binary from download dir -------- 13.77s
download : download_container | Download image if required --------------- 13.35s
network_plugin/calico : Calico | Copy calicoctl binary from download dir -- 11.89s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources -------------- 11.35s
kubernetes/preinstall : Preinstall | wait for the apiserver to be running --- 9.79s
download : download_container | Download image if required ---------------- 9.38s
download : download_container | Download image if required ---------------- 9.29s
download : download_container | Download image if required ---------------- 8.74s
download : download_container | Download image if required ---------------- 6.84s
kubernetes/node : Pre-upgrade | check if kubelet container exists --------- 6.37s
container-engine/containerd : containerd | Unpack containerd archive ------ 6.24s
```

Ожидаемый результат:

1. Работоспособный Kubernetes кластер.

```bash
kubectl get no -A
NAME      STATUS   ROLES           AGE     VERSION
master    Ready    control-plane   4m41s   v1.24.6
worker1   Ready    <none>          3m26s   v1.24.6
worker2   Ready    <none>          3m26s   v1.24.6
```

2. В файле `~/.kube/config` находятся данные для доступа к кластеру.

```bash
vim ~/.kube/config 

apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBD...==
    server: https://158.160.146.180:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUS...==
    client-key-data: LS0tLS1CRUdJTiBSU0EgU...==
```

3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

```bash
kubectl get pods -A
NAMESPACE     NAME                              READY   STATUS    RESTARTS   AGE
kube-system   calico-node-9lqnt                 1/1     Running   0          2m40s
kube-system   calico-node-fcvwn                 1/1     Running   0          2m40s
kube-system   calico-node-mz6rw                 1/1     Running   0          2m40s
kube-system   coredns-74d6c5659f-4t99r          1/1     Running   0          94s
kube-system   coredns-74d6c5659f-pwcfz          1/1     Running   0          87s
kube-system   dns-autoscaler-59b8867c86-wbd7k   1/1     Running   0          90s
kube-system   kube-apiserver-master             1/1     Running   1          4m20s
kube-system   kube-controller-manager-master    1/1     Running   1          4m21s
kube-system   kube-proxy-jkx96                  1/1     Running   0          3m10s
kube-system   kube-proxy-s8hsx                  1/1     Running   0          3m10s
kube-system   kube-proxy-sj8wj                  1/1     Running   0          3m10s
kube-system   kube-scheduler-master             1/1     Running   1          4m20s
kube-system   nginx-proxy-worker1               1/1     Running   0          119s
kube-system   nginx-proxy-worker2               1/1     Running   0          116s
kube-system   nodelocaldns-fcrch                1/1     Running   0          89s
kube-system   nodelocaldns-hxzhp                1/1     Running   0          89s
kube-system   nodelocaldns-ktjjf                1/1     Running   0          89s
```

---

### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.

[Репозиторий моего приложения](https://github.com/Muroway/logomaker-nginx)

2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

![Logomaker image in Yandex Container Registry](./assets/Yandex%20Container%20Registry.png)

---

### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:

1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:

1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:

Выбрано разворачивание через kube-prometheus-stack:

```bash
kubectl create namespace monitoring
namespace/monitoring created
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring
NAME: kube-prometheus-stack
LAST DEPLOYED: Tue Jul  2 09:53:18 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
kubectl expose service kube-prometheus-stack-grafana --type=NodePort --target-port=3000 --name=grafana-node-port-service -n monitoring
service/grafana-node-port-service exposed
```

1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.

[Файл kubeconfig](IV.Monitoring/kubeconfig)

2. Http доступ к web интерфейсу grafana.

[Доступ к интерфейсу grafana](http://158.160.146.180:30813/)

3. Дашборды в grafana отображающие состояние Kubernetes кластера.

![Дашборд Grafana](./assets/Grafana%20Dashboard.png)

4. Http доступ к тестовому приложению.

[Тестовое приложение](http://158.160.146.180:30180/)

![Тестовое приложение](./assets/Test%20application.png)

---

### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.

2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.

[CI/CD сервис в GitHub Actions](https://github.com/Muroway/logomaker-nginx/actions)

[Пайплайн](https://github.com/Muroway/logomaker-nginx/blob/main/.github/workflows/docker-image.yml)

![GitHub Actions](./assets/GitHub%20Actions%20CICD.png)

2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.

![Сборка образа при пуше в main](./assets/Docker%20Image%20YC%20building%20.png)

3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

![Развертывание образа при пуше тега c указанием v*](./assets/Docker%20Image%20k8s%20deploy.png)

---

## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.

[Репозиторий с конфигурацией Terraform](https://github.com/Muroway/devops-diplom-yandexcloud/tree/main/I.Terraform)

2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.

![Пуш в CICD](./assets/Push%20in%20CICD.png)

3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.

[Конфигурация hosts.yaml для ansible kubespray](https://github.com/Muroway/devops-diplom-yandexcloud/blob/main/II.K8s/hosts.yaml)

4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.

[Репозиторий c Dockerfile](https://github.com/Muroway/logomaker-nginx/blob/main/Dockerfile)

5. Репозиторий с конфигурацией Kubernetes кластера.

[Конфигурация](https://github.com/Muroway/devops-diplom-yandexcloud/blob/main/II.K8s/kubeconfig)

6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.

[Тестовое приложение](https://github.com/Muroway/logomaker-nginx)

[Интерфейс Grafana](http://158.160.146.180:30813/) логин/пароль по-умолчанию

7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

[Мой диплом](https://github.com/Muroway/devops-diplom-yandexcloud/tree/main)
