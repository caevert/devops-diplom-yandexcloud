

### Разворачиваем инстансы
resource "yandex_compute_instance" "master-node" {
  platform_id = "standart-v1"
  name        = "master"
  zone        = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      name     = "master-node"
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.zone1.id
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }
}
  
