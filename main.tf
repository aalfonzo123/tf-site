variable "network" {
  type        = string
  description = "subnetwork connected to site VMs"
  default     = "linux-vpc"
}


variable "subnetwork" {
  type        = string
  description = "subnetwork connected to site VMs"
  default     = "another-us-east5"
}

variable "region" {
  type        = string
  description = "region for site VMs"
  default     = "us-east5"
}

variable "zone" {
  type        = string
  description = "zone for site VMs"
  default     = "us-east5-c"
}

variable "project" {
  type        = string
  description = "project site VMs"
  default     = "alfproject-358913"
}

resource "google_service_account" "site-sa" {
  account_id   = "site-sa"
  display_name = "Service Account for site VMs"
}

resource "google_compute_instance_template" "site-vm-template" {
  name = "site-vm-template"

  instance_description    = "site vm"
  machine_type            = "e2-medium"
  region                  = var.region
  metadata_startup_script = "sudo apt update && sudo apt -y install apache2;"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  service_account {
    email  = google_service_account.site-sa.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_template" "site-vm-template-v2" {
  name = "site-vm-template-v2"

  instance_description    = "site vm"
  machine_type            = "e2-medium"
  region                  = var.region
  metadata_startup_script = "#! /bin/bash\n     sudo apt-get update\n     sudo apt-get install apache2 -y\n     sudo a2ensite default-ssl\n     sudo a2enmod ssl\n     vm_hostname=\"$(curl -H \"Metadata-Flavor:Google\" \\\n   http://169.254.169.254/computeMetadata/v1/instance/name)\"\n   sudo echo \"Page served from: $vm_hostname\" | \\\n   tee /var/www/html/index.html\n   sudo systemctl restart apache2"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  service_account {
    email  = google_service_account.site-sa.email
    scopes = ["cloud-platform"]
  }
}

# ------

resource "google_compute_health_check" "site-health-check" {
  name                = "site-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  # http_health_check {
  #   request_path = "/healthz"
  #   port         = "8080"
  # }

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_instance_group_manager" "site-mig" {
  name = "site-mig"

  base_instance_name = "site"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.site-vm-template-v2.self_link_unique
  }

  # all_instances_config {
  #   metadata = {
  #     metadata_key = "metadata_value"
  #   }
  #   labels = {
  #     label_key = "label_value"
  #   }
  # }

  # target_pools = [google_compute_target_pool.site-target-pool.id]
  target_size = 2

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.site-health-check.id
    initial_delay_sec = 300
  }

  update_policy {
    type                           = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = 0
    max_unavailable_fixed          = 1
    replacement_method             = "RECREATE"
  }
}

module "site-lb" {
  source  = "GoogleCloudPlatform/lb-http/google"
  name    = "site-lb"
  project = var.project
  #target_tags       = ["allow-shared-vpc-mig"]
  #firewall_projects = [var.host_project]
  firewall_networks     = [var.network]
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backends = {
    default = {
      protocol    = "HTTP"
      port        = 80
      port_name   = "http"
      timeout_sec = 10
      enable_cdn  = false

      health_check = {
        request_path = "/"
        port         = 80
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = google_compute_instance_group_manager.site-mig.instance_group
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }
}
