# docker image with the kosit validator and xrechnung configuration

this repo is the source for a docker image that holds a containerized version of the kosit validator including the german xrechnung configration (UBL and CII)

docker hub link: [link](https://hub.docker.com/r/flx235/xr-validator-service)

## kosit sourcefiles

- [kosit validator](https://github.com/itplr-kosit/validator) version `1.5.0` JAR file `validationtool-1.5.0-standalone.jar`
- [kosit xrechnung configuration](https://github.com/itplr-kosit/validator-configuration-xrechnung/) version `3.0.2` (`/resources`, `EN16931-CII-validation.xslt`, `EN16931-UBL-validation.xslt`, `scenarios.xml`)

## notes/misc

- validator using [daemon mode](https://github.com/itplr-kosit/validator/blob/main/docs/daemon.md) (`-D` Daemon, `-H` Host, `-P` Port), so the validator provides http service
- for docker deployment, the service inside docker needs to run on `0.0.0.0`
- example to run alidator locally w/o docker: `java -jar validationtool-1.5.0-standalone.jar -s scenarios.xml -r ${PWD} -D -H localhost -P 8081` (`${PWD}` Path Working Directory)
- example for dockerfile OS command to start the validator:
`CMD ["java", "-jar", "validationtool-1.5.0-standalone.jar", "-s", "scenarios.xml", "-r", "/app", "-D", "-H", "0.0.0.0", "-P", "8081"]`
`--disable-gui` flag / `:nogui` build: this repo was meant to provide the validator service via https and build frontend around, so the gui provided by the http daemon can be ignored

## quickstart

- `git clone`
- start validator locally: `java -jar validationtool-1.5.0-standalone.jar -s scenarios.xml -r ${PWD} -D -H localhost -P 8081`
- test running service with XRechnung XMLs `curl -i --location --request POST 'http://localhost:8081' --header 'Content-Type: application/xml' --data-binary "@test/ubl.xml"` (`-i` include headers in reponse)
- build `docker build -t user/<image_name>:<tag> -f Dockerfile .`
- run `docker run -p 8081:8081 <image_name>:<tag>` (port forwarding may be required)

## min overview docker cmds

- optional flag for build: `--no-cache`
- docker build to run validator with gui: `docker build -t user/<image_name>:<tag> -f Dockerfile .`
- docker build to run validator without gui: `docker build -t user/<image_name>:<tag> -f DockerfileNoGui .`
- run container: `docker run -p 8081:8081 user/<image_name>:<tag>`
- safe working docker image as \*.tar file: `docker save -o my-image.tar my-image`
- tagging: `docker tag user/<image_name>:<tag>`
- push to hub: `docker push user/<image_name>:<tag>`

## min overview linux setup to run docker image

### docker

- update and upgrade packages: `sudo apt update` & `sudo apt upgrade`

- install docker req. packages:
`sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common`

- install docker: `curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -`

- add docker dapt-repository: `sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"`

- install docker packages:
`sudo apt install -y docker-ce docker-ce-cli containerd.io`

- pull docker image and start validator: `docker pull`, `docker run`

### nginx

- setup nginx (..)
- example for subdomain nginx config:

```powershell

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
