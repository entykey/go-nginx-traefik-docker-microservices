# ERROR:
    # => ERROR [goservice build 6/7] RUN go get github.com/gorilla/mux                                                     1.9s
    # ------
    #  > [goservice build 6/7] RUN go get github.com/gorilla/mux:
    # 1.841 # github.com/gorilla/mux
    # 1.841 ../github.com/gorilla/mux/route.go:28:15: undefined: any
    # ------
    # failed to solve: process "/bin/sh -c go get github.com/gorilla/mux" did not complete successfully: exit code: 2

# FROM golang:1.12.7-alpine3.10 AS build
# # Support CGO and SSL
# RUN apk --no-cache add gcc g++ make
# RUN apk add git
# WORKDIR /go/src/app
# COPY . .
# RUN go get github.com/gorilla/mux
# RUN GOOS=linux go build -ldflags="-s -w" -o ./bin/test ./main.go

# FROM alpine:3.10
# RUN apk --no-cache add ca-certificates
# WORKDIR /usr/bin
# COPY --from=build /go/src/app/bin /go/bin
# EXPOSE 8080
# ENTRYPOINT /go/bin/test --port 8080





FROM golang:1.24-alpine AS builder

RUN apk update && apk add alpine-sdk git && rm -rf /var/cache/apk/*

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /app/main .

# would cause build stage error due to .env does not exist !
# COPY --from=builder /app/.env .

# Use the PORT environment variable
ENV PORT=8080

# Expose the internal port (8080)
EXPOSE 8080

ENTRYPOINT ["./main"]