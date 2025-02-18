PROJECT_DIR := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))
GIT_REPO_NAME := $(shell basename $(shell git config --get remote.origin.url) .git)
SHELL := /usr/bin/env bash -o pipefail -e
REQ_BINS = java curl docker
_ := $(foreach exec,$(REQ_BINS), \
       $(if $(shell which $(exec)),some string,$(error "No $(exec) binary in $$PATH")))

MAKEFLAGS += --warn-undefined-variables


build-jar:
	JAVA_TOOL_OPTIONS="" ./gradlew bootJar

request:
	curl http://localhost:8080/rolldice

run-server: build-jar
	JAVA_TOOL_OPTIONS=-javaagent:opentelemetry-javaagent.jar java -jar build/libs/java-zero-code-otel-reference-app-0.0.1-SNAPSHOT.jar

create-docker-network:
	docker network create shared || true

start-alloy: create-docker-network
	docker run --rm -d \
		--net shared \
		--name alloy \
		-v ./config.alloy:/etc/alloy/config.alloy \
		-p 4317:4317 \
		-p 4318:4318 \
		-p 12345:12345 \
		-e OPENSEARCH_INITIAL_ADMIN_PASSWORD \
		-e OPENSEARCH_USERNAME \
		-e OPENSEARCH_URI="https://opensearch:9200" \
		-e LOKI_URI="http://loki:3100" \
		--replace \
		docker.io/grafana/alloy:v1.6.1 \
		run --stability.level experimental --server.http.listen-addr=0.0.0.0:12345 --storage.path=/var/lib/alloy/data \
		/etc/alloy/config.alloy

start-opensearch: create-docker-network
	docker run -d --rm \
		--net shared \
		-p 9200:9200 \
		-p 9600:9600 \
		-e "discovery.type=single-node" \
		-e OPENSEARCH_INITIAL_ADMIN_PASSWORD \
		--name opensearch \
		--replace \
		--replace docker.io/opensearchproject/opensearch:latest

start-otel-collector: create-docker-network
	touch metrics.json || true
	chmod 777 metrics.json || true
	docker run -d --rm \
		--net shared \
		--name otel-collector \
		-p 4317:4317 \
		-p 4318:4318 \
		-p 55679:55679 \
		--replace \
		-v ./:/app \
		docker.io/otel/opentelemetry-collector-contrib:0.119.0 \
		--config /app/example-configuration.yaml

start-grafana: create-docker-network
	docker run -d --rm \
		--net shared \
		--name=grafana -p 3000:3000 \
		--replace \
		docker.io/grafana/grafana:main

start-loki: create-docker-network
	docker run -d --rm \
		--net shared \
		--name=loki -p 3100:3100 \
		--replace \
		docker.io/grafana/loki:3.4

demo-alloy: start-opensearch start-loki start-grafana start-alloy run-server

demo-otel: start-opensearch start-loki start-grafana start-otel-collector run-server
