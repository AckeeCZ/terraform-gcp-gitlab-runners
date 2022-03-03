resource "google_compute_address" "outgoing_traffic_europe_west1" {
  name    = "nat-external-address-europe-west1"
  region  = var.region
  project = var.project
}

module "cloud-nat" {
  count         = var.enable_cloud_nat == true ? 1 : 0
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 2.0"
  project_id    = var.project
  region        = var.region
  create_router = true
  network       = var.network
  router        = "nat-router"
  nat_ips       = [google_compute_address.outgoing_traffic_europe_west1.self_link]
}
