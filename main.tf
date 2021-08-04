resource "google_storage_bucket" "runner_cache" {
  name          = "runner-cache-${var.project}"
  storage_class = "STANDARD"
  location      = var.runner_cache_location
  force_destroy = true
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = "7"
    }
  }
  versioning {
    enabled = false
  }
}

resource "google_storage_bucket_iam_binding" "runner_cache" {
  bucket = google_storage_bucket.runner_cache.name
  role   = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.runner_controller.email}"
  ]
  depends_on = [google_storage_bucket.runner_cache]
}

resource "google_service_account_key" "runner_sa_key" {
  service_account_id = google_service_account.runner_controller.name
}

locals {
  runners_additional_volumes = <<-EOT
  %{~for volume in var.runner_mount_volumes~},"${volume}"%{endfor~}
  EOT
}

data "template_file" "runner_config" {
  template = file("${path.module}/runner_config.tpl")
  vars = {
    CONCURRENT    = var.runner_concurrency
    NAME          = var.controller_gitlab_name
    URL           = var.gitlab_url
    TOKEN         = var.runner_token
    IDLE_TIME     = var.runner_idle_time
    PROJECT       = var.project
    INSTANCE_TYPE = var.runner_instance_type
    ZONE          = var.zone
    SA            = google_service_account.runner_instance.email
    DISK_SIZE     = var.runner_disk_size
    TAGS          = var.runner_instance_tags
    BUCKET_NAME   = google_storage_bucket.runner_cache.name
    IDLE_COUNT_W  = var.runner_idle_count_working_hours
    IDLE_TIME_W   = var.runner_idle_time_working_hours
    WORKING_HOURS = var.working_hours
    VOLUMES       = local.runners_additional_volumes
  }
}

resource "google_compute_instance" "gitlab_runner" {
  project                   = var.project
  zone                      = var.zone
  name                      = "gitlab-runner-controller"
  machine_type              = var.controller_instance_type
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = var.controller_disk_size
      type  = "pd-standard"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
  metadata_startup_script = <<EOF
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash
curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-Linux-x86_64 -o /tmp/docker-machine
sudo install /tmp/docker-machine /usr/local/bin/docker-machine
sudo yum install -y gitlab-runner
echo "${data.template_file.runner_config.rendered}" > /tmp/config.toml
mkdir -p /secrets
echo '${base64decode(google_service_account_key.runner_sa_key.private_key)}' > /secrets/sa.json
sudo gitlab-runner register -n \
    --name "${var.controller_gitlab_name} 💪" \
    --url ${var.gitlab_url} \
    --registration-token ${var.runner_token} \
    --executor "docker+machine" \
    --docker-image "alpine:latest" \
    --tag-list "${var.controller_gitlab_tags}" \
    --run-untagged="${var.controller_gitlab_untagged}" \
    --template-config "/tmp/config.toml"
EOF
  service_account {
    email  = google_service_account.runner_controller.email
    scopes = ["cloud-platform"]
  }
}
