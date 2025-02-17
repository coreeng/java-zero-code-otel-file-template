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

run-server:
	JAVA_TOOL_OPTIONS=-javaagent:opentelemetry-javaagent.jar
	java -jar build/libs/java-zero-code-otel-reference-app-0.0.1-SNAPSHOT.jar

start-alloy:
	alloy run --stability.level experimental config.alloy

start-opensearch:
	docker network create shared || true
	docker run -d --rm \
		--net shared \
		-p 9200:9200 \
		-p 9600:9600 \
		-e "discovery.type=single-node" \
		-e OPENSEARCH_INITIAL_ADMIN_PASSWORD \
		--name opensearch \
		--replace docker.io/opensearchproject/opensearch:latest

start-otel-collector:
	docker network create shared || true
	docker run -d --rm \
		--net shared \
		-p 4317:4317 \
		-p 4318:4318 \
		-p 55679:55679 \
		-v ./:/app \
		docker.io/otel/opentelemetry-collector-contrib:0.119.0 \
		--config /app/example-configuration.yaml

