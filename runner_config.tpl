concurrent = ${CONCURRENT}
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "\"${NAME}\""
  url = "\"${URL}\""
  token = "\"${TOKEN}\""
  executor = "\"docker+machine\""
  [runners.custom_build_dir]
  [runners.cache]
    Type = "\"gcs\""
    Shared = true
    [runners.cache.s3]
    [runners.cache.gcs]
      CredentialsFile = "\"/secrets/sa.json\""
      BucketName = "\"${BUCKET_NAME}\""
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "\"alpine:latest\""
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"${VOLUMES}]
    shm_size = 0
  [runners.machine]
    IdleCount = 0
    IdleTime = ${IDLE_TIME}
    MachineDriver = "\"google\""
    MachineName = "\"instance-%s\""
    MachineOptions = ["\"google-project=${PROJECT}\"", "\"google-machine-type=${INSTANCE_TYPE}\"", "\"google-zone=${ZONE}\"", "\"google-service-account=${SA}\"", "\"google-scopes=https://www.googleapis.com/auth/cloud-platform\"", "\"google-disk-type=pd-ssd\"", "\"google-disk-size=${DISK_SIZE}\"", "\"google-tags=${TAGS}\"", "\"google-use-internal-ip\""]
      [[runners.machine.autoscaling]]
        Periods = ["\"${WORKING_HOURS}\""]
        IdleCount = ${IDLE_COUNT_W}
        IdleTime = ${IDLE_TIME_W}
        Timezone = "CET"
