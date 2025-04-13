# Use Nginx Reverse Proxy to serve Go Services
Golang served by Nginx reverse proxy.


[Check the tutorial on Medium](https://medium.com/@alessandromarinoac/docker-nginx-golang-reverse-proxy-d8244778bd43 "Tutorial on Medium")

#  <font color='red'>Requirements</font>
* Install on of the latest stable version of [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1), and install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* Install [Docker Compose](https://docs.docker.com/compose/install/#install-compose)

#  <font color='red'>Installation</font>
* Browse the repository's root
* Build the images 
    - `docker-compose build`
* Start containers 
    - `docker-compose up -d`

After starting containers you can test the Api at:
```url
http://localhost/api/
```

#  <font color='red'>Code Building</font>
Golang is a compiled programming language so to make any changes to your app, you need to build the executable again.
In this repo the build process is done inside the docker-build process.
So when you need to re-compile the code you can follow this steps:

- `docker-compose down`
- `docker-compose build`
- `docker-compose up -d`

To simplify this steps you can create a makefile and group this commands in a single one, or on *nix system you can use this version of the commands: 
```shell
docker-compose down && docker-compose build && docker-compose up -d
```


# Use Traefik instead of Nginx
**Project structure:**
```
TuanhayhoMacBookPro:go-nginx-traefik-docker-microservices user$ tree -L 3
.
├── Dockerfile
├── LICENSE
├── README.md
├── docker-compose.yaml
├── go.mod
├── go.sum
├── imgs
│   └── images_sizes.png
├── main.go
├── nginx
│   ├── Dockerfile
│   └── nginx.conf
└── nodejs
    ├── Dockerfile
    ├── index.js
    ├── node_modules
    ├── package-lock.json
    └── package.json

```

**docker-compose.yaml:**
```yml
services:
  traefik:
    image: traefik:v2.2
    command:
      - --api.insecure=true
      - --providers.docker
      - --entrypoints.web.address=:80
    ports:
      - "80:80"
      - "8080:8080" # Traefik dashboard
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

  goservice:
    build: .
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.goservice.rule=PathPrefix(`/api/go`)"
      - "traefik.http.services.goservice.loadbalancer.server.port=8080"

  nodeservice:
    build: ./nodejs
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nodeservice.rule=PathPrefix(`/api/node`)"
      - "traefik.http.services.nodeservice.loadbalancer.server.port=3000"

  # You can keep nginx if you want, but with Traefik it's not necessary !
  # nginx:
  #   build: "./nginx"
  #   ports:
  #     - "80:80"
  #   depends_on:
  #     - "goservice"
```

**Nodes lightwight build Dockerfile:**
```
# Stage 1: Build
FROM node:16-alpine AS builder

WORKDIR /usr/src/app

# Copy package files first để tận dụng Docker cache layer
COPY package.json package-lock.json ./

# Install dependencies (bao gồm cả devDependencies)
RUN npm ci --production

# Copy source code
COPY . .

# Stage 2: Runtime
FROM node:16-alpine

WORKDIR /usr/src/app

# Copy từ builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/index.js ./

# Giảm quyền của user
USER node

EXPOSE 3000
CMD ["node", "index.js"]
```

**Error with new Nodes Service Dockerfike**
```
TuanhayhoMacBookPro:medium-go-nginx-docker-alessandromr user$ docker compose up -d --build
WARN[0000] /Users/user/Documents/medium-go-nginx-docker-alessandromr/docker-compose.yaml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] Running 5/5
 ✔ traefik Pulled                                                                                                    12.7s 
   ✔ 97518928ae5f Pull complete                                                                                       3.0s 
   ✔ 8f1084cd7998 Pull complete                                                                                       4.3s 
   ✔ cd589cd7ab30 Pull complete                                                                                       6.5s 
   ✔ 34d201bdb744 Pull complete                                                                                       6.5s 
[+] Building 5.3s (18/30)                                                                             docker:desktop-linux
 => [nodeservice internal] load build definition from Dockerfile                                                      0.1s
 => => transferring dockerfile: 595B                                                                                  0.0s
 => [goservice internal] load build definition from Dockerfile                                                        0.1s
 => => transferring dockerfile: 1.52kB                                                                                0.0s
 => [goservice internal] load metadata for docker.io/library/golang:1.24-alpine                                       3.6s
 => [goservice internal] load metadata for docker.io/library/alpine:latest                                            3.6s
 => [nodeservice internal] load metadata for docker.io/library/node:16-alpine                                         3.6s
 => [goservice auth] library/golang:pull token for registry-1.docker.io                                               0.0s
 => [nodeservice auth] library/node:pull token for registry-1.docker.io                                               0.0s
 => [goservice auth] library/alpine:pull token for registry-1.docker.io                                               0.0s
 => [goservice internal] load .dockerignore                                                                           0.1s
 => => transferring context: 2B                                                                                       0.0s
 => [nodeservice internal] load .dockerignore                                                                         0.1s
 => => transferring context: 2B                                                                                       0.0s
 => CANCELED [goservice builder 1/7] FROM docker.io/library/golang:1.24-alpine@sha256:7772cb5322baa875edd74705556d08  0.6s
 => => resolve docker.io/library/golang:1.24-alpine@sha256:7772cb5322baa875edd74705556d08f0eeca7b9c4b5367754ce3f2f00  0.1s
 => => sha256:7772cb5322baa875edd74705556d08f0eeca7b9c4b5367754ce3f2f00041ccee 10.29kB / 10.29kB                      0.0s
 => => sha256:3077e12cda6debf8a9eba8eba0b6b4efe6f9c17295a18e3883cc5797d1688acb 1.92kB / 1.92kB                        0.0s
 => => sha256:dce68b1cd2298b5ece1593ada1a8ebb7962c2d2d820d98342cddcd0e2f1495e4 2.08kB / 2.08kB                        0.0s
 => => sha256:efda6a9ec0ed27775d0887572a23317fed2c90e7dc2dbe7ce0dfebddc8ae41f6 0B / 126B                              1.4s
 => => sha256:cfdff1cf77cc238c3b8e5663c583e181f4a737027e840204038f02071b9c7faf 0B / 294.90kB                          1.4s
 => => sha256:f1d296901bdc593d88a0813bb00eef0974b68222cba6add046b831c086a1c68c 0B / 78.94MB                           1.4s
 => [goservice stage-1 1/4] FROM docker.io/library/alpine:latest@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75  0.3s
 => => resolve docker.io/library/alpine:latest@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef8  0.1s
 => => sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c 9.22kB / 9.22kB                        0.0s
 => => sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474 1.02kB / 1.02kB                        0.0s
 => => sha256:aded1e1a5b3705116fa0a92ba074a5e0b0031647d9c315983ccba2ee5428ec8b 581B / 581B                            0.0s
 => [goservice internal] load build context                                                                           0.2s
 => => transferring context: 15.61kB                                                                                  0.1s
 => [nodeservice internal] load build context                                                                         0.3s
 => => transferring context: 1.15kB                                                                                   0.0s
 => CANCELED [nodeservice builder 1/5] FROM docker.io/library/node:16-alpine@sha256:a1f9d027912b58a7c75be7716c97cfbc  0.3s
 => => resolve docker.io/library/node:16-alpine@sha256:a1f9d027912b58a7c75be7716c97cfbc6d3099f3a97ed84aa490be9dee20e  0.1s
 => => sha256:a1f9d027912b58a7c75be7716c97cfbc6d3099f3a97ed84aa490be9dee20e787 1.43kB / 1.43kB                        0.0s
 => => sha256:72e89a86be58c922ed7b1475e5e6f151537676470695dd106521738b060e139d 1.16kB / 1.16kB                        0.0s
 => => sha256:2573171e0124bb95d14d128728a52a97bb917ef45d7c4fa8cfe76bc44aa78b73 6.73kB / 6.73kB                        0.0s
 => => sha256:93b3025fe10392717d06ec0d012a9ffa2039d766a322aac899c6831dd93382c2 0B / 2.34MB                            1.4s
 => => sha256:7264a8db6415046d36d16ba98b79778e18accee6ffa71850405994cffa9be7de 0B / 3.40MB                            1.4s
 => CACHED [nodeservice builder 2/5] WORKDIR /usr/src/app                                                             0.0s
 => ERROR [nodeservice builder 3/5] COPY package.json package-lock.json ./                                            0.0s
 => CANCELED [goservice stage-1 2/4] RUN apk --no-cache add ca-certificates                                           1.2s
------
 > [nodeservice builder 3/5] COPY package.json package-lock.json ./:
------
failed to solve: failed to compute cache key: failed to calculate checksum of ref 47bfa8e4-8554-46be-b875-2cdfc0c766bd::l68tj2fmkd9emdhhfq70fmg82: "/package-lock.json": not found
```

- This error occurs due to missing `package-lock.json` file in `nodejs/` directory. Let's fix the error and optimize `Dockerfile`:

**Steps to resolve:**
1. Create package-lock.json file:
```sh
cd nodejs
npm init -y
npm install express --save
```

2. Update `nodejs/Dockerfile`:

```dockerfile
# Stage 1: Build
FROM node:16-alpine AS builder

WORKDIR /usr/src/app

# Chỉ copy package.json trước (nếu không có package-lock.json)
COPY package.json ./

# Install dependencies
RUN npm install --production

# Copy source code
COPY index.js ./

# Stage 2: Runtime
FROM node:16-alpine

WORKDIR /usr/src/app

# Copy từ builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/index.js ./

# Giảm quyền
USER node

EXPOSE 3000
CMD ["node", "index.js"]
```

### Inspect
- Access Traefik dashboard: http://localhost:8080

- Go service API: http://localhost/api/go

- NodeJS service API: http://localhost/api/node

### Giải thích cấu hình Traefik
1. Traefik service**:
- Sử dụng image Traefik v2.5
- Kích hoạt Docker provider để tự động phát hiện các service
- Mở port 80 cho web và 8080 cho dashboard

2. Labels trong các service:

- `traefik.enable=true`: Kích hoạt Traefik cho service

- `traefik.http.routers.[service].rule`: Quy tắc định tuyến

- `traefik.http.services.[service].loadbalancer.server.port`: Port mà service lắng nghe

Với cấu hình này, ta có thể dễ dàng thêm các service khác vào hệ thống mà không cần phải cấu hình Nginx thủ công.