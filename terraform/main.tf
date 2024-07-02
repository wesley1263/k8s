provider "google" {
  credentials = file("~/terraform-key.json")
  project     = "divine-precinct-428122-a7"
  region      = "us-central1"
}

resource "google_project_service" "container" {
  project = "divine-precinct-428122-a7"
  service = "container.googleapis.com"
}

resource "google_container_cluster" "primary" {
  depends_on         = [google_project_service.container]
  name               = "devops-cluster"
  location           = "us-central1"
  initial_node_count = 1
  deletion_protection = false

  node_config {
    machine_type = "e2-medium" # Máquina simples e barata
    preemptible  = true        # Mais barato, mas pode ser interrompido
    disk_size_gb = 20          # Reduzir o tamanho do disco
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

    # Especificar uma versão do Kubernetes compatível
  min_master_version = "1.28"
  node_version = "1.28"

  # Habilitar o painel de controle do Kubernetes
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    # kubernetes_dashboard {
    #   disabled = false
    # }
    network_policy_config {
      disabled = true
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  node_count = 2   # Reduzir o número de nós

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = 20   # Reduzir o tamanho do disco

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}

output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}

output "kubernetes_cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "kubernetes_cluster_ca_certificate" {
  value = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}