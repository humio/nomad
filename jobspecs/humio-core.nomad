job "humio-core" {
  type        = "service"
  datacenters = ["DCE"]

  # only run humio on certain nodes
  constraint {
    attribute      = "${node.class}"
    value          = "humio-core"
  }

  # humio-core
  group "core" {
    count = 5

    # spread the nodes over distinct hosts
    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    # restart policy for failed humio-core tasks
    restart {
      attempts = 3
      delay    = "30s"
      interval = "5m"
      mode     = "fail"
    }

    # how to handle upgrades of humio-core instances
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
      "KAFKA_BROKER_01"   = "10.223.57.56:9092"
      "KAFKA_BROKER_02"   = "10.223.57.126:9092"
      "KAFKA_BROKER_03"   = "10.223.57.107:9092"
      "ZK_NODE_01"        = "10.223.57.56:2181"
      "ZK_NODE_02"        = "10.223.57.126:2181"
      "ZK_NODE_03"        = "10.223.57.107:2181"
    }

    task "node" {
      driver = "docker"
      kill_timeout = "120s"   # allow humio 2 min to gracefully shut down
      kill_signal = "SIGTERM" # use SIGTERM to shut down the nodes

      # consul service check for humio-core instances
      service {
        check {
          port     = "humio"
          type     = "http"
          path     = "/api/v1/configversion"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # setup environment variables for humio-cores
      env {
        "CORES"             = "26"
        "HUMIO_JVM_ARGS"    = "-XX:+UseParallelOldGC -Xlog:gc+jni=debug -Xms2G -Xmx16G -Xss2M -XX:MaxDirectMemorySize=32G -Xlog:gc*:file=/data/logs/gc_humio.log:time,tags:filecount=5,filesize=102400 -Xprof"
        "EXTERNAL_URL"      = "http://${attr.unique.network.ip-address}:8080"
        "KAFKA_SERVERS"     = "${NOMAD_META_KAFKA_BROKER_01},${NOMAD_META_KAFKA_BROKER_02},${NOMAD_META_KAFKA_BROKER_02}"
        "ZOOKEEPER_URL"     = "${NOMAD_META_ZK_NODE_01},${NOMAD_META_ZK_NODE_02},${NOMAD_META_ZK_NODE_03}"
        "HUMIO_PORT"        = "8080"
        "HUMIO_SOCKET_BIND" = "${attr.unique.network.ip-address}"
        "HUMIO_HTTP_BIND"   = "${attr.unique.network.ip-address}"
        "AUTHENTICATION_METHOD"  = "ldap"
        "LDAP_AUTH_PROVIDER_URL" = "ldap://ldap.rsyd.net:389"
       }

      # container config
      config {
        image        = "humio/humio-core:1.0.68"
        network_mode = "host"

        volumes = [
          "/data/logs:/data/logs",
          "/data/humio-data:/data/humio-data",
          "/backup:/backup"
        ]

        ulimit {
          nofile = "65536" # ensure humio can create enough open file handles
        }
      }

      # resource config
      resources {
        cpu    = 1024
        memory = 2048

        network {
          mbits = 1
          port "humio" {
            static = "8080"
          }
        }
      } # resources end here

    } # task node ends here
  } # group core ends here

} # job humio-core ends here
