resource "google_compute_instance" "postgres" {
	name = "postgres"
	hostname = "postgres.btg.com"
	machine_type = "n1-standard-4"
	zone = "${var.region_zone}"

	depends_on = ["google_compute_instance.monitoring"]

	network_interface {
		subnetwork = "${google_compute_subnetwork.dev.name}"
		network_ip = "${google_compute_address.internal_postgres.address}"
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
		source      = "files/postgresql/install.sh"
		destination = "/tmp/install.sh"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "files/postgresql/DDL.sql"
		destination = "/tmp/DDL.sql"
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }		
	}

	provisioner "file" {
		source      = "files/postgresql/create_user_and_db.sql"
		destination = "/tmp/create_user_and_db.sql"
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
		source      = "files/monitoring-agents/provision-monitoring.sh"
		destination = "/tmp/provision-monitoring.sh"
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

    provisioner "remote-exec" {
        inline = [
                ". /tmp/install.sh",
				"sudo gcloud auth activate-service-account --key-file /tmp/gc-cred.json",
				". /tmp/provision-monitoring.sh",
                "cd ~/OneMillionDoc",
                "cat /dev/null > db_load_test.log",
                "python3.7 main.py -d postgres -i 5 -n 100000 -c bt4",
                "python3.7 main.py -d postgres -i 5 -n 100000 -p 2 -c bt4",
                "python3.7 main.py -d postgres -i 5 -n 100000 -p 4 -c bt4",
                "python3.7 main.py -d postgres -i 5 -n 100000 -p 6 -c bt4",
                "python3.7 main.py -d postgres -i 5 -n 100000 -p 8 -c bt4",
                "python3.7 main.py -d postgres -i 5 -n 100000 -p 12 -c bt4",
                "python3.7 main.py -d postgres -i 5 -n 100000 -p 16 -c bt4",
                "cat db_load_test.log"
                ]
        connection {
            type = "ssh"
            user = "${var.gce_ssh_user}"
            private_key = "${file(var.gce_ssh_priv_key_file)}"
        }
	}
}
