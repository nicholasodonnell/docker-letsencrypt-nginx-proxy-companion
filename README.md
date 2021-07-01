<img src="logo/logo.png" />

**Docker LetsEncrypt NGINX proxy companion** is a collection of dockerized companion services for proxying Docker containers over SSL.

### Requirements

- [Docker Community Edition](https://www.docker.com/community-edition)
- [Docker Compose](https://docs.docker.com/compose/)
- [GNU make](https://www.gnu.org/software/make/)

### Services

- [nginx-gen](https://github.com/jwilder/docker-gen) - File generator that renders templates using docker container meta-data.
- [nginx-letsencrypt](https://github.com/nginx-proxy/docker-letsencrypt-nginx-proxy-companion) - Lets Encrypt companion container for NGINX.
- [nginx-web](https://hub.docker.com/_/nginx) - Reverse proxy server for HTTP & HTTPS.

## Installation

1. Create a `.env` file using [`.env.example`](.env.example) as a reference: `cp -n .env{.example,}`.
2. Create a `docker-compose.override.yml` file using [`docker-compose.override.example.yml`](docker-compose.override.example.yml) as a reference: `cp -n docker-compose.override{.example,}.yml`.
3. Pull the required docker images by running `make pull`.

## Setup

Before running this collection for the first time you must create the external network by running `make network`.

## Usage

To start the collection:

```
make up
```

To stop the collection:

```
make down
```

To view logs:

```
make logs [service="<service>"] [file="/path/to/log/file"]
```

To build docker images:

```
make build
```

To remove docker images:

```
make clean
```

## ENV Options

| Option                     | Description                                                                                                   |
| -------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `NGINX_DATA_PATH`          | NGINX files path. Here you can configure the path where NGINX stores all the configurations and certificates. |
| `DOCKER_SOCKET_PATH`       | The host docker socket path.                                                                                  |
| `EXTERNAL_NETWORK`         | Name of the external docker network for proxying.                                                             |
| `EXTERNAL_NETWORK_OPTIONS` | Docker network options when creating the external network.                                                    |
| `NGINX_GEN_SSL_POLICY`     | The SSL policy. See available options here: https://github.com/jwilder/nginx-proxy#how-ssl-support-works.     |
| `NGINX_LETSENCRYPT_EMAIL`  | Email so that Let's Encrypt can warn you about expiring certificates and allow you to recover your account.   |
| `NGINX_WEB_HTTP_PORT`      | Locally exposed ports for HTTP on the host.                                                                   |
| `NGINX_WEB_HTTPS_PORT`     | Locally exposed ports for HTTPS on the host.                                                                  |

## Proxying Docker Containers

After following the steps above you can create new docker containers that will automatically proxy any connections over SSL.

> External containers must be attached to the external network defined in your `EXTERNAL_NETWORK` variable in order to resolve properly.

Once this collection is running, simply start a container you want proxyed with environment variables `VIRTUAL_HOST` and `LETSENCRYPT_HOST` both set to the domain(s) your proxyed container is going to use.

> `VIRTUAL_HOST` controls proxying by nginx-web and `LETSENCRYPT_HOST` control certificate creation and SSL enabling by nginx-letsencrypt.
> Certificates will only be issued for containers that have both `VIRTUAL_HOST` and `LETSENCRYPT_HOST` variables set to the domain(s) that correctly resolve to the host, provided the host is publicly reachable.

If this collectioned container listen on and exposes another port other than the default `80`, you can force NGINX to use this port with the `VIRTUAL_PORT` environment variable.

#### Examples

```bash
docker run \
  --env "LETSENCRYPT_HOST=subdomain.yourdomain.tld" \
  --env "VIRTUAL_HOST=subdomain.yourdomain.tld" \
  --env "VIRTUAL_PORT=80" \
  --expose=80 \
  --name app \
  --network=webproxy \
  nginx
```

```yml
version: "3.5"
services:
  app:
    container_name: app
    environment:
      - LETSENCRYPT_HOST=subdomain.yourdomain.tld
      - VIRTUAL_HOST=subdomain.yourdomain.tld
      - VIRTUAL_PORT=80
    expose:
      - 80
    image: nginx
    networks:
      - webproxy

networks:
  webproxy:
    external:
      name: webproxy
```

## Advanced Usage

The following environment variables can be used for more advanced usage:

| Variable                  | Description                                                                                                                                                     |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `HTTPS_METHOD=noredirect` | Disable the automatic SSL redirect on the proxyed container.                                                                                                    |
| `HTTPS_METHOD=nohttps`    | Disable the non-SSL site on the proxyed container (http only).                                                                                                  |
| `HSTS=...`                | Customize the [Strict-Transport-Security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security) header on the proxyed container. |
| `HSTS=off`                | Disable the [Strict-Transport-Security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security) header on the proxyed container.   |
| `DEFAULT_HOST`            | Set the default NGINX host for `nginx-gen`.                                                                                                                     |

#### Per-`VIRTUAL_HOST` NGINX conf

To add NGINX conf options on a per-`VIRTUAL_HOST` basis: add your configuration file under `{NGINX_DATA_PATH}/vhost.d/{VIRTUAL_HOST}`.

To add a NGINX conf *location* block on a per-`VIRTUAL_HOST` basis: add your configuration file under `{NGINX_DATA_PATH}/vhost.d/{VIRTUAL_HOST}_location`.

#### `VIRTUAL_HOST` default conf

If you want your `VIRTUAL_HOST` to use some default NGINX conf options: add a configuration file under `{NGINX_DATA_PATH}/vhost.d/default`.

If you want your `VIRTUAL_HOST` to use some default NGINX conf *location* block: add your configuration file under `{NGINX_DATA_PATH}/vhost.d/default_location`.

#### Basic Authentication Support

In order to secure your `VIRTUAL_HOST` with basic auth: add a [`htpasswd`](https://httpd.apache.org/docs/2.2/programs/htpasswd.html) file under `{NGINX_DATA_PATH}/htpasswd/{VIRTUAL_HOST}`.

## Credits

Without the authors below this collection wouldn't be possible. Credits goes to:

- [@jwilder](https://github.com/jwilder)
- [@JrCs](https://github.com/JrCs)
