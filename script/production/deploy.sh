#!/bin/bash
function log(){
   printf "[%s] %s %s \n" "$(date +'%d/%m/%Y %H:%M:%S')" "$1" "$2"
}

# first step: cleanp tmp & staging container
log "INFO" "Production process..."
if [ -d tmp/ ]; then
	rm -r tmp 
	if [ $? ]; then
		log "SUCCESS" "Clean up successfully"
	fi
fi

docker-compose rm -f production  &> /dev/null

# second step :  wget  source
mkdir tmp & wget --no-check-certificate https://github.com/josselinchevalay/click-count/releases/download/v1.0/clickCount.war -O tmp/archive.zip &> /dev/null
if [ $? ]; then
	log "SUCCESS" "Get release successfully"
fi

# fith step : use docker to run glassfish
log "INFO" "Pull docker image : galssefish " & docker pull glassfish &> /dev/null
if [ $? ]; then
	log "SUCCESS" "Pulling successfully"
fi
docker-compose up -d 
sleep 23
docker exec -it production_click-count_1 asadmin deploy /war/clickCount.war
if [ $? ]; then
	log "SUCCESS" "You can use staging"
fi
