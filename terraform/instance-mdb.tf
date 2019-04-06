resource "google_compute_instance" "mdb" {
	name = "mdb"
	hostname = "mdb.btg.com"
	machine_type = "n1-standard-4"
	zone = "${var.region_zone}"

	depends_on = ["google_compute_instance.monitoring"]

	network_interface {
		subnetwork = "${google_compute_subnetwork.dev.name}"
		network_ip = "${google_compute_address.internal_mongodb.address}"
		access_config {
			# 
		}
	}

	boot_disk {
		initialize_params {
			image = "packer-1553992517"
			size = 20
		}
	}
	
	metadata {
		sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
	}

	provisioner "file" {
		source      = "files/mdb/mongodb-org-4.0.repo"
		destination = "/tmp/mongodb-org-4.0.repo"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "files/mdb/mongod.conf"
		destination = "/tmp/mongod.conf"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}
	
	provisioner "file" {
		source      = "files/mdb/provision.sh"
		destination = "/tmp/provision.sh"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "files/monitoring-agents/provision-monitoring.sh"
		destination = "/tmp/provision-monitoring.sh"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "files/mdb/users_roles.js"
		destination = "/tmp/users_roles.js"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "files/loader"
		destination = "~/OneMillionDoc"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "files/monitoring-agents/influxdb.repo"
		destination = "/tmp/influxdb.repo"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "files/monitoring-agents/telegraf.conf"
		destination = "/tmp/telegraf.conf"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "${var.account_file_path}"
		destination = "/tmp/gc-cred.json"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "remote-exec" {
        inline = [
          ". /tmp/provision.sh",
		  "sudo gcloud auth activate-service-account --key-file /tmp/gc-cred.json",
		  ". /tmp/provision-monitoring.sh",
		  "cd ~/OneMillionDoc",
		  "cat /dev/null > db_load_test.log",
		  "python3.7 main.py -d mongo -c bt4",
		  "sudo shutdown -h now"
        ]
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }

    }
}
