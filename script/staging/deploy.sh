#!/bin/bash
function log(){
   printf "[%s] %s %s \n" "$(date +'%d/%m/%Y %H:%M:%S')" "$1" "$2"
}

# first step: cleanp tmp & staging container
log "INFO" "Staging process..."
if [ -d tmp/ ]; then
	rm -r tmp 
	if [ $? ]; then
		log "SUCCESS" "Clean up successfully"
	fi
fi

docker rm -f staging &> /dev/null

# second step :  wget  source
mkdir tmp & wget --no-check-certificate https://github.com/josselinchevalay/click-count/archive/master.tar.gz -O tmp/archive.zip &> /dev/null
if [ $? ]; then
	log "SUCCESS" "Get the new version successfully"
fi

# third step : unzip 
tar zxf tmp/archive.zip -C tmp/
if [ $? ]; then
	log "SUCCESS" "Unzip project"
fi

# forth step : use docker maven for build project
log "INFO" "Pull docker image : maven" & docker pull maven &> /dev/null 
if [ $? ]; then 
        log "SUCCESS" "Pulling sucessfully"
	docker run --rm --name my-maven-project -v "$PWD/tmp/click-count-master/":/usr/src/mymaven -w /usr/src/mymaven maven mvn clean package
	if [ $? ]; then 
		log "SUCCESS" "Build successfully"
	fi
fi

# fith step : use docker to run glassfish
log "INFO" "Pull docker image : galssefish " & docker pull glassfish &> /dev/null
if [ $? ]; then
	log "SUCCESS" "Pulling successfully"
fi
docker run -d --name staging -p "8080:8080" --add-host "redis:52.29.149.36"  -v "$PWD/tmp/click-count-master/target/clickCount.war":/war/clickCount.war glassfish
sleep 23
docker exec -it staging asadmin deploy /war/clickCount.war
if [ $? ]; then
	log "SUCCESS" "You can use staging"
fi
