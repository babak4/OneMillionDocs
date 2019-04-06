resource "google_compute_network" "platform" {
  name       = "${var.network_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dev" {
  name          = "dev-${var.network_name}-${var.region}"
  ip_cidr_range = "10.1.2.0/24"
  network       = "${google_compute_network.platform.self_link}"
  region        = "${var.region}"
}

resource "google_compute_firewall" "www" {
  name = "btnet-firewall"
  network = "${google_compute_network.platform.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["22", "443", "3000", "8086", "8088"]
  }

  source_ranges = ["0.0.0.0/0"]
}

