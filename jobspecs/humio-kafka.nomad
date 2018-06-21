job "humio-kafka" {
  type        = "service"
  datacenters = ["DCE"]
  # how to handle upgrades
  update {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "30s"
    healthy_deadline = "5m"
    auto_revert      = true
    canary           = 0
    stagger          = "30s"
  }
  meta {
    "ZK_NODE_01"        = "10.223.57.56:2181"
    "ZK_NODE_02"        = "10.223.57.126:2181"
    "ZK_NODE_03"        = "10.223.57.107:2181"
  }
  # kafka brokers
  group "broker01" {
    count = 1
    # restart policy for failed tasks
    restart {
      attempts = 3
      delay    = "30s"
      interval = "5m"
      mode     = "fail"
    }
    task "broker" {
      driver = "docker"
      kill_timeout = "300s"    # allow kafka 5 min to gracefully shut down
      kill_signal  = "SIGTERM" # use SIGTERM to shut down the brokers
      # humio-kafka nodes must always be spread across different machines
      constraint {
        attribute = "${attr.unique.hostname}"
        value     = "ts-esbappkaf01v"
      }
      env {
        "KAFKA_HEAP_OPTS" = "-Xmx3G -Xms3G"
      }
      template {
        data = <<EOH
broker.id=1
log.dirs=/data/kafka-data
zookeeper.connect={{ env "NOMAD_META_ZK_NODE_01"}},{{ env "NOMAD_META_ZK_NODE_02"}},{{env "NOMAD_META_ZK_NODE_03"}}
listeners=PLAINTEXT://{{ env "attr.unique.network.ip-address"}}:9092
replica.fetch.max.bytes=104857600
message.max.bytes=104857600
compression.type=producer
num.partitions=1
log.retention.hours=48
log.retention.check.interval.ms=300000
unclean.leader.election.enable=false
broker.id.generation.enable=false
auto.create.topics.enable=false
EOH
        destination = "local/kafka.properties"
      }
      # container config
      config {
        image      = "humio/kafka"
        network_mode = "host"
        volumes = [
          "local/kafka.properties:/etc/kafka/kafka.properties",
          "/data/kafka-data:/data/kafka-data",
          "/data/logs:/data/logs"
        ]
        ulimit {
          nofile = "65536" # ensure kafka can create enough open file handles
        }
      }
      # resource config
      resources {
        cpu    = 1024
        memory = 2048
      } # resources end here
    } # task broker-01 ends here
  }
  group "broker02" {
    count = 1
    # restart policy for failed tasks
    restart {
      attempts = 3
      delay    = "30s"
      interval = "5m"
      mode     = "fail"
    }
    task "broker" {
      driver = "docker"
      kill_timeout = "300s"   # allow kafka 5 min to gracefully shut down
      kill_signal = "SIGTERM" # use SIGTERM to shut down the brokers
      # humio-kafka nodes must always be spread across different machines
      constraint {
        attribute = "${attr.unique.hostname}"
        value     = "ts-esbappkaf02v"
      }
      env {
        "KAFKA_HEAP_OPTS" = "-Xmx3G -Xms3G"
      }
      template {
        data = <<EOH
broker.id=2
log.dirs=/data/kafka-data
zookeeper.connect={{ env "NOMAD_META_ZK_NODE_01"}},{{ env "NOMAD_META_ZK_NODE_02"}},{{env "NOMAD_META_ZK_NODE_03"}}
listeners=PLAINTEXT://{{ env "attr.unique.network.ip-address"}}:9092
replica.fetch.max.bytes=104857600
message.max.bytes=104857600
compression.type=producer
num.partitions=1
log.retention.hours=48
log.retention.check.interval.ms=300000
unclean.leader.election.enable=false
broker.id.generation.enable=false
auto.create.topics.enable=false
EOH
        destination = "local/kafka.properties"
      }
      # container config
      config {
        image      = "humio/kafka"
        network_mode = "host"
        volumes = [
          "local/kafka.properties:/etc/kafka/kafka.properties",
          "/data/kafka-data:/data/kafka-data",
          "/data/logs:/data/logs"
        ]
        ulimit {
          nofile = "65536" # ensure kafka can create enough open file handles
        }
      }
      # resource config
      resources {
        cpu    = 1024
        memory = 2048
      } # resources end here
    } # task broker-02 ends here
  }
  group "broker03" {
    count = 1
    # restart policy for failed tasks
    restart {
      attempts = 3
      delay    = "30s"
      interval = "5m"
      mode     = "fail"
    }
    task "broker" {
      driver = "docker"
      kill_timeout = "300s"   # allow kafka 5 min to gracefully shut down
      kill_signal = "SIGTERM" # use SIGTERM to shut down the brokers
      # humio-kafka nodes must always be spread across different machines
      constraint {
        attribute = "${attr.unique.hostname}"
        value     = "ts-esbappkaf03v"
      }
      env {
        "KAFKA_HEAP_OPTS" = "-Xmx3G -Xms3G"
      }
      template {
        data = <<EOH
broker.id=3
log.dirs=/data/kafka-data
zookeeper.connect={{ env "NOMAD_META_ZK_NODE_01"}},{{ env "NOMAD_META_ZK_NODE_02"}},{{env "NOMAD_META_ZK_NODE_03"}}
listeners=PLAINTEXT://{{ env "attr.unique.network.ip-address"}}:9092
replica.fetch.max.bytes=104857600
message.max.bytes=104857600
compression.type=producer
num.partitions=1
log.retention.hours=48
log.retention.check.interval.ms=300000
unclean.leader.election.enable=false
broker.id.generation.enable=false
auto.create.topics.enable=false
EOH
        destination = "local/kafka.properties"
      }
      # container config
      config {
        image        = "humio/kafka"
        network_mode = "host"
        volumes = [
          "local/kafka.properties:/etc/kafka/kafka.properties",
          "/data/kafka-data:/data/kafka-data",
          "/data/logs:/data/logs"
        ]
        ulimit {
          nofile = "65536" # ensure kafka can create enough open file handles
        }
      }
      # resource config
      resources {
        cpu    = 1024
        memory = 2048
      } # resources end here
    } # task broker-03 ends here
  } # group kafka ends here
} # job humio-kafka ends here
