resource "google_compute_instance" "monitoring" {
	name = "monitoring"
	hostname = "monitoring.btg.com"
	machine_type = "g1-small"
	zone = "${var.region_zone}"

	network_interface {
		subnetwork = "${google_compute_subnetwork.dev.name}"
		network_ip = "${google_compute_address.internal_monitoring.address}"
		access_config {
			# 
		}
	}

	boot_disk {
		initialize_params {
			image = "centos-cloud/centos-7"
		}
	}
	
	metadata {
		sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
	}

	provisioner "file" {
		source      = "files/monitoring-agents"
		destination = "/tmp"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "remote-exec" {
        inline = [
            "sudo yum -y update",
			". /tmp/monitoring-agents/provision.sh"
        ]
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }

    }
}
