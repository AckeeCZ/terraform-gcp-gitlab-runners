# SA for microinstance which spawns instances
resource "google_service_account" "runner_controller" {
  project      = var.project
  account_id   = "runner-controller"
  display_name = "GitLab CI Runner Controller"
}

# SA for spawned runner instances
resource "google_service_account" "runner_instance" {
  project      = var.project
  account_id   = "runner-instance"
  display_name = "GitLab CI Runner Instance"
}

# Allow controller to use runner instance SA
resource "google_service_account_iam_member" "controller_instance" {
  service_account_id = google_service_account.runner_instance.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.runner_controller.email}"
}

# Allow controler to manage GCE resources
resource "google_project_iam_member" "instance_admin" {
  project = var.project
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.runner_controller.email}"
}
resource "google_project_iam_member" "network_admin" {
  project = var.project
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.runner_controller.email}"
}
resource "google_project_iam_member" "security_admin" {
  project = var.project
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.runner_controller.email}"
}
resource "google_project_iam_member" "logwriter" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.runner_controller.email}"
}
