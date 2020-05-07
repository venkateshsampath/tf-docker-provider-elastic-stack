provider "docker" {}

resource "docker_network" "elastic_net" {
  name = "elastic_net"
}

resource "docker_container" "elasticsearch" {
  image = "docker.elastic.co/elasticsearch/elasticsearch:7.6.2"
  name = "elasticsearch"
  restart = "always"
  network_mode = "elastic_net"
  ports {
    internal = 9200
    external = 9200
  }
  ports {
    internal = 9300
    external = 9300
  }
  env = [
    "xpack.security.enabled=false",
    "discovery.type=single-node"
  ]
}

resource "docker_container" "kibana" {
  image = "docker.elastic.co/kibana/kibana:7.6.2"
  name = "kibana"
  restart = "always"
  network_mode = "elastic_net"
  ports {
    internal = 5601
    external = 5601
  }
  env = [
    "elasticsearch.hosts=http://elasticsearch:9200"
  ]
}

resource "docker_container" "logstash" {
  image = "docker.elastic.co/logstash/logstash:7.6.2"
  name = "logstash"
  restart = "always"
  network_mode = "elastic_net"
  ports {
    internal = 8080
    external = 8089
  }
  volumes {
    host_path = "${path.module}/config/custom-pipeline.conf"
    container_path = "/usr/share/logstash/pipeline/sample-pipeline.conf"
  }
}

resource "docker_container" "filebeat" {
  image = "docker.elastic.co/beats/filebeat:7.6.2"
  name = "filebeat"
  restart = "always"
  network_mode = "elastic_net"
  ports {
    internal = 5044
    external = 5044
  }
  volumes {
    host_path = "${path.module}/config/filebeat.yml"
    container_path = "/usr/share/filebeat/filebeat.yml"
  }
  volumes {
    host_path = "${path.module}/config/logstash.log"
    container_path = "/usr/share/filebeat/logstash.log"

  }
}