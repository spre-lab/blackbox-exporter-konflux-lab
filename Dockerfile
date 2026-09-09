FROM golang:1.25 AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o /blackbox_exporter .

FROM quay.io/prometheus/busybox-linux-amd64:latest

COPY --from=builder /blackbox_exporter /bin/blackbox_exporter
COPY blackbox.yml /etc/blackbox_exporter/config.yml

EXPOSE 9115

ENTRYPOINT ["/bin/blackbox_exporter"]
CMD ["--config.file=/etc/blackbox_exporter/config.yml"]
