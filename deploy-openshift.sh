echo ---- Start deploy Demo Application

echo ---- Weather APP JBoss EAP

### Create Project ###
oc new-project redhat-jboss-eap-cloud-ready-demo --display-name="Red Hat JBoss EAP Cloud Ready Demo"

echo ---- Weather APP EAP Cloud Ready

### Import image related to OpenJDK 11 ###
# oc import-image ubi8/openjdk-11:1.10-1 --from=registry.access.redhat.com/ubi8/openjdk-11:1.10-1 --confirm

### Import image related to OpenJDK 11 - Runtime ###
# oc import-image ubi8/openjdk-11-runtime:1.10-1 --from=registry.access.redhat.com/ubi8/openjdk-11-runtime:1.10-1 --confirm

### Move to the project directory ###
cd weather-app-eap-cloud-ready

### Create the ImageStreams and the chained builds config to make the runtime image with JBoss EAP XP 3 and the application
# oc create -f k8s/buildConfig.yaml

### Start the build of the application on Openshift ###
# oc start-build weather-app-eap-cloud-ready-build-artifacts --from-dir=. --wait

### Check if the chained build is completed ###
#while :
#do
#	if [[ $(oc get build weather-app-eap-cloud-ready-1 -o=jsonpath='{ .status.phase }') == 'Complete' ]]; then
#  		echo "Build Completed!"
#  		break;
#  	else
#  		sleep 15
#  		echo "Building runtime image"
#  	fi
#done;

### Move to the project directory weather-app-eap-cloud-ready
# cd weather-app-eap-cloud-ready

### Create the weather application for JBoss EAP XP 3 and configure it ###
# oc create -f k8s/weather-app-eap-cloud-ready.yaml

### Create the weather application for JBoss EAP XP 3 and configure it ###
mvn oc:deploy