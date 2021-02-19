# Weather app cloud ready on JBoss EAP 7.3
This is a simple project based on JAX-RS, JPA and Microprofile Health specification migrated from JEE 8 to Jakarta EE 8 (https://jakarta.ee/). 
The code is taken from the application weather-app GitHub Pages used in Katacoda JEE Openshift learning (https://www.katacoda.com/openshift/courses/middleware/middleware-javaee8) and modified to use Jakarta EE 8 specification and Openshift 4.6.15

## Install on Openshift
You can install your application on Openshift, remote cluster or local Red Hat Code Ready Container environment. If you use Red Hat Code Ready Container environment you need to:

1. Start the Red Hat Code Ready Container container and login as a developer

```sh
$ crc start \
$ oc login -u developer -p developer https://api.crc.testing:6443
```

Otherwise, if you have an available Openshift environment, login to it (remember to update $username, $password and $URL with the proper values):

```sh
$ oc login -u $username -p $password $URL
```

or (remember to update $token and $server_url with the proper values):

```sh
$ oc login --token=$token --server=$server_url
```

2. Create a new project 

```sh
$ oc new-project redhat-jboss-eap-cloud-ready-demo --display-name="Red Hat JBoss EAP Cloud Ready Demo"
```

3. Create the Postgresql environment

```sh
$ oc import-image rhel8/postgresql-12 --from=registry.redhat.io/rhel8/postgresql-12 --confirm \
$ oc new-app -e POSTGRESQL_USER=mauro -ePOSTGRESQL_PASSWORD=secret -ePOSTGRESQL_DATABASE=weather postgresql-12 --name=weather-postgresql
```

4. Import image related to JBoss EAP 7.3 - Openjdk 11
```sh
$ oc import-image jboss-eap-7/eap73-openjdk11-openshift-rhel8 --from=registry.redhat.io/jboss-eap-7/eap73-openjdk11-openshift-rhel8 --confirm
```

5. Create the build related to the weather app cloud ready app that will be deployed on JBoss EAP 7.3 

```sh
$ oc new-build eap73-openjdk11-openshift-rhel8 --binary=true --name=weather-app-eap-cloud-ready
```

6. Start a new build

Before executing the command check to be in the weather-app-eap-cloud-ready folder-project. 

```sh
$ oc start-build weather-app-eap-cloud-ready --from-dir=. --wait
```

7. Create the new application

```sh
$ oc new-app weather-app-eap-cloud-ready -e DB_SERVICE_PREFIX_MAPPING=weatherds-postgresql=DB \
  -e DB_JNDI=java:jboss/datasources/WeatherDS \
  -e DB_DATABASE=weather \
  -e DB_USERNAME=mauro \
  -e DB_PASSWORD=secret \
  -e DB_DRIVER=postgresql \
  -e DB_NONXA=true \
  -e DB_URL='jdbc:postgresql://$(WEATHER_POSTGRESQL_SERVICE_HOST):$(WEATHER_POSTGRESQL_SERVICE_PORT)/weather'
```

8. Expose the route in order to test the application

```sh
$ oc expose svc weather-app-eap-cloud-ready
```

### Test the application
You can test the application using the route http://weather-app-eap-cloud-ready-redhat-jboss-eap-cloud-ready-demo.apps-crc.testing. You will be able to connect to the weather application and check the weather in the selected cities.

You can also update the expected weather connecting to postgresql and change the value of the weather

```sh
$ oc rsh dc/weather-postgresql \

$ psql -U $POSTGRESQL_USER $POSTGRESQL_DATABASE -c "update city set weathertype='rainy-5' where id='nyc'";
```
Now you can check again the weather for New York city and verify that the expected weather is rainy.

You can also test the liveness of the application, as described into the Microprofile health specifications, in this way:

1. Connect to application pod

```sh
$ oc rsh dc/weather-app-eap-cloud-ready
```

2. Connect to EAP CLI

```sh
$ cd /opt/eap/bin/ \
$ ./jboss-cli.sh  --connect
```

3. Test the health subsystem

```sh
$ /subsystem=microprofile-health-smallrye:check
```
