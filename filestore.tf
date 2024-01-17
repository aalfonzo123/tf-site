resource "google_filestore_instance" "filestore-instance" {
  name     = "filestore-instance"
  location = var.zone
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "share1"

    nfs_export_options {
      ip_ranges   = ["10.80.0.0/16"]
      access_mode = "READ_WRITE"
      squash_mode = "NO_ROOT_SQUASH"
    }
  }

  networks {
    network = var.network
    modes   = ["MODE_IPV4"]
  }
}

# umount -f /mnt
