resource "google_compute_network" "tf_demo_vpc" {
  name                                = "tf-demo-vpc"
  project                             = data.google_project.demo.project_id
  auto_create_subnetworks             = false
}

resource "google_compute_subnetwork" "tf_demo_nw" {
  name                        = "tf-demo-nw"
  project                     = data.google_project.demo.project_id
  region                      = var.region
  network                     = google_compute_network.tf_demo_vpc.self_link
  ip_cidr_range               = "10.50.8.0/24"
}