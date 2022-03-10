echo ---- Start deploy Demo Application

echo ---- Weather APP JBoss EAP

### Create Project ###
oc new-project redhat-jboss-eap-cloud-ready-demo --display-name="Red Hat JBoss EAP Cloud Ready Demo"

echo ---- Weather APP EAP Cloud Ready

### Move to the project directory ###
cd weather-app-eap-cloud-ready

### Create the weather application for JBoss EAP XP 3 and configure it ###
mvn oc:deploy