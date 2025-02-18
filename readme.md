# Java Zero Code Local Otel Reference Template

This guide helps you set up and run a local OpenTelemetry reference app with minimal code changes. Follow these steps to get started.

## Prerequisites

Before you begin, make sure you have the following installed and set up on your machine:

- Docker/Podman: The OpenTelemetry Collector runs in a OCI container, so you'll need Docker installed on your system. [Install Docker](https://docs.docker.com/engine/install/) if you don't have it yet.

- Java (JDK 11 or later): You'll need Java installed to build and run the application. The app is built with Gradle, so ensure that Java is properly configured. [Install Java](https://www.openlogic.com/openjdk-downloads) (JDK 11 or later).

- Make: Make should come on all macos/linux machines [make](https://www.gnu.org/software/make/)

## Get started with make

The simpliest way to get started once the above dependencies have been installed.


### Alloy

```sh
make demo-alloy
```

![alloy_demo](docs/alloy.png)

### OTel Contrib Collector

```sh
make demo-otel
```

![demo_otel](docs/otel.png)


#### Make some requests

```sh
make request
```

## Steps to Run

### Start the OpenTelemetry Collector
The OpenTelemetry Collector is responsible for collecting and processing telemetry data (like traces and metrics). To start the collector, run this command:

```sh
docker network create shared
docker run -d \
  --net shared \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 55679:55679 \
  -v ./:/app \
  docker.io/otel/opentelemetry-collector-contrib:0.119.0 \
  --config /app/example-configuration.yaml
```

### Alternatively: Start alloy

```sh
docker run -it \
  --net host \
  -p 9200:9200 \
  -p 9600:9600 \
  -e "discovery.type=single-node" \
  -e "OPENSEARCH_INITIAL_ADMIN_PASSWORD=5m2-meG04e70m-wdf99s-dhnm" \
  --name opensearch \
  docker.io/opensearchproject/opensearch:latest
```

### Build and Run the Java Application

Next, build the Java application and run it with OpenTelemetry support:

#### Build the app:

```sh
./gradlew bootJar
```

#### Run the app with OpenTelemetry:

```sh
JAVA_TOOL_OPTIONS=-javaagent:opentelemetry-javaagent.jar
java -jar build/libs/java-zero-code-otel-reference-app-0.0.1-SNAPSHOT.jar
```

This will start the app and automatically connect to the OpenTelemetry Collector.

### Call the API
To test the app, call the API by running this command:

```sh
curl http://localhost:8080/rolldice
```

This will trigger the app to roll a dice and generate telemetry data.

### Check Grafana

#### Start Grafana

```sh
	docker network create shared || true
	docker run -d --rm \
		--net shared \
		--name=grafana -p 3000:3000 \
		docker.io/grafana/grafana:main
```

#### Browse Grafana

[http://localhost:3000/](http://localhost:3000/)

Defaults to:
User: admin
Password: admin


### Check the Metrics
You can view the app's output logs by running:

```sh
tail -f metrics.json
```

This will display the log output in real-time as the app runs.

By following these steps, you'll have the OpenTelemetry Collector running, your Java app instrumented with OpenTelemetry, and be able to observe telemetry data in the logs.

### Alloy

Run with alloy

```sh
alloy run --stability.level experimental config.alloy
```
