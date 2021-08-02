# ------------------------------------------------------------------------------
# Google Kubernetes Engine - Cluster
# ------------------------------------------------------------------------------
resource "google_container_cluster" "tf_demo_gke" {
  provider                            = google
  project                             = data.google_project.demo.project_id
  name                                = "tf-demo-gke"
  description                         = "TF DEMO GKE"
  network                             = google_compute_network.tf_demo_vpc.self_link
  subnetwork                          = google_compute_subnetwork.tf_demo_nw.self_link
  location                            = var.region
  node_locations                      = [
                                          data.google_compute_zones.gcp-us-central1.names[0],
                                          data.google_compute_zones.gcp-us-central1.names[1],
                                          data.google_compute_zones.gcp-us-central1.names[2]
                                        ]
  remove_default_node_pool            = true
  initial_node_count                  = "1"
  enable_shielded_nodes               = true
  default_max_pods_per_node           = 110
  min_master_version                  = "1.20.8-gke.2100"
  release_channel {
    channel                           = "UNSPECIFIED"
  }
  ip_allocation_policy {  }
  private_cluster_config {
    enable_private_nodes              = true
    # enable_private_endpoint           = false
    enable_private_endpoint           = true
    master_ipv4_cidr_block            = "10.50.224.32/28"
    master_global_access_config {
      enabled                         = true
    }
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block                      = "10.50.8.20/32"
      display_name                    = "tf-demo-instance"
    }
  }
  workload_identity_config {
    identity_namespace                = "mauriciomelendezdou.svc.id.goog"
  }
}
# ------------------------------------------------------------------------------
# Google Kubernetes Engine - Node Pool
# ------------------------------------------------------------------------------
resource "google_container_node_pool" "tf_demo_gkenp" {
  provider                            = google
  project                             = data.google_project.demo.project_id
  cluster                             = google_container_cluster.tf_demo_gke.name
  name                                = "tf-demo-gkenp"
  location                            = var.region
  node_locations                      = [
                                          data.google_compute_zones.gcp-us-central1.names[0],
                                          data.google_compute_zones.gcp-us-central1.names[1],
                                          data.google_compute_zones.gcp-us-central1.names[2]
                                        ]
  initial_node_count                  = 1
  version                             = "1.20.8-gke.2100"
  node_config {
    machine_type                      = "n1-standard-2"
    preemptible                       = true
    image_type                        = "COS"
    disk_size_gb                      = "30"
    disk_type                         = "pd-standard" 
    oauth_scopes                      = [
                                          "https://www.googleapis.com/auth/devstorage.read_only",
                                          "https://www.googleapis.com/auth/logging.write",
                                          "https://www.googleapis.com/auth/monitoring",
                                          "https://www.googleapis.com/auth/servicecontrol",
                                          "https://www.googleapis.com/auth/service.management.readonly",
                                          "https://www.googleapis.com/auth/trace.append",
                                    ]
    shielded_instance_config {
      enable_secure_boot              = true
    }
    workload_metadata_config {
      node_metadata                   = "GKE_METADATA_SERVER"
    }
    tags                              = ["tf-demo-gke"]
  }
  management {
    auto_repair                       = true
    auto_upgrade                      = false
  }
}