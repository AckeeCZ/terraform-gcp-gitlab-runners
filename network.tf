resource "google_compute_project_default_network_tier" "default" {
  network_tier = "STANDARD"
}

resource "google_compute_address" "outgoing_traffic_europe_west1" {
  name    = "nat-external-address-europe-west1"
  region  = var.region
  project = var.project
}

module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "2.0.0"
  project_id    = var.project
  region        = var.region
  create_router = true
  network       = "default"
  router        = "nat-router"
  nat_ips       = [google_compute_address.outgoing_traffic_europe_west1.self_link]
}
