output "master_public_ip" {
  value = yandex_compute_instance.master-node.network_interface[0].nat_ip_address
}
output "master_internal_ip" {
  value = yandex_compute_instance.master-node.network_interface[0].ip_address
}
output "worker1_internal_ip" {
  value = yandex_compute_instance.worker-node1.network_interface[0].ip_address
}
output "worker1_public_ip" {
  value = yandex_compute_instance.worker-node1.network_interface[0].nat_ip_address
}
output "worker2_internal_ip" {
  value = yandex_compute_instance.worker-node2.network_interface[0].ip_address
}
output "worker2_public_ip" {
  value = yandex_compute_instance.worker-node2.network_interface[0].nat_ip_address
}
