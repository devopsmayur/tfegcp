terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "hc-298fe22b114c4f4f8961e031e5c"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

check "check_vm_status" {
  data "google_compute_instance" "vm_instance" {
    name = google_compute_instance.vm_instance.name
  }
  assert {
    condition = data.google_compute_instance.vm_instance.current_status == "RUNNING"
    error_message = format("Provisioned VMs should be in a RUNNING status, instead the VM `%s` has status: %s",
      data.google_compute_instance.vm_instance.name,
      data.google_compute_instance.vm_instance.current_status
    )
  }
}
