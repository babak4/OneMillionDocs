resource "google_compute_instance" "mdb" {
	name = "mdb"
	hostname = "mdb.btg.com"
	machine_type = "n1-standard-4"
	zone = "${var.region_zone}"

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
			size = 10
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
		source      = "files/mdb/users_roles.js"
		destination = "/tmp/users_roles.js"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "files/loader-install/install-python.sh"
		destination = "/tmp/install-python.sh"
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
		source      = "files/mdb/telegraf.conf"
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
		  ". /tmp/install-python.sh",
          ". /tmp/provision.sh",
		  "sudo gcloud auth activate-service-account --key-file /tmp/gc-cred.json",
		  "cd ~/OneMillionDoc",
		  "cat /dev/null > db_load_test.log",
		  "python3.7 main.py -d mongo -n 100000 -p 4 -c bt4",
		  "cat db_load_test.log"
        ]
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }

    }
}
