data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gcp-network" {
  source = "terraform-google-modules/network/google"

  project_id   = var.project_id
  network_name = var.network

  subnets = [
    {
      subnet_name   = var.subnetwork
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (var.subnetwork) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google"
  project_id             = var.project_id
  name                   = var.cluster_name
  regional               = true
  region                 = var.region
  network                = module.gcp-network.network_name
  subnetwork             = module.gcp-network.subnets_names[0]
  ip_range_pods          = var.ip_range_pods_name
  ip_range_services      = var.ip_range_services_name
  create_service_account = true

  node_pools = [
    {
      name           = "node-pool-example"
      machine_type   = "n1-standard-2"
      node_locations = "${var.region}-b,${var.region}-c"
      node_count     = 2
      disk_type      = "pd-standard"
    }
  ]

  node_pools_labels = {
    all = {}

    node-pool-example = {
      demo-target = true
    }
  }
}

resource "kubernetes_deployment" "nginx-example" {
  metadata {
    name = "nginx-example"

    labels = {
      maintained_by = "terraform"
      app           = "nginx-example"
    }
  }

  spec {
    replicas = 4

    selector {
      match_labels = {
        app = "nginx-example"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-example"
        }
      }

      spec {
        node_selector = {
          demo-target = true
        }

        container {
          image = "nginx:1.21.6"
          name  = "nginx-example"
        }
      }
    }
  }
  depends_on = [module.gke]
}

resource "kubernetes_service_v1" "nginx-example" {
  metadata {
    name = "nginx-example"
  }

  spec {
    selector = {
      app = kubernetes_deployment.nginx-example.metadata[0].labels.app
    }

    port {
      port = 80
    }

    type = "ClusterIP"
  }

  depends_on = [module.gke]
}

resource "kubernetes_ingress_v1" "nginx-example" {
  wait_for_load_balancer = true
  metadata {
    name = "nginx-example"
  }
  spec {
    default_backend {
      service {
        name = kubernetes_service_v1.nginx-example.metadata.0.name
        port {
          number = 80
        }
      }
    }
  }
}
