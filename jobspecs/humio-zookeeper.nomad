# Note. This jobspect does not create Zookeeper myid files. Make sure those exist on your hosts!

job "humio-zookeeper" {
  type        = "service"
  datacenters = ["DCE"]
  meta {
    "ZK_NODE_01"        = "10.223.57.56"
    "ZK_NODE_02"        = "10.223.57.126"
    "ZK_NODE_03"        = "10.223.57.107"
  }
  # zookeeper cluster
  group "ensemble01" {
    count = 1
# restart policy for failed zookeeper node tasks
    restart {
      attempts = 10
      delay    = "30s"
      interval = "10m"
      mode     = "fail"
    }
    # how to handle upgrades of zookeeper nodes
    update {
      max_parallel     = 1
      health_check     = "checks"
      min_healthy_time = "30s"
      healthy_deadline = "5m"
      auto_revert      = true
      canary           = 0
      stagger          = "30s"
    }
    task "task" {
      driver = "docker"
      kill_timeout = "300s"   # allow zookeeper 5 min to gracefully shut down
      kill_signal = "SIGTERM" # use SIGTERM to shut down the brokers
      # humio-zookeeper nodes must always be pinned to the same node
      constraint {
        attribute = "${attr.unique.hostname}"
        value     = "ts-esbappkaf01v"
      }
      # render zookeeper config for this task
      template {
        data = <<EOH
dataDir=/data/zookeeper-data
clientPort=2181
clientPortAddress={{ env "attr.unique.network.ip-address"}}
tickTime=2000
initLimit=5
syncLimit=2
server.1={{env "NOMAD_META_ZK_NODE_01"}}:2888:3888
server.2={{env "NOMAD_META_ZK_NODE_02"}}:2888:3888
server.3={{env "NOMAD_META_ZK_NODE_03"}}:2888:3888
EOH
        destination = "local/zookeeper.properties"
      }
      # container config
      config {
        image      = "humio/zookeeper"
        network_mode = "host"
        volumes = [
          "local/zookeeper.properties:/etc/kafka/zookeeper.properties",
          "/data/zookeeper-data:/data/zookeeper-data",
          "/data/logs:/data/logs"
        ]
        ulimit {
          nofile = "65536" # ensure zookeeper can create enough open file handles
        }
      }
      # resource config
      resources {
        cpu    = 1024
        memory = 2048
      }
    } # task node01 ends here
}
group "ensemble02" {
    task "task" {
      driver = "docker"
      kill_timeout = "300s"   # allow zookeeper 5 min to gracefully shut down
      kill_signal = "SIGTERM" # use SIGTERM to shut down the brokers
      # humio-zookeeper nodes must always be pinned to the same node
      constraint {
        attribute = "${attr.unique.hostname}"
        value     = "ts-esbappkaf02v"
      }
      # render zookeeper config for this task
      template {
        data = <<EOH
dataDir=/data/zookeeper-data
clientPort=2181
clientPortAddress={{ env "attr.unique.network.ip-address"}}
tickTime=2000
initLimit=5
syncLimit=2
server.1={{env "NOMAD_META_ZK_NODE_01"}}:2888:3888
server.2={{env "NOMAD_META_ZK_NODE_02"}}:2888:3888
server.3={{env "NOMAD_META_ZK_NODE_03"}}:2888:3888
EOH
        destination = "local/zookeeper.properties"
      }
      # container config
      config {
        image      = "humio/zookeeper"
        network_mode = "host"
        volumes = [
          "local/zookeeper.properties:/etc/kafka/zookeeper.properties",
          "/data/zookeeper-data:/data/zookeeper-data",
          "/data/logs:/data/logs"
        ]
        ulimit {
          nofile = "65536" # ensure zookeeper can create enough open file handles
        }
      }
      # resource config
      resources {
        cpu    = 1024
        memory = 2048
      }
    } # task node02 ends here
  }
group "ensemble03" {
    task "task" {
      driver = "docker"
      kill_timeout = "300s"   # allow zookeeper 5 min to gracefully shut down
      kill_signal = "SIGTERM" # use SIGTERM to shut down the brokers
      # humio-zookeeper nodes must always be pinned to the same node
      constraint {
        attribute = "${attr.unique.hostname}"
        value     = "ts-esbappkaf03v"
      }
      # render zookeeper config for this task
      template {
        data = <<EOH
dataDir=/data/zookeeper-data
clientPort=2181
clientPortAddress={{env "attr.unique.network.ip-address"}}
tickTime=2000
initLimit=5
syncLimit=2
server.1={{env "NOMAD_META_ZK_NODE_01"}}:2888:3888
server.2={{env "NOMAD_META_ZK_NODE_02"}}:2888:3888
server.3={{env "NOMAD_META_ZK_NODE_03"}}:2888:3888
EOH
        destination = "local/zookeeper.properties"
      }
      # container config
      config {
        image      = "humio/zookeeper"
        privileged = false #TODO: not needed ??
        network_mode = "host"
        volumes = [
           "local/zookeeper.properties:/etc/kafka/zookeeper.properties",
          "/data/zookeeper-data:/data/zookeeper-data",
          "/data/logs:/data/logs"
        ]
        ulimit {
          nofile = "65536" # ensure zookeeper can create enough open file handles
        }
      }
      # resource config
      resources {
        cpu    = 1024
        memory = 2048
      }
    } # task node03 ends here
  } # group ensemble ends here
} # job humio-zookeeper ends here
