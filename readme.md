# Java Zero Code Local Otel Reference Template

This guide helps you set up and run a local OpenTelemetry reference app with minimal code changes. Follow these steps to get started.

## Prerequisites

Before you begin, make sure you have the following installed and set up on your machine:

- Docker/Podman: The OpenTelemetry Collector runs in a OCI container, so you'll need Docker installed on your system. [Install Docker](https://docs.docker.com/engine/install/) if you don't have it yet.

- Java (JDK 11 or later): You'll need Java installed to build and run the application. The app is built with Gradle, so ensure that Java is properly configured. [Install Java](https://www.openlogic.com/openjdk-downloads) (JDK 11 or later).

## Steps to Run

### Start the OpenTelemetry Collector
The OpenTelemetry Collector is responsible for collecting and processing telemetry data (like traces and metrics). To start the collector, run this command:

```sh
touch logs.json
docker network create shared
docker run -it \
  --net shared \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 55679:55679 \
  -v ./:/app \
  docker.io/otel/opentelemetry-collector-contrib:0.119.0 \
  --config /app/example-configuration.yaml
```

```sh
docker run -it \
  --net shared \
  -p 9200:9200 \
  -p 9600:9600 \
  -e "discovery.type=single-node" \
  -e "OPENSEARCH_INITIAL_ADMIN_PASSWORD=5m2-meG04e70m-wdf99s-dhnm" \
  --name opensearch \
  docker.io/opensearchproject/opensearch:latest
```

This command does the following:
- Runs the OpenTelemetry Collector in a Docker container.
- Opens necessary ports for communication.
- Mounts the current directory (./) into the container to access the configuration file (example-configuration.yaml).

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

### Check the Logs
You can view the app's output logs by running:

```sh
tail -f logs.json
```

This will display the log output in real-time as the app runs.

By following these steps, you'll have the OpenTelemetry Collector running, your Java app instrumented with OpenTelemetry, and be able to observe telemetry data in the logs.
