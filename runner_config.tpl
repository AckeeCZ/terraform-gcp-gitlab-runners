[[runners]]
  name = "\"${RUNNER_NAME}\""
  url = "\"${RUNNER_URL}\""
  token = "\"${RUNNER_TOKEN}\""
  executor = "\"docker+machine\""
  [runners.custom_build_dir]
  [runners.cache]
    Type = "\"gcs\""
    Shared = true
    [runners.cache.s3]
    [runners.cache.gcs]
      CredentialsFile = "\"/secrets/sa.json\""
      BucketName = "\"${RUNNER_BUCKET_NAME}\""
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "\"alpine:latest\""
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    shm_size = 0
  [runners.machine]
    IdleCount = 0
    IdleTime = ${RUNNER_IDLE_TIME}
    MaxBuilds = ${RUNNER_MAX_BUILDS}
    MachineDriver = "\"google\""
    MachineName = "\"instance-%s\""
    MachineOptions = ["\"google-project=${RUNNER_PROJECT}\"", "\"google-machine-type=${RUNNER_INSTANCE_TYPE}\"", "\"google-zone=${RUNNER_ZONE}\"", "\"google-service-account=${RUNNER_SA}\"", "\"google-scopes=https://www.googleapis.com/auth/cloud-platform\"", "\"google-disk-type=pd-ssd\"", "\"google-disk-size=${RUNNER_DISK_SIZE}\"", "\"google-tags=${RUNNER_TAGS}\"", "\"google-use-internal-ip\"","\"engine-registry-mirror=https://mirror.gcr.io\"","\"google-preemptible=true\"","\"google-machine-image=${WORKER_IMAGE}\""]
      [[runners.machine.autoscaling]]
        Periods = ["\"${RUNNER_WORKING_HOURS}\""]
        IdleCount = ${RUNNER_IDLE_COUNT_W}
        IdleTime = ${RUNNER_IDLE_TIME_W}
        Timezone = "\"Local\""
