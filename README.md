<img src="logo/logo.png" />

**Docker letsencrypt nginx proxy companion** is a collection of dockerized companion services for proxying Docker containers over SSL.

### Requirements

- [Docker Community Edition](https://www.docker.com/community-edition)
- [Docker Compose](https://docs.docker.com/compose/)
- [GNU make](https://www.gnu.org/software/make/)

### Services

- [nginx-gen](https://github.com/jwilder/docker-gen) - File generator that renders templates using docker container meta-data.
- [nginx-letsencrypt](https://github.com/nginx-proxy/docker-letsencrypt-nginx-proxy-companion) - Lets Encrypt companion container for NGINX.
- [nginx-web](https://hub.docker.com/_/nginx) - Reverse proxy server for HTTP & HTTPS.

## Installation

1. Create a `.env` file using [`.env.example`](.env.example) as a reference.
2. Pull the docker images by running `make pull`.

## Setup

Before running this collection for the first time you must create the external network by running `make network`.

## Usage

To bring up the proxy:

```
make up
```

To bring down the proxy:

```
make down
```

To restart a service:

```
make restart service="<service>"
```

To stop a service:

```
make stop service="<service>"
```

To run a command against a running service:

```
make exec service="<service>" cmd="command"
```

To view logs:

```
make logs [service="<service>"] [file=/path/to/log/file]
```

To remove any images & containers (will require another `make build`):

```
make clean
```

## ENV Options
| Option                    | Description                                                                                                   |
| ------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `PROJECT_NAME`            | The docker compose project name. Will be used as a prefix for all containers.                                 |
| `NGINX_DATA_PATH`         | NGINX files path. Here you can configure the path where NGINX stores all the configurations and certificates. |
| `DOCKER_SOCKET_PATH`      | The host docker socket path.                                                                                  |
| `NETWORK`                 | The name of the docker network for proxying.                                                                  |
| `NETWORK_OPTIONS`         | Docker network options when creating the network.                                                             |
| `NGINX_GEN_SSL_POLICY`    | The SSL policy. See available options here: https://github.com/jwilder/nginx-proxy#how-ssl-support-works.     |
| `NGINX_LETSENCRYPT_EMAIL` | Email so that Let's Encrypt can warn you about expiring certificates and allow you to recover your account.   |
| `NGINX_WEB_HTTP_PORT`     | Locally exposed ports for http on the Host.                                                                   |
| `NGINX_WEB_HTTPS_PORT`    | Locally exposed ports for https on the Host.                                                                  |

## Proxying Docker Containers

After following the steps above you can create new docker web containers that will automatically forward any connections over SSL.

Once this collection is running, start any container you want proxyed with environment variables `VIRTUAL_HOST` and `LETSENCRYPT_HOST` both set to the domain(s) your proxyed container is going to use.
`VIRTUAL_HOST` controls proxying by NGINX and `LETSENCRYPT_HOST` controls certificate creation by LetsEncrypt.

If the proxyed container listen on and expose another port other than the default `80`, you can force NGINX to use this port with the `VIRTUAL_PORT` environment variable.

## Credits

Without the repositories below this collection wouldn't be possible.

Credits goes to:

* [@jwilder](https://github.com/jwilder).
* [@JrCs](https://github.com/JrCs).
