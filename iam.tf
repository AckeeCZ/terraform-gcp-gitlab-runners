resource "random_string" "random_suffix" {
  length  = 6
  special = false
  upper   = false
}

# SA for microinstance which spawns instances
resource "google_service_account" "runner_controller" {
  project      = var.project
  account_id   = "runner-controller-${random_string.random_suffix.result}"
  display_name = "GitLab CI Runner Controller"
}

# SA for spawned runner instances
resource "google_service_account" "runner_instance" {
  project      = var.project
  account_id   = "runner-instance-${random_string.random_suffix.result}"
  display_name = "GitLab CI Runner Instance"
}

# Allow controller to use runner instance SA
resource "google_service_account_iam_member" "controller_instance" {
  service_account_id = google_service_account.runner_instance.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.runner_controller.email}"
}

# Allow controller to manage GCE resources
resource "google_project_iam_member" "controller_iam" {
  for_each = toset(var.controller_permissions)
  project  = var.project
  role     = each.key
  member   = "serviceAccount:${google_service_account.runner_controller.email}"
}
