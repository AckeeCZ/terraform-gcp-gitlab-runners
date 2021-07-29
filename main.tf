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
sed -i "s/concurrent = .*/concurrent = ${var.runner_concurrency}/" /etc/gitlab-runner/config.toml
sudo gitlab-runner register -n \
    --name "${var.controller_gitlab_name} 💪" \
    --url ${var.gitlab_url} \
    --registration-token ${var.runner_token} \
    --executor "docker+machine" \
    --docker-image "alpine:latest" \
    --tag-list "${var.controller_gitlab_tags}" \
    --run-untagged="${var.controller_gitlab_untagged}" \
    --docker-privileged=true \
    --machine-idle-time ${var.runner_idle_time} \
    --machine-max-builds ${var.runner_max_builds} \
    --machine-machine-driver google \
    --machine-machine-name "instance-%s" \
    --machine-machine-options "google-project=${var.project}" \
    --machine-machine-options "google-machine-type=${var.runner_instance_type}" \
    --machine-machine-options "google-zone=${var.zone}" \
    --machine-machine-options "google-service-account=${google_service_account.runner_instance.email}" \
    --machine-machine-options "google-scopes=https://www.googleapis.com/auth/cloud-platform" \
    --machine-machine-options "google-disk-type=pd-ssd" \
    --machine-machine-options "google-disk-size=${var.runner_disk_size}" \
    --machine-machine-options "google-tags=${var.runner_instance_tags}" \
    --machine-machine-options "google-use-internal-ip" \
    --machine-autoscaling-periods "["${var.working_hours_scaling_period}"]" \
    --machine-autoscaling-idle-count "${var.working_hours_scaling_idle_count}" \
    --machine-autoscaling-idle-time "${var.working_hours_scaling_idle_time}" \
    --machine-autoscaling-timezone "${var.working_hours_scaling_timezone}" \
EOF
  service_account {
    email  = google_service_account.runner_controller.email
    scopes = ["cloud-platform"]
  }
}
