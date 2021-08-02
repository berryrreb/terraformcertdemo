# ------------------------------------------------------------------------------
# Datas
# ------------------------------------------------------------------------------
data "google_compute_zones" "gcp-us-central1" {
  project                     = data.google_project.demo.project_id
  region                      = var.region
}
# ------------------------------------------------------------------------------
# Google VPC Network - VPC Networks - Externa IP Address
# ------------------------------------------------------------------------------
resource "google_compute_address" "tf-demo-instance-address" {
  project                     = data.google_project.demo.project_id
  name                        = "tf-demo-instance-address"
  region                      = var.region
}
# ------------------------------------------------------------------------------
# Google Compute Engine - VM instance and Disk
# ------------------------------------------------------------------------------
resource "google_compute_instance" "tf-demo-instance" {
  project                     = data.google_project.demo.project_id
  name                        = "tf-demo-instance"
  hostname                    = "tf-demo-instance.gpc-us-central1"
  machine_type                = "e2-micro"
  zone                        = data.google_compute_zones.gcp-us-central1.names[0]
  allow_stopping_for_update   = true
  boot_disk {
    initialize_params {
      image                   = "debian-cloud/debian-9"
    }
  }
  attached_disk {
    source                    = google_compute_disk.tf-demo-instance-disk-sdb.self_link
    device_name               = google_compute_disk.tf-demo-instance-disk-sdb.name
  }
  network_interface {
    subnetwork                = google_compute_subnetwork.tf_demo_nw.self_link
    network_ip                = "10.50.8.20"
    access_config {
      nat_ip                  = google_compute_address.tf-demo-instance-address.address
    }
  }
  deletion_protection         = true
  metadata = {
    sshKeys                   = "mauriciomelendez:${file("/Users/mauriciomelendez/.ssh/id_rsa.pub")}"
  }
  tags                        = [
                                  "tf-demo-instance-fw"
                                ]
}
resource "google_compute_disk" "tf-demo-instance-disk-sdb" {
  name                        = "tf-demo-instance-disk-sdb"
  project                     = data.google_project.demo.project_id
  type                        = "pd-standard"
  zone                        = data.google_compute_zones.gcp-us-central1.names[0]
  size                        = "8"
}
# ------------------------------------------------------------------------------
# Google VPC Network - Firewall - Policies
# ------------------------------------------------------------------------------
resource "google_compute_firewall" "tf-demo-instance-from-internet-ssh" {
  name                        = "tf-demo-instance-from-internet-ssh"
  network                     = google_compute_network.tf_demo_vpc.self_link
  direction                   = "INGRESS"
  project                     = data.google_project.demo.project_id
  source_ranges               = ["0.0.0.0/0"]
  allow {
    protocol                  = "tcp"
    ports                     = ["22"]
  }
  target_tags                 = ["tf-demo-instance-fw"]
  description                 = "From Internet:SSH"
}
resource "google_compute_firewall" "tf-demo-instance-to-internet-https" {
  name                        = "tf-demo-instance-to-internet-https"
  network                     = google_compute_network.tf_demo_vpc.self_link
  direction                   = "EGRESS"
  project                     = data.google_project.demo.project_id
  destination_ranges          = ["0.0.0.0/0"]
  allow {
    protocol                  = "tcp"
    ports                     = ["443"]
  }
  target_tags                 = ["tf-demo-instance-fw"]
  description                 = "To Internet:HTTPS"
}
resource "google_compute_firewall" "tf-demo-instance-to-internet-http" {
  name                        = "tf-demo-instance-to-internet-http"
  network                     = google_compute_network.tf_demo_vpc.self_link
  direction                   = "EGRESS"
  project                     = data.google_project.demo.project_id
  destination_ranges          = ["0.0.0.0/0"]
  allow {
    protocol                  = "tcp"
    ports                     = ["80"]
  }
  target_tags                 = ["tf-demo-instance-fw"]
  description                 = "To Internet:HTTP"
}