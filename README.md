# Ackee Node.js Optimized Gitlab CI Runners 🦄

Terraform module for GitLab CI runners deployed at GCP with focus on Node.js builds.

## Why 🦄?
* Autoscaling by working hours
* Preemptible instances
* Distributed cache using GCS (Google Cloud Storage)
* Registry as a pull through cache for:
  * docker (Docker registry)
  * npm (Verdaccio)
* NAT or Public IP setup
* Highly customizable in general

## First setup
After specifying `gitlab_url`, `runner_token`, `project` and optionally some other variables, run terraform.
Initialization of the controller will take a while and then the infrastructure is ready (signalized with a newly registered runner in GitLab Runners Admin Area).
It is then recommended to adjust the HW requirements (instance types), to balance between quick builds and willingness to pay for them. Our setup can be viewed in the example folder.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud-nat"></a> [cloud-nat](#module\_cloud-nat) | terraform-google-modules/cloud-nat/google | 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.outgoing_traffic_europe_west1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_instance.gitlab_runner](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_project_iam_member.controller_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.runner_controller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.runner_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.controller_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_key.runner_sa_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.runner_cache](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_binding.runner_cache](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [random_string.random_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [template_file.runner_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_controller_disk_size"></a> [controller\_disk\_size](#input\_controller\_disk\_size) | The size of the persistent disk in GB for the controller | `string` | `"100"` | no |
| <a name="input_controller_disk_type"></a> [controller\_disk\_type](#input\_controller\_disk\_type) | GCP disk type for controller | `string` | `"pd-balanced"` | no |
| <a name="input_controller_gitlab_name"></a> [controller\_gitlab\_name](#input\_controller\_gitlab\_name) | Name of registered runner in GitLab | `string` | `"GCP runner"` | no |
| <a name="input_controller_gitlab_tags"></a> [controller\_gitlab\_tags](#input\_controller\_gitlab\_tags) | List of runner's tags delimited with , | `string` | `"cloud"` | no |
| <a name="input_controller_gitlab_untagged"></a> [controller\_gitlab\_untagged](#input\_controller\_gitlab\_untagged) | Register the runner to also execute GitLab jobs that are untagged. | `string` | `"true"` | no |
| <a name="input_controller_image"></a> [controller\_image](#input\_controller\_image) | Image for controller | `string` | `"ubuntu-os-cloud/ubuntu-2004-lts"` | no |
| <a name="input_controller_instance_type"></a> [controller\_instance\_type](#input\_controller\_instance\_type) | Instance type for controller, speed & power is not needed here | `string` | `"e2-small"` | no |
| <a name="input_controller_permissions"></a> [controller\_permissions](#input\_controller\_permissions) | Roles needed for controller | `list(string)` | <pre>[<br>  "roles/compute.instanceAdmin.v1",<br>  "roles/compute.networkAdmin",<br>  "roles/compute.securityAdmin",<br>  "roles/logging.logWriter"<br>]</pre> | no |
| <a name="input_docker_machine_version"></a> [docker\_machine\_version](#input\_docker\_machine\_version) | Version of docker machine for runners | `string` | `"v0.16.2"` | no |
| <a name="input_enable_cloud_nat"></a> [enable\_cloud\_nat](#input\_enable\_cloud\_nat) | Use Cloud NAT instance instead of public IP addreses | `bool` | `false` | no |
| <a name="input_gitlab_url"></a> [gitlab\_url](#input\_gitlab\_url) | GitLab URL where cloud runners are intended to be used | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | GCP network for use | `string` | `"default"` | no |
| <a name="input_project"></a> [project](#input\_project) | GCP project for cloud runners | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | `"europe-west1"` | no |
| <a name="input_runner_cache_location"></a> [runner\_cache\_location](#input\_runner\_cache\_location) | GCS bucket location for runner cache | `string` | `"EUROPE-WEST1"` | no |
| <a name="input_runner_concurrency"></a> [runner\_concurrency](#input\_runner\_concurrency) | The maximum number of summoned instances. | `number` | `12` | no |
| <a name="input_runner_disk_size"></a> [runner\_disk\_size](#input\_runner\_disk\_size) | The size of the persistent disk in GB for summoned instances (higher number than needed for better IOPS) | `string` | `"200"` | no |
| <a name="input_runner_docker_image"></a> [runner\_docker\_image](#input\_runner\_docker\_image) | Docker image to be used, for runners | `string` | `"docker-stable"` | no |
| <a name="input_runner_idle_count_working_hours"></a> [runner\_idle\_count\_working\_hours](#input\_runner\_idle\_count\_working\_hours) | Always up instances during working hours | `number` | `4` | no |
| <a name="input_runner_idle_time"></a> [runner\_idle\_time](#input\_runner\_idle\_time) | The maximum idle time for summoned instances before they went down | `number` | `60` | no |
| <a name="input_runner_idle_time_working_hours"></a> [runner\_idle\_time\_working\_hours](#input\_runner\_idle\_time\_working\_hours) | The maximum idle time for summoned instances before they went down during working hours | `number` | `600` | no |
| <a name="input_runner_instance_tags"></a> [runner\_instance\_tags](#input\_runner\_instance\_tags) | The GCP instance networking tags to apply | `string` | `"gitlab-runner"` | no |
| <a name="input_runner_instance_type"></a> [runner\_instance\_type](#input\_runner\_instance\_type) | Runner instance type. Adjust it for build needs | `string` | `"n2d-standard-2"` | no |
| <a name="input_runner_max_builds"></a> [runner\_max\_builds](#input\_runner\_max\_builds) | Each machine can handle up to 100 jobs in a row | `number` | `100` | no |
| <a name="input_runner_mount_volumes"></a> [runner\_mount\_volumes](#input\_runner\_mount\_volumes) | Docker volume mounts | `list(string)` | <pre>[<br>  "/cache",<br>  "/builds:/builds",<br>  "/var/run/docker.sock:/var/run/docker.sock"<br>]</pre> | no |
| <a name="input_runner_token"></a> [runner\_token](#input\_runner\_token) | Registration token for runner obtained in GitLab | `string` | n/a | yes |
| <a name="input_working_hours"></a> [working\_hours](#input\_working\_hours) | Working hours for autoscaling runners | `string` | `"\"* * 8-18 * * mon-fri *\""` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone for GCE instances | `string` | `"europe-west1-c"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_runners_service_account"></a> [runners\_service\_account](#output\_runners\_service\_account) | n/a |
