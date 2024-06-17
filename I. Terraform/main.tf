### Разворачиваем мастер ноду
resource "yandex_compute_instance" "master-node" {
  platform_id = "standard-v2"
  name        = "master"
  zone        = "ru-central1-d"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      name     = "master-node"
      size     = 50
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.zone3.id
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }
}

### Разворачиваем воркеры
resource "yandex_compute_instance" "worker-node1" {
  platform_id = "standard-v1"
  name        = "slave1"
  zone        = "ru-central1-b"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      name     = "worker-node1"
      size     = 50
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.zone2.id
    #nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }
}

resource "yandex_compute_instance" "worker-node2" {
  platform_id = "standard-v1"
  name        = "slave2"
  zone        = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      name     = "worker-node2"
      size     = 50
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.zone1.id
    #nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }
}
