# Docker image with the kosit XML validator and xrechnung configuration

[kosit validator](https://github.com/itplr-kosit/validator) `1.5.0` + [XRechnung configuration](https://github.com/itplr-kosit/validator-configuration-xrechnung/) `3.0.2` as docker-image

## disclaimer

The repository and the docker-image are **not** affiliated with or officially supported by the maintainers of the KoSIT validator.

No files were changed. The original license/notice of the validator and the changelog the XRechnung configuration are included in the repository.

## about this repository

Its a source for a docker-image that holds a containerized version of the kosit [kosit XML validator](https://github.com/itplr-kosit/validator) including the most recent german [XRechnung configuration](https://github.com/itplr-kosit/validator-configuration-xrechnung/). XML files in `/test` are picked from the [kosit testsuite](https://github.com/itplr-kosit/xrechnung-testsuite⁠).

docker hub link: [flx235/xr-validator-service](https://hub.docker.com/r/flx235/xr-validator-service) (latest tag: `302`)

## KoSIT sourcefiles

- [kosit validator](https://github.com/itplr-kosit/validator) version `1.5.0` JAR file `validationtool-1.5.0-standalone.jar`
- [kosit xrechnung configuration](https://github.com/itplr-kosit/validator-configuration-xrechnung/) version `3.0.2` (`/resources`, `EN16931-CII-validation.xslt`, `EN16931-UBL-validation.xslt`, `scenarios.xml`)
- [kosit testsuite](https://github.com/itplr-kosit/xrechnung-testsuite⁠)

## notes/misc

- validator using [daemon mode](https://github.com/itplr-kosit/validator/blob/main/docs/daemon.md) (`-D` Daemon, `-H` Host, `-P` Port), so the validator provides http service
- for docker deployment, the service inside docker needs to run on `0.0.0.0`
- example to run alidator locally w/o docker: `java -jar validationtool-1.5.0-standalone.jar -s scenarios.xml -r ${PWD} -D -H localhost -P 8081` (`${PWD}` Path Working Directory)
- example for dockerfile OS command to start the validator:
`CMD ["java", "-jar", "validationtool-1.5.0-standalone.jar", "-s", "scenarios.xml", "-r", "/app", "-D", "-H", "0.0.0.0", "-P", "8081"]`
`--disable-gui` flag: this repo was meant to provide the validator service via https and build api/frontend around

## quickstart build

- `git clone`
- start validator locally: `java -jar validationtool-1.5.0-standalone.jar -s scenarios.xml -r ${PWD} -D -H localhost -P 8081`
- test running service with XRechnung XMLs `curl -v -i --location POST 'http://localhost:8081' --header 'Content-Type: application/xml' --data-binary "@test/min_ubl.xml"` (`-i` include headers in reponse; `-v` for verbose logging)
- build `docker build -t user/<image_name>:<tag> -f Dockerfile .`
- run `docker run -p 8081:8081 <image_name>:<tag>` (port forwarding may be required)

## min overview docker cmds

- build container: `docker build -t user/<image_name>:<tag> -f Dockerfile .` (optional flag for build: `--no-cache`)
- run container: `docker run -p 8081:8081 user/<image_name>:<tag>`
- safe docker image as \*.tar file: `docker save -o <image_name>.tar <image_name>`
- tagging: `docker tag user/<image_name>:<tag>`
- push to docker-hub: `docker push user/<image_name>:<tag>`

## min overview linux setup to run docker image

- setup docker and run container/image
- setup nginx to proxy https from subdomain to docker

### docker

- update and upgrade packages: `sudo apt update` & `sudo apt upgrade`
- install docker req. packages: `sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common`
- install docker: `curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -`
- add docker apt-repository: `sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"`
- install docker packages: `sudo apt install -y docker-ce docker-ce-cli containerd.io`
- pull docker image and start validator: `docker pull` & `docker run`
- verify docker container `docker ps -a`

### nginx

- requires running nginx, certbot (..)
- add protection / auth levels as needed (..)
- example for subdomain nginx config:

```bash

server {
    listen 80;
    listen [::]:80;
    server_name <subdomain>.cluster.server.com;

    # redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name <subdomain>.cluster.server.com;

    # ssl certs (certbot)
    ssl_certificate /etc/letsencrypt/live/<subdomain>.cluster.server.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<subdomain>.cluster.server.com/privkey.pem;

    # serve files directly
    location / {
        proxy_pass http://127.0.0.1:8081/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

       # optional logging/debugging 
       error_log /var/log/nginx/docker_validator_error.log;
       access_log /var/log/nginx/docker_validator_access.log;
    }

    # optional logging/debugging
    access_log /var/log/nginx/<subdomain>_access.log;
    error_log /var/log/nginx/<subdomain>_error.log;
}
```
