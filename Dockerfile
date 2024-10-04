FROM golang:1.22 AS builder

RUN mkdir -p /go/src/gofr
WORKDIR /go/src/gofr

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -ldflags "-linkmode external -extldflags -static" -a -o main ./examples/http-server/main.go

FROM alpine:latest

RUN apk add --no-cache tzdata ca-certificates

COPY --from=builder /go/src/gofr/main /main

EXPOSE 8000
EXPOSE 9090

ENV LOG_LEVEL=debug
ENV TRACE_ENABLED=true
ENV METRICS_ENABLED=true
ENV JAEGER_AGENT_HOST=jaeger
ENV JAEGER_AGENT_PORT=6831

WORKDIR /app

CMD ["./main"]
