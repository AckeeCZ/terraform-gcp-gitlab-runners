variable "project" {
}

variable "gitlab_url" {
}

variable "runner_token" {
}

# Install the GitLab CI Runner infrastructure
module "runner" {
  source                   = "../"
  project                  = var.project
  gitlab_url               = var.gitlab_url
  runner_token             = var.runner_token
  runner_instance_type     = "n2d-custom-4-8192"
  controller_instance_type = "n2d-highcpu-4"
  controller_gitlab_tags   = "cloud, web"
  controller_disk_type     = "pd-ssd"
}

# Grant the storage.admin role to the runner instances
resource "google_project_iam_member" "storage_admin" {
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.runner.runners_service_account.email}"
}
