#!/bin/bash
function log(){
   printf "[%s] %s %s \n" "$(date +'%d/%m/%Y %H:%M:%S')" "$1" "$2"
}

# first step : war & container cleaning
log "INFO" "Production in progress..."
if [ -e clickCount.war ]; then
	rm -f clickCount.war
	if [ $? ]; then
		log "SUCCESS" "Clean up successfully"
	fi
fi

docker rm -f production_click-count_1  &> /dev/null

# second step :  wget  source
 wget --no-check-certificate https://github.com/josselinchevalay/click-count/releases/download/v1.0/clickCount.war &> /dev/null
if [ $? ]; then
	log "SUCCESS" "Get release successfully"
fi

# third step : use docker to run glassfish
log "INFO" "Pull docker image : galssefish " & docker pull glassfish &> /dev/null
if [ $? ]; then
	log "SUCCESS" "Pulling successfully"
fi
docker-compose up -d 
sleep 23
docker exec -it production_click-count_1 asadmin deploy /war/clickCount.war
if [ $? ]; then
	log "SUCCESS" "You can use Production"
fi
