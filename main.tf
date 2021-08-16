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

data "template_file" "runner_config" {
  template = file("${path.module}/runner_config.tpl")
  vars = {
    RUNNER_CONCURRENT    = var.runner_concurrency
    RUNNER_NAME          = var.controller_gitlab_name
    RUNNER_URL           = var.gitlab_url
    RUNNER_TOKEN         = var.runner_token
    RUNNER_IDLE_TIME     = var.runner_idle_time
    RUNNER_PROJECT       = var.project
    RUNNER_INSTANCE_TYPE = var.runner_instance_type
    RUNNER_ZONE          = var.zone
    RUNNER_SA            = google_service_account.runner_instance.email
    RUNNER_DISK_SIZE     = var.runner_disk_size
    RUNNER_TAGS          = var.runner_instance_tags
    RUNNER_BUCKET_NAME   = google_storage_bucket.runner_cache.name
    RUNNER_IDLE_COUNT_W  = var.runner_idle_count_working_hours
    RUNNER_IDLE_TIME_W   = var.runner_idle_time_working_hours
    RUNNER_WORKING_HOURS = var.working_hours
    RUNNER_MAX_BUILDS    = var.runner_max_builds
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
curl -L https://github.com/docker/machine/releases/download/${var.docker_machine_version}/docker-machine-Linux-x86_64 -o /tmp/docker-machine
sudo install /tmp/docker-machine /usr/local/bin/docker-machine
sudo yum install -y gitlab-runner
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io
touch /tmp/stage_one_done
sudo systemctl start docker
sudo docker run -d -p 6000:5000 \
  -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
  --restart always \
  --name registry registry:2
touch /tmp/stage_two_done
sed -i "s/concurrent = .*/concurrent = ${var.runner_concurrency}/" /etc/gitlab-runner/config.toml
echo "${data.template_file.runner_config.rendered}" > /tmp/config.toml
sed -i "s/engine-registry-mirror=https:\/\/mirror.gcr.io/engine-registry-mirror=${google_compute_instance.gitlab_runner.network_interface.0.network_ip}:6000/" /tmp/config.toml
mkdir -p /secrets
echo '${base64decode(google_service_account_key.runner_sa_key.private_key)}' > /secrets/sa.json
sudo gitlab-runner register -n \
    --name "${var.controller_gitlab_name} 💪" \
    --url ${var.gitlab_url} \
    --registration-token ${var.runner_token} \
    --executor "docker+machine" \
    --docker-image "docker:stable" \
    ${join("\n", formatlist("--docker-volumes \"%s\" \\", var.runner_mount_volumes))}
    --tag-list "${var.controller_gitlab_tags}" \
    --run-untagged="${var.controller_gitlab_untagged}" \
    --template-config "/tmp/config.toml"
EOF
  service_account {
    email  = google_service_account.runner_controller.email
    scopes = ["cloud-platform"]
  }
}
