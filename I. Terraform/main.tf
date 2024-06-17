#Выправить исходя https://github.com/yandex-cloud-examples/yc-s3-secure-bucket/blob/main/main.tf

// Генерация random-string для имени bucket
resource "random_string" "random" {
    length = 8
    special = false
    upper = false
  
}

// Создание управляющего sa для bucket
resource "yandex_iam_service_account" "bucketbot" {
    name = "bucketbot-${random_string.random.result}"
    description = ""
    folder_id = var.folder_id

}