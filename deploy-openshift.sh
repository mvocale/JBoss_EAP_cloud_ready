echo ---- Start deploy Demo Application

echo ---- Weather APP JBoss EAP

### Create Project ###
oc new-project redhat-jboss-eap-cloud-ready-demo --display-name="Red Hat JBoss EAP Cloud Ready Demo"

### Import image related to Postgresql Database ###
oc import-image rhel8/postgresql-13:1-21 --from=registry.redhat.io/rhel8/postgresql-13:1-21 --confirm

### Create the Postgresql Database Application ###
oc new-app -e POSTGRESQL_USER=mauro -ePOSTGRESQL_PASSWORD=secret -ePOSTGRESQL_DATABASE=weather postgresql-13:1-21 --name=weather-postgresql

### Add Icon Postgresql ###
oc patch dc weather-postgresql --patch '{"metadata": { "labels": { "app.openshift.io/runtime": "postgresql" } } }'

echo ---- Jaeger Opentracing

### Import Jaeger image from catalog ### 
oc import-image distributed-tracing/jaeger-all-in-one-rhel8:1.24.1-1 --from=registry.redhat.io/distributed-tracing/jaeger-all-in-one-rhel8:1.24.1-1 --confirm

### Create the Jaeger application ### 
oc new-app -i jaeger-all-in-one-rhel8:1.24.1-1

### Expose the route in order to make the Jaeger application available outside of Openshift  ###
oc expose svc jaeger-all-in-one-rhel8 --port=16686

echo ---- Weather APP EAP Cloud Ready

### Import image related to OpenJDK 11 ###
oc import-image ubi8/openjdk-11:1.10-1 --from=registry.access.redhat.com/ubi8/openjdk-11:1.10-1 --confirm

### Import image related to OpenJDK 11 - Runtime ###
oc import-image ubi8/openjdk-11-runtime:1.10-1 --from=registry.access.redhat.com/ubi8/openjdk-11-runtime:1.10-1 --confirm

### Move to the project directory ###
cd weather-app-eap-cloud-ready

### Create the ImageStreams and the chained builds config to make the runtime image with JBoss EAP XP 3 and the application
oc create -f k8s/buildConfig.yaml

### Move to the project root
cd ..

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

### Move to the project directory weather-app-eap-cloud-ready
cd weather-app-eap-cloud-ready

### Create the weather application for JBoss EAP XP 3 and configure it ###
oc create -f k8s/weather-app-eap-cloud-ready.yaml

echo ---- Prometheus application

### Import Prometheus image from catalog ### 
oc import-image openshift4/ose-prometheus:v4.8.0-202110011559.p0.git.f3beb88.assembly.stream --from=registry.redhat.io/openshift4/ose-prometheus:v4.8.0-202110011559.p0.git.f3beb88.assembly.stream --confirm

### Create the config map with the Prometheus configurations ###
oc create configmap prometheus --from-file=k8s/prometheus.yml

### Create the Prometheus application ### 
oc create -f k8s/ose-prometheus.yaml

echo ---- Grafana application

### Import Grafana image from catalog ### 
oc import-image openshift4/ose-grafana:v4.8.0-202110011559.p0.git.b987e4b.assembly.stream --from=registry.redhat.io/openshift4/ose-grafana:v4.8.0-202110011559.p0.git.b987e4b.assembly.stream --confirm

### Create the config map with the Grafana configurations ###
oc create configmap grafana --from-file=k8s/datasource-prometheus.yaml --from-file=k8s/grafana-dashboard.yaml --from-file=k8s/jboss_eap_grafana_dashboard.json

### Create the Grafana application ###
oc create -f k8s/ose-grafana.yaml