resource "google_compute_address" "internal_grafana" {
  name         = "grafana"
  subnetwork   = "${google_compute_subnetwork.dev.self_link}"
  address_type = "INTERNAL"
  address      = "10.1.2.10"
}

resource "google_compute_address" "internal_mongodb" {
  name         = "mdb"
  subnetwork   = "${google_compute_subnetwork.dev.self_link}"
  address_type = "INTERNAL"
  address      = "10.1.2.11"
}

resource "google_compute_address" "internal_oracle" {
  name         = "oracle"
  subnetwork   = "${google_compute_subnetwork.dev.self_link}"
  address_type = "INTERNAL"
  address      = "10.1.2.12"
}

resource "google_compute_address" "internal_postgres" {
  name         = "pg"
  subnetwork   = "${google_compute_subnetwork.dev.self_link}"
  address_type = "INTERNAL"
  address      = "10.1.2.13"
}

resource "google_compute_address" "internal_loader" {
  name         = "loader"
  subnetwork   = "${google_compute_subnetwork.dev.self_link}"
  address_type = "INTERNAL"
  address      = "10.1.2.14"
}