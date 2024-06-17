### Разворачиваем VPC
resource "yandex_vpc_network" "diplom-vpc" {
  name        = "diplom-vpc"
  description = "My diplom project vpc"
}

resource "yandex_vpc_subnet" "zone1" {
  name           = "zone1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom-vpc.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "zone2" {
  name           = "zone2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diplom-vpc.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "zone3" {
  name           = "zone3"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.diplom-vpc.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
