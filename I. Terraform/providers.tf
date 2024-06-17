terraform {
    required_providers {
        yandex = {
            source = "yandex-cloud/yandex"
            version = "~> 0.5"
        }
    }
    required_version = ">=0.13"

/*
    backend "s3" {
        endpoint = "storage.yandexcloud.net"
        bucket = "drutskoi-bucket"
        region = "ru-central1"
        key    = "terraform.tfstate"
        skip_region_validation      = true
        skip_credentials_validation = true
        }
}
*/

provider "yandex" {
    token = var.token
    cloud_id = var.cloud_id
    folder_id = var.folder_id
#   zone      = "ru-central1"
}