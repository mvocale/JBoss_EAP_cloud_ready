echo ---- Start deploy Demo Application

echo ---- Weather APP JBoss EAP

### Create Project ###
oc new-project redhat-jboss-eap-cloud-ready-demo --display-name="Red Hat JBoss EAP Cloud Ready Demo"

### Import image related to Postgresql Database ###
oc import-image rhel8/postgresql-12 --from=registry.redhat.io/rhel8/postgresql-12 --confirm

### Create the Postgresql Database Application ###
oc new-app -e POSTGRESQL_USER=mauro -ePOSTGRESQL_PASSWORD=secret -ePOSTGRESQL_DATABASE=weather postgresql-12 --name=weather-postgresql

### Add Icon Postgresql ###
oc patch dc weather-postgresql --patch '{"metadata": { "labels": { "app.openshift.io/runtime": "postgresql" } } }'

### Import image related to JBoss EAP 7.2 - Openjdk 8 ###
oc import-image jboss-eap-7/eap72-openshift --from=registry.access.redhat.com/jboss-eap-7/eap72-openshift --confirm

### Create the build related to the weather app that will be deployed on JBoss EAP ###
oc new-build eap72-openshift --binary=true --name=weather-app-eap

### Move the project directory ###
cd weather-app-eap

### Run the Maven build ###
mvn clean package

### Start the build of the application on Openshift ###
oc start-build weather-app-eap --from-file=target/ROOT.war --wait

### Create the weather application for JBoss EAP and configure it ###
oc new-app weather-app-eap -e DB_SERVICE_PREFIX_MAPPING=weatherds-postgresql=DB \
  -e DB_JNDI=java:jboss/datasources/WeatherDS \
  -e DB_DATABASE=weather \
  -e DB_USERNAME=mauro \
  -e DB_PASSWORD=secret \
  -e DB_DRIVER=postgresql \
  -e DB_NONXA=true \
  -e DB_URL='jdbc:postgresql://$(WEATHER_POSTGRESQL_SERVICE_HOST):$(WEATHER_POSTGRESQL_SERVICE_PORT)/weather'

### Expose the route in order to make the application available outside of Openshift  ###
oc expose svc weather-app-eap

### Add Icon JBoss EAP ###
oc patch dc weather-app-eap --patch '{"metadata": { "labels": { "app.openshift.io/runtime": "eap" } } }'

echo ---- Jaeger Opentracing

### Import Jaeger image from catalog ### 
oc import-image distributed-tracing/jaeger-all-in-one-rhel8 --from=registry.redhat.io/distributed-tracing/jaeger-all-in-one-rhel8 --confirm

### Create the Jaeger application ### 
oc new-app -i jaeger-all-in-one-rhel8

### Expose the route in order to make the Jaeger application available outside of Openshift  ###
oc expose svc jaeger-all-in-one-rhel8 --port=16686

echo ---- Weather APP EAP Cloud Ready

### Import image related to JBoss EAP XP 2.0 - Openjdk 11 ###
oc import-image jboss-eap-7/eap-xp2-openjdk11-openshift-rhel8 --from=registry.redhat.io/jboss-eap-7/eap-xp2-openjdk11-openshift-rhel8 --confirm

### Import image related to JBoss EAP XP 2.0 - Openjdk 11 - Runtime ###
oc import-image jboss-eap-7/eap-xp2-openjdk11-runtime-openshift-rhel8 --from=registry.redhat.io/jboss-eap-7/eap-xp2-openjdk11-runtime-openshift-rhel8 --confirm

### Move to the project directory ###
cd ../weather-app-eap-cloud-ready

### Create the ImageStreams and the chained builds config to make the runtime image with JBoss EAP XP 2 and the application
oc create -f k8s/buildConfig.yaml

### Start the build of the application on Openshift ###
oc start-build weather-app-eap-cloud-ready-build-artifacts --from-dir=. --wait

### Check if the chained build is completed ###
while :
do
	if [[ $(oc get build weather-app-eap-cloud-ready-1 -o=jsonpath='{ .status.phase }') == 'Complete' ]]; then
  		echo "Build Completed!"
  		break;
  	else 
  		sleep 15
  		echo "Building runtime image"
  	fi
done;

### Create the weather application for JBoss EAP XP 2 and configure it ###
oc create -f k8s/weather-app-eap-cloud-ready.yaml

echo ---- Prometheus application

### Import Prometheus image from catalog ### 
oc import-image openshift4/ose-prometheus --from=registry.redhat.io/openshift4/ose-prometheus --confirm

### Create the config map with the Prometheus configurations ###
oc create configmap prometheus --from-file=k8s/prometheus.yml

### Create the Prometheus application ### 
oc create -f k8s/ose-prometheus.yaml

echo ---- Grafana application

### Import Grafana image from catalog ### 
oc import-image openshift4/ose-grafana --from=registry.redhat.io/openshift4/ose-grafana --confirm

### Create the config map with the Grafana configurations ###
oc create configmap grafana --from-file=k8s/datasource-prometheus.yaml --from-file=k8s/grafana-dashboard.yaml --from-file=k8s/jboss_eap_grafana_dashboard.json

### Create the Grafana application ###
oc create -f k8s/ose-grafana.yaml 

