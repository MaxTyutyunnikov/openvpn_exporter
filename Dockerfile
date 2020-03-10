# build stage
FROM golang:1.14-alpine AS build-env

ENV GO111MODULE=on \
    CGO_ENABLED=0
    
WORKDIR /src

COPY go.mod .
COPY go.sum .
RUN go mod download

# add source
ADD . .

RUN go build -ldflags="-w -s"

# final stage
FROM debian
COPY --from=build-env /src/openvpn_exporter /bin/openvpn_exporter
ENTRYPOINT ["/bin/openvpn_exporter"]
CMD [ "-h" ]
