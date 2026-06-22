data "google_compute_subnetwork" "dev_shared_subnet" {
  name    = "dev"
  region  = "us-east1"
  project = "non-prod-platform"
}

data "google_dns_managed_zone" "dns_zone" {
  name = "private-zone"
}
