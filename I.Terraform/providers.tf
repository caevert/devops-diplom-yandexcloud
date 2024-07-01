terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.5"
    }
  }
  required_version = ">=0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "drutskoy-state-bucket"
    region     = "ru-central1-a"
    key        = "terraform/infrastructure1/terraform.tfstate"
    access_key = "YCAJEFEofzReMdzfqvyz9uK2N"
    secret_key = "YCN3fDkITpucWV1A5VTEofhDK1Q9pONvlf8PWiHw"

    skip_region_validation      = true
    skip_credentials_validation = true
  }

}
provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  #   zone      = "ru-central1"
}
