.PHONY: run build test lint fmt tidy


run:
go run ./cmd/api


build:
go build -o bin/api ./cmd/api


test:
go test ./...


lint:
@golangci-lint run || echo "Install golangci-lint or skip"


fmt:
gofmt -s -w .


tidy:
go mod tidy
