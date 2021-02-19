# Weather app on JBoss EAP 7.2
This is a simple project based on JAX-RS, JPA and Microprofile Health specification. 

The code is taken from the application weather-app [GitHub Pages](https://github.com/tqvarnst/weather-app) used in Katacoda JEE Openshift learning (https://www.katacoda.com/openshift/courses/middleware/middleware-javaee8) and modified to run on top of JBoss EAP 7.2.9 and Openshift 4.6.15.

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

4. Import the JBoss EAP 7.2 Openjdk 8 image

```sh
$ oc import-image jboss-eap-7/eap72-openshift --from=registry.access.redhat.com/jboss-eap-7/eap72-openshift --confirm
```

5. Create a new build for the application

```sh
$ oc new-build eap72-openshift --binary=true --name=weather-app-eap
```

6. Run the Maven build

```sh
$ mvn clean package
```   

7. Start a new build

```sh
$ oc start-build weather-app-eap --from-file=target/ROOT.war --wait
```

8. Create the new application

```sh
$ oc new-app weather-app-eap -e DB_SERVICE_PREFIX_MAPPING=weatherds-postgresql=DB \
  -e DB_JNDI=java:jboss/datasources/WeatherDS \
  -e DB_DATABASE=weather \
  -e DB_USERNAME=mauro \
  -e DB_PASSWORD=secret \
  -e DB_DRIVER=postgresql \
  -e DB_NONXA=true \
  -e DB_URL='jdbc:postgresql://$(WEATHER_POSTGRESQL_SERVICE_HOST):$(WEATHER_POSTGRESQL_SERVICE_PORT)/weather'
```

9. Expose the route in order to test the application

```sh
$ oc expose svc weather-app-eap
```

### Test the application
You can test the application using the route http://weather-app-eap-redhat-jboss-eap-cloud-ready-demo.apps-crc.testing. You will be able to connect to the weather application and check the weather in the selected cities.

You can also update the expected weather connecting to postgresql and change the value of the weather

```sh
$ oc rsh dc/weather-postgresql \

$ psql -U $POSTGRESQL_USER $POSTGRESQL_DATABASE -c "update city set weathertype='rainy-5' where id='nyc'";
```
Now you can check again the weather for New York city and verify that the expected weather is rainy.

You can also test the liveness of the application, as described into the Microprofile health specifications, in this way:

1. Connect to application pod

```sh
$ oc rsh dc/weather-app-eap
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
