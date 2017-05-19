## Docker ELK stack with syslog input

Run the latest version of the ELK (Elasticsearch, Logstash, Kibana) stack to process the syslog logs via Docker and Docker-compose.You can redirect your logs to this stack with *syslog* driver in your Docker instances and get the ability to analyze any data set by using the searching/aggregation capabilities of Elasticsearch and the visualization power of Kibana. 

Based on the official images:

* [elasticsearch](https://github.com/elastic/elasticsearch-docker)
* [logstash](https://github.com/elastic/logstash-docker)
* [kibana](https://github.com/elastic/kibana-docker)

## Logstash syslog input plugin

Installed in `Dockerfile` and configure in `./logstash/pipeline/logstash.conf`

## Requirements

1. Install [Docker](http://docker.io).
2. Install [Docker-compose](http://docs.docker.com/compose/install/).

## Usage

### install

1. `git clone https://github.com/yangjunsss/docker-elk-syslog`
2. `cd docker-elk-syslog && ./install.sh`
3. After install successfully then access Kibana UI by hitting [http://localhost:5601](http://localhost:5601) with a web browser.

By default, the stack exposes the following ports:
* 5140: Logstash syslog input.
* 9200: Elasticsearch HTTP
* 9300: Elasticsearch TCP transport
* 5601: Kibana

### stop

`docker-compose -f docker-compose.yml down -v`

## Start your application

Take nginx for example:

```bash
echo "192.168.0.4 syslog_host" >> /etc/hosts
docker-compose -f docker-compose.nginx.yml up
```

After started, you can verify the logs from *http://192.168.0.4:5601* by Kibana.

## Configuration

*NOTE*: Configuration is not dynamically reloaded, you will need to restart the stack after any change in the configuration of a component.

The Kibana default configuration is stored in `kibana/config/kibana.yml`.

The Logstash configuration is stored in `logstash/config/logstash.yml`.

The Logstash pipeline configuration is stored in `logstash/pipeline/logstash.conf`

The Elasticsearch configuration is stored in `elasticsearch/config/elasticsearch.yml`.

### How can I scale up the Elasticsearch cluster?

Follow the instructions from the Wiki: [Scaling up Elasticsearch](https://github.com/deviantony/docker-elk/wiki/Elasticsearch-cluster)

## Storage

The data stored in Elasticsearch will be persisted under `./elasticsearch/data`

