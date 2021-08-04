# Basic options
variable "project" {
  type        = string
  description = "GCP project for cloud runners"
}

variable "region" {
  type        = string
  default     = "europe-west3"
  description = "GCP region"
}

variable "zone" {
  type        = string
  default     = "europe-west3-c"
  description = "Zone for GCE instances"
}

variable "runner_token" {
  type        = string
  description = "Registration token for runner obtained in GitLab"
}

variable "gitlab_url" {
  type        = string
  description = "GitLab URL where cloud runners are intended to be used"
}

# Controller options
variable "controller_disk_size" {
  type        = string
  default     = "20"
  description = "The size of the persistent disk in GB for the controller"
}
variable "controller_instance_type" {
  type        = string
  default     = "f1-micro"
  description = "Instance type for controller, speed & power is not needed here."
}
variable "controller_gitlab_name" {
  type        = string
  default     = "GCP runner"
  description = "Name of registered runner in GitLab"
}
variable "controller_gitlab_tags" {
  type        = string
  default     = "cloud"
  description = "List of runner's tags delimited with ,"
}
variable "controller_gitlab_untagged" {
  type        = string
  default     = "true"
  description = "Register the runner to also execute GitLab jobs that are untagged."
}

# Instance options
variable "runner_disk_size" {
  type        = string
  default     = "100"
  description = "The size of the persistent disk in GB for summoned instances"
}
variable "runner_instance_type" {
  type        = string
  default     = "e2-standard-2"
  description = "Runner instance type. Adjust it for build needs (but n2-standard-2 is not working)"
}
variable "runner_instance_tags" {
  type        = string
  default     = "gitlab-runner"
  description = "The GCP instance networking tags to apply"
}
variable "runner_concurrency" {
  type        = number
  default     = 1
  description = "The maximum number of summoned instances."
}
variable "runner_idle_time" {
  type        = number
  default     = 60
  description = "The maximum idle time for summoned instances before they went down"
}
variable "runner_cache_location" {
  type        = string
  default     = "EUROPE-WEST3"
  description = "GCS bucket location for runner cache"
}
variable "runner_mount_volumes" {
  type        = list(string)
  default     = ["/cache"]
  description = "Docker volume mounts"
}
variable "runner_idle_time_working_hours" {
  type        = number
  default     = 600
  description = "The maximum idle time for summoned instances before they went down during working hours"
}
variable "runner_idle_count_working_hours" {
  type        = number
  default     = 4
  description = "Always up instances during working hours"
}
variable "working_hours" {
  type        = string
  default     = "\"* * 8-17 * * mon-fri *\""
  description = "Working hours for autoscaling runners"
}
