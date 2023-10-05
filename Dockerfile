FROM golang:1.17 AS build

WORKDIR /go/src/app
COPY . .

RUN go build && chmod +x /go/src/app/openvpn_exporter

FROM debian as image
COPY --from=build /go/src/app/openvpn_exporter /openvpn_exporter
ENTRYPOINT ["/openvpn_exporter"]
CMD [ "-h" ]
