#cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}
/*
variable "service_account_id" {
  type = string
  description = "https://yandex.cloud/ru/docs/iam/operations/sa/get-id#cli_1"
  
}
*/

variable "public_key" {
  type        = string
  description = "ssh ed25519 public key"
}