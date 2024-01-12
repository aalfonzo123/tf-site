variable "project_id" {
  type = string
  default = "alfproject-358913"
}

variable "network_project_id" {
  type = string
  default = "alfproject-358913"
}

variable "image_storage_locations" {
  type = list(string)
  default = ["us-east5"]
}

variable "zone" {
  type = string
  default = "us-east5-c"
}

variable "network" {
  type = string
  default = "projects/alfproject-358913/global/networks/linux-vpc"
}

variable "subnetwork" {
  type = string
  default = "projects/alfproject-358913/regions/us-east5/subnetworks/another-us-east5"
}

source "googlecompute" "debian" {
  project_id              = var.project_id
  source_image            = "debian-11-bullseye-v20231212"
  image_name              = "site-{{timestamp}}"
  image_family            = "site-family"
  image_storage_locations = var.image_storage_locations
  image_labels = {
    "os" : "debian"
    "application" : "apache"
  }
  ssh_username       = "packer-sa"
  instance_name      = "packer-image-build"
  zone               = var.zone
  network            = var.network
  subnetwork         = var.subnetwork
  network_project_id = var.network_project_id
  machine_type = "e2-standard-2"
  use_internal_ip    = true
  omit_external_ip   = true
  use_iap            = true
  use_os_login       = true
  metadata = {
    block-project-ssh-keys = "true"
  }
  tags = ["packer"]
}

build {
  sources = [
    "source.googlecompute.debian"
  ]

  provisioner "file" {
    source      = "scripts"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "sudo bash /tmp/scripts/install_apache.sh",
    ]
  }

  # provisioner "ansible-local" {
  #   playbook_file = "ansible/playbook.yaml"
  #   role_paths = [
  #     "ansible/roles/CIS-Ubuntu-20.04-Ansible"
  #   ]
  # }

  # provisioner "shell" {
  #   inline = [
  #     "sudo apt remove ansible -y"
  #   ]
  # }

}