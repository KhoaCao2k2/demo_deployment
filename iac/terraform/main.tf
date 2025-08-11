terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.80.0"
    }
  }
  required_version = "1.12.2"
}

provider "google" {
  credentials = file(var.key)
  project     = var.project_id
  region      = var.region
}


// GKE
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region

  // Enabling Autopilot for this cluster
  # enable_autopilot = true
  
  remove_default_node_pool = true
  initial_node_count       = 1
  // Enable Istio (beta)
  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#nested_istio_config
  // not yet supported on Autopilot mode
  # addons_config {
  #   istio_config {
  #     disabled = false
  #     auth     = "AUTH_NONE"
  #   }
  # }
  node_config {
    disk_type    = "pd-standard"
    disk_size_gb = 20
    machine_type = "e2-small"
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1
  
  node_config {
    disk_type    = "pd-standard"
    disk_size_gb = 20
    machine_type = "e2-small"
    preemptible  = true
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}


// Firewall
resource "google_compute_firewall" "default" {
  name    = "firewall-rules"
  network = "${var.self_link}"
  description = "Allow ports for model deployment"

  allow {
    protocol = "tcp"
    ports    = ["30000"]
  }

  direction = "INGRESS"
  
  source_tags = ["web"]
}