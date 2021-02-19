echo ---- Start deploy Demo Application

echo ---- Weather APP JBoss EAP

### Create Project ###
oc new-project redhat-jboss-eap-cloud-ready-demo --display-name="Red Hat JBoss EAP Cloud Ready Demo"

### Import image related to Postgresql Database ###
oc import-image rhel8/postgresql-12 --from=registry.redhat.io/rhel8/postgresql-12 --confirm

### Create the Postgresql Database Application ###
oc new-app -e POSTGRESQL_USER=mauro -ePOSTGRESQL_PASSWORD=secret -ePOSTGRESQL_DATABASE=weather postgresql-12 --name=weather-postgresql

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

# echo ---- Weather APP EAP Cloud Ready

### Import image related to JBoss EAP 7.3 - Openjdk 11 ###
oc import-image jboss-eap-7/eap73-openjdk11-openshift-rhel8 --from=registry.redhat.io/jboss-eap-7/eap73-openjdk11-openshift-rhel8 --confirm

### Create the build related to the weather app cloud ready that will be deployed on JBoss EAP 7.3 ###
oc new-build eap73-openjdk11-openshift-rhel8 --binary=true --name=weather-app-eap-cloud-ready

### Move the project directory ###
cd ../weather-app-eap-cloud-ready

### Start the build of the application on Openshift ###
oc start-build weather-app-eap-cloud-ready --from-dir=. --wait

### Create the weather application for JBoss EAP 7.3 and configure it ###
oc new-app weather-app-eap-cloud-ready -e DB_SERVICE_PREFIX_MAPPING=weatherds-postgresql=DB \
  -e DB_JNDI=java:jboss/datasources/WeatherDS \
  -e DB_DATABASE=weather \
  -e DB_USERNAME=mauro \
  -e DB_PASSWORD=secret \
  -e DB_DRIVER=postgresql \
  -e DB_NONXA=true \
  -e DB_URL='jdbc:postgresql://$(WEATHER_POSTGRESQL_SERVICE_HOST):$(WEATHER_POSTGRESQL_SERVICE_PORT)/weather'

### Expose the route in order to make the application available outside of Openshift  ###
oc expose svc weather-app-eap-cloud-ready