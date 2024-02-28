# repo for a xrechnung validator docker image based on the kosit

this repo is the source of an docker image for running a containerized / deployment-ready version of the KOSIT validator for the german XRechnung standard.

docker hub link: https://hub.docker.com/r/flx235/xr-validator-service

## kosit / source
- basic kosit validator: https://github.com/itplr-kosit/validator
- kosit xrechnung configuration for the validator: https://github.com/itplr-kosit/validator-configuration-xrechnung
- kosit source files:
	- validationtool-1.5.0-standalone.jar
	- scenarios.xml
	- resources
	- libs
	- EN16931-CII-validation.xslt 
	- EN16931-UBL-validation.xslt


## hint @ run cmds
local run command: `java -jar validationtool-1.5.0-standalone.jar -s scenarios.xml -r ${PWD} -D -H 0.0.0.0 -P 8081`
BUT: java validator is usually running on localhost, but for deployment the service inside docker needs to run on `-H 0.0.0.0`:
docker run command: `CMD ["java", "-jar", "validationtool-1.5.0-standalone.jar", "-s", "scenarios.xml", "-r", "/app", "-D", "-H", "0.0.0.0", "-P", "8081"]`


## curl query example
- `curl --location --request POST 'http://localhost:8081' --header 'Content-Type: application/xml' --data-binary "@ubl.xml"`

## running locally from cmd
- `java -jar validationtool-1.5.0-standalone.jar -s scenarios.xml -r ${PWD} -D` -> `localhost:8080` (default)

## running locally via docker
- 
- `docker run -p 8081:8081 flx235/xr-validator-service:1.0` (port forwarding may be required)

## deployment example: onrender.com
- TBC



when docker container is running: curl --location --request POST 'http://localhost:8081' --header 'Content-Type: application/xml' --data-binary "@ubl.xml" returns the validator report XML.
important

also port forwarding: docker run -p 8081:8081 flx235/xr-validator-service:1.0
kosit
