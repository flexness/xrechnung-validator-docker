# docker image for the kosit validator for xrechnung XML invoices

this repo is the source for a docker image, running a containerized KOSIT validator for the german XRechnung (german e-invoicing standard)

docker hub link: https://hub.docker.com/r/user/xr-validator-service


## kosit sourcefiles (latest)
- validator: https://github.com/itplr-kosit/validator (1.5.0)
- validator xrechnung configuration: https://github.com/itplr-kosit/validator-configuration-xrechnung (release-2023-11-15)
- files from the source included in the docker image:		
	- `/libs`	
	- `/resources`
	- `EN16931-CII-validation.xslt`
	- `EN16931-UBL-validation.xslt`
	- `scenarios.xml`
	- `validationtool-1.5.0-standalone.jar`

## notes
- validator running in daemon mode (`-D`, `-H`, `-P`), so the validator gets as exposed as http service
- running this repo/validator locally w/o docker: 

`java -jar validationtool-1.5.0-standalone.jar -s scenarios.xml -r ${PWD} -D -H localhost -P 8081`
- for docker deployment, the service inside docker needs to run on `0.0.0.0`:

`CMD ["java", "-jar", "validationtool-1.5.0-standalone.jar", "-s", "scenarios.xml", "-r", "/app", "-D", "-H", "0.0.0.0", "-P", "8081"]`

## running/building locally
- `git clone`
- `java -jar validationtool-1.5.0-standalone.jar -s scenarios.xml -r ${PWD} -D -H localhost -P <port>`
- `curl --location --request POST 'http://localhost:8081' --header 'Content-Type: application/xml' --data-binary "@ubl.xml"`
- `docker build -t user/<image_name>:<tag> -f Dockerfile .`
- `docker run -p 8081:8081 <image_name>:<tag>` (port forwarding may be required)

## docker cmds
- optional flag for build: `--no-cache`
- docker build to run validator with gui: `docker build -t user/<image_name>:<tag> -f Dockerfile .`
- docker build to run validator without gui:`docker build -t user/<image_name>:<tag> -f DockerfileNoGui .`
- run container: `docker run -p 8081:8081 user/<image_name>:<tag>` 
- safe working docker image as \*.tar file: `docker save -o my-image.tar my-image`
- tagging: `docker tag user/<image_name>:<tag>`
- push to hub: `docker push user/<image_name>:<tag>`
	
## alternative deployments
- saas (tba)
