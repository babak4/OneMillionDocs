resource "google_compute_address" "internal_monitoring" {
  name         = "grafana"
  subnetwork   = "${google_compute_subnetwork.dev.self_link}"
  address_type = "INTERNAL"
  address      = "10.1.2.10"
}
