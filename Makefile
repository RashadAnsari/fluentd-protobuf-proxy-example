export ROOT=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))

proto-code-gen:
	docker run --rm -it -v `pwd`/proto:/proto --entrypoint=/bin/sh jaegertracing/protobuf:0.3.0 -c "protoc --go_out=. ./proto/*.proto"

up:
	docker-compose up -d

log:
	docker logs -f fluentd

run-producer:
	go run producer.go

run-consumer:
	go run consumer.go

create-topic:
	docker exec -it kafka /opt/bitnami/kafka/bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --topic hello_world --partitions 1 --replication-factor 1

kafka-consume:
	docker exec -it kafka /opt/bitnami/kafka/bin/kafka-console-consumer.sh --topic hello_world --from-beginning --bootstrap-server kafka:9092

down:
	docker-compose down

check-formatter:
	which goimports || GO111MODULE=off go get -u golang.org/x/tools/cmd/goimports

format: check-formatter
	find $(ROOT) -type f -name "*.go" -not -path "$(ROOT)/vendor/*" | xargs -n 1 -I R goimports -w R
	find $(ROOT) -type f -name "*.go" -not -path "$(ROOT)/vendor/*" | xargs -n 1 -I R gofmt -s -w R

check-linter:
	which golangci-lint || GO111MODULE=off go get -u github.com/golangci/golangci-lint/cmd/golangci-lint@v1.23.8

lint: check-linter
	golangci-lint run $(ROOT)/...
