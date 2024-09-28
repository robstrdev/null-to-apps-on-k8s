FROM golang:1.22.1-alpine3.19 AS build
WORKDIR /app

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY *.go .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o webapp

FROM alpine:3.20.3
LABEL maintainer="Roberth Strand <me@robstr.dev>"
RUN apk --no-cache add ca-certificates \
&& mkdir /home/nonroot && adduser -S nonroot

WORKDIR /home/nonroot
USER nonroot

COPY --from=build /app/webapp ./
COPY public/index.html public/index.html

EXPOSE 9020

ENTRYPOINT [ "/home/nonroot/webapp" ]