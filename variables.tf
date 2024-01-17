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

variable "host_project" {
  type        = string
  description = "shared vpc host project"
  default     = "alfproject-358913"
}

variable "source_image" {
  type        = string
  description = "source_image for site VMs"
  default =  "projects/alfproject-358913/global/images/site-1705065674" 
  # "projects/alfproject-358913/global/images/site-1704998583" #"debian-cloud/debian-11"
}

variable "source_image_v2" {
  type        = string
  description = "source_image for site VMs v2"
  default = "projects/alfproject-358913/global/images/site-1705064799" 
}