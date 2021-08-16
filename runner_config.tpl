concurrent = ${RUNNER_CONCURRENT}
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  pre_build_script = "\"echo \\\"@runner-registry:registry=${RUNNER_NPM_REGISTRY}\nregistry=http://0.0.0.0:4975\\\" > .npmrc.temp && cat .npmrc .npmrc.temp | sort -u > .npmrc\""
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
    privileged = false
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
    MachineOptions = ["\"google-project=${RUNNER_PROJECT}\"", "\"google-machine-type=${RUNNER_INSTANCE_TYPE}\"", "\"google-zone=${RUNNER_ZONE}\"", "\"google-service-account=${RUNNER_SA}\"", "\"google-scopes=https://www.googleapis.com/auth/cloud-platform\"", "\"google-disk-type=pd-ssd\"", "\"google-disk-size=${RUNNER_DISK_SIZE}\"", "\"google-tags=${RUNNER_TAGS}\"", "\"google-use-internal-ip-only\"","\"engine-registry-mirror=https://mirror.gcr.io\"","\"google-preemptible=true\""]
      [[runners.machine.autoscaling]]
        Periods = ["\"${RUNNER_WORKING_HOURS}\""]
        IdleCount = ${RUNNER_IDLE_COUNT_W}
        IdleTime = ${RUNNER_IDLE_TIME_W}
        Timezone = "\"Local\""
