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

----

### Переделать

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя

2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  backends/configuration
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)

----

3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
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
  
[Выбран деплой через kubespray:](II.%20K8s/kubespray.sh)

Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.

```bash
ubuntu@node1:~/kubespray$ cat ~/.kube/config 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CR...==
    server: https://127.0.0.1:6443
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
    client-certificate-data: LS0tLS1CRU...==
    client-key-data: LS0tLS1CRUdJ...=
```

3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

```bash
ubuntu@node1:~/kubespray$ kubectl get pods --all-namespaces
NAMESPACE     NAME                              READY   STATUS    RESTARTS   AGE
kube-system   calico-node-7kpj4                 1/1     Running   0          13m
kube-system   calico-node-9br6n                 1/1     Running   0          13m
kube-system   calico-node-hgpxs                 1/1     Running   0          13m
kube-system   coredns-74d6c5659f-9dr4c          1/1     Running   0          12m
kube-system   coredns-74d6c5659f-tvzp8          1/1     Running   0          12m
kube-system   dns-autoscaler-59b8867c86-kt65c   1/1     Running   0          12m
kube-system   kube-apiserver-node1              1/1     Running   1          15m
kube-system   kube-controller-manager-node1     1/1     Running   1          15m
kube-system   kube-proxy-7zspk                  1/1     Running   0          14m
kube-system   kube-proxy-87qj8                  1/1     Running   0          14m
kube-system   kube-proxy-s2sp7                  1/1     Running   0          14m
kube-system   kube-scheduler-node1              1/1     Running   1          15m
kube-system   nginx-proxy-node2                 1/1     Running   0          12m
kube-system   nginx-proxy-node3                 1/1     Running   0          13m
kube-system   nodelocaldns-7k7qs                1/1     Running   0          12m
kube-system   nodelocaldns-nnpvq                1/1     Running   0          12m
kube-system   nodelocaldns-qphzq                1/1     Running   0          12m
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

[GitHub repo for my app](https://github.com/Muroway/logomaker-nginx)

2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

[Logomaker image in Yandex Container Registry](https://console.yandex.cloud/folders/b1g96o71ipj82qfd6304/container-registry/registries/crphve47f826uus3t4li/overview/logomaker/image)

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

1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

```bash
kubectl get svc -A
NAMESPACE     NAME                                             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
default       kubernetes                                       ClusterIP   10.233.0.1      <none>        443/TCP                         121m
default       nginx-mtool-svc                                  ClusterIP   10.233.43.169   <none>        9001/TCP,9002/TCP               60m
default       nginx-mtool-svc-np                               NodePort    10.233.48.228   <none>        9001:30080/TCP,9002:31443/TCP   59m
kube-system   coredns                                          ClusterIP   10.233.0.3      <none>        53/UDP,53/TCP,9153/TCP          118m
kube-system   kube-prometheus-stack-coredns                    ClusterIP   None            <none>        9153/TCP                        26m
kube-system   kube-prometheus-stack-kube-controller-manager    ClusterIP   None            <none>        10257/TCP                       26m
kube-system   kube-prometheus-stack-kube-etcd                  ClusterIP   None            <none>        2381/TCP                        26m
kube-system   kube-prometheus-stack-kube-proxy                 ClusterIP   None            <none>        10249/TCP                       26m
kube-system   kube-prometheus-stack-kube-scheduler             ClusterIP   None            <none>        10259/TCP                       26m
kube-system   kube-prometheus-stack-kubelet                    ClusterIP   None            <none>        10250/TCP,10255/TCP,4194/TCP    105m
monitoring    alertmanager-operated                            ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP      26m
monitoring    grafana-node-port-service                        NodePort    10.233.57.232   <none>        80:30577/TCP                    3s
monitoring    kube-prometheus-stack-alertmanager               ClusterIP   10.233.54.92    <none>        9093/TCP,8080/TCP               26m
monitoring    kube-prometheus-stack-grafana                    ClusterIP   10.233.50.129   <none>        80/TCP                          26m
monitoring    kube-prometheus-stack-kube-state-metrics         ClusterIP   10.233.42.108   <none>        8080/TCP                        26m
monitoring    kube-prometheus-stack-operator                   ClusterIP   10.233.60.208   <none>        443/TCP                         26m
monitoring    kube-prometheus-stack-prometheus                 ClusterIP   10.233.47.178   <none>        9090/TCP,8080/TCP               26m
monitoring    kube-prometheus-stack-prometheus-node-exporter   ClusterIP   10.233.53.212   <none>        9100/TCP                        26m
monitoring    prometheus-operated                              ClusterIP   None            <none>        9090/TCP                        26m
monitoring    prometheus-server-ext                            NodePort    10.233.36.75    <none>        9090:30023/TCP                  119s
```

![My Grafana k8s cluster dashboard](./IV.Monitoring/assets/Dashboard%20Grafana.png)
---

### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.

2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

[Репозиторий приложения](https://github.com/Muroway/logomaker-nginx)

[CI/CD pipeline для GitHub Actions](https://github.com/Muroway/logomaker-nginx/blob/main/.github/workflows/docker-image.yml)

---

## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)
