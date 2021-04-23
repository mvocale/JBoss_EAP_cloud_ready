# Weather app cloud ready on JBoss EAP XP 2

This is a simple project based on JAX-RS, JPA and Microprofile specifications migrated from JEE 8 to Jakarta EE 8 (<https://jakarta.ee/>). The code is taken from the application weather-app GitHub Pages used in Katacoda JEE Openshift learning (<https://www.katacoda.com/openshift/courses/middleware/middleware-javaee8>) and modified to use Jakarta EE 8 specifications and Microprofile specificatons on top of JBoss EAP EAP XP 2 and Openshift 4.7. The final container image was improved using the runtime version of JBoss EAP EAP XP 2 and also through Galleon to use only the required subsystems.

## Install on Openshift

You can install your application on Openshift, remote cluster or local Red Hat Code Ready Container environment. If you use Red Hat Code Ready Container environment you need to:

1. Start the Red Hat Code Ready Container container and login as a developer

   ```sh
   crc start \
   oc login -u developer -p developer https://api.crc.testing:6443
   ```

   Otherwise, if you have an available Openshift environment, login to it (remember to update $username, $password and $URL with the proper values):

   ```sh
   oc login -u $username -p $password $URL
   ```

   or (remember to update $token and $server_url with the proper values):

   ```sh
   oc login --token=$token --server=$server_url
   ```

2. Create a new project.

   ```sh
   oc new-project redhat-jboss-eap-cloud-ready-demo --display-name="Red Hat JBoss EAP Cloud Ready Demo"
   ```

3. Create the Postgresql environment

   ```sh
   oc import-image rhel8/postgresql-12 --from=registry.redhat.io/rhel8/postgresql-12 --confirm \
   oc new-app \
      -e POSTGRESQL_USER=mauro \
      -e POSTGRESQL_PASSWORD=secret \
      -e POSTGRESQL_DATABASE=weather postgresql-12 \
      --name=weather-postgresql
   ```

4. Create the Jaeger environment used as a reference implementation of Microprofile OpenTracing specifications.

   Import Jaeger image from catalog

   ```sh
   oc import-image distributed-tracing/jaeger-all-in-one-rhel8 --from=registry.redhat.io/distributed-tracing/jaeger-all-in-one-rhel8 --confirm
   ```

   Create the Jaeger application

   ```sh
   oc new-app -i jaeger-all-in-one-rhel8
   ```

   Expose the route in order to make the Jaeger application available outside of Openshift

   ```sh
   oc expose svc jaeger-all-in-one-rhel8 --port=16686
   ```

5. Create the Waeather Application

   Import the image related to JBoss EAP XP 2.0 - Openjdk 11

   ```sh
   oc import-image jboss-eap-7/eap-xp2-openjdk11-openshift-rhel8 --from=registry.redhat.io/jboss-eap-7/eap-xp2-openjdk11-openshift-rhel8 --confirm
   ```

   Create the build related to the weather app cloud ready that will be deployed on JBoss EAP XP 2

   ```sh
   oc new-build eap-xp2-openjdk11-openshift-rhel8 --binary=true --name=weather-app-eap-cloud-ready
   ```

   Before executing the command check to be in the weather-app-eap-cloud-ready folder-project.

   Start the build of the application on Openshift

   ```sh
   oc start-build weather-app-eap-cloud-ready --from-dir=. --wait
   ```

   Create the weather application for JBoss EAP XP 2 and configure it

   ```sh
   oc create -f k8s/weather-app-eap-cloud-ready.yaml
   ```

6. Create the Prometheus environment used to collect the values provided by Microprofile Metrics specifications.

   Import the Prometheus image from catalog

   ```sh
   oc import-image openshift4/ose-prometheus --from=registry.redhat.io/openshift4/ose-prometheus --confirm
   ```

   Create the config map with the Prometheus configurations

   ```sh
   oc create configmap prometheus --from-file=k8s/prometheus.yml
   ```

   Create the Prometheus application

   ```sh
   oc create -f k8s/ose-prometheus.yaml
   ```

7. Create the Grafana environment used to collect the values provided by Microprofile Metrics specifications.

   Import Grafana image from catalog

   ```sh
   oc import-image openshift4/ose-grafana --from=registry.redhat.io/openshift4/ose-grafana --confirm
   ```

   Create the config map with the Grafana configurations

   ```sh
   oc create configmap grafana --from-file=k8s/datasource-prometheus.yaml --from-file=k8s/grafana-dashboard.yaml --from-file=k8s/jboss_eap_grafana_dashboard.json
   ```

   Create the Grafana application

   ```sh
   oc create -f k8s/ose-grafana.yaml 
   ```

## Test the application

You can test the application using the route that you can get using the following command:

```sh
oc get route weather-app-eap-cloud-ready --template='{{ .spec.host }}'
```

Copy the output of the previous command into your browser and you will be able to connect to the weather application and check the weather in the selected cities.

You can also update the expected weather connecting to postgresql and change the value of the weather

```sh
oc rsh dc/weather-postgresql \

psql -U $POSTGRESQL_USER $POSTGRESQL_DATABASE -c "update city set weathertype='rainy-5' where id='nyc'";
```

Now you can check again the weather for New York city and verify that the expected weather is rainy.

You can also test the liveness of the application, as described into the Microprofile health specifications, in this way:

1. Connect to application pod

   ```sh
   oc rsh dc/weather-app-eap-cloud-ready
   ```

2. Connect to EAP CLI

   ```sh
   cd /opt/eap/bin/ \
   ./jboss-cli.sh  --connect
   ```

3. Test the health subsystem

   ```sh
   /subsystem=microprofile-health-smallrye:check
   ```

## Test the Microprofile specificatons

### Health

The Eclipse MicroProfile Health specification defines a single container runtime mechanism for validating the availability and status of a MicroProfile implementation.
Click on the route *health* in the Openshift web console or get the value using the following command:

```sh
oc get route health --template='{{ .spec.host }}'
```

and append the path *health*.
You can also verify the status of your application using those paths after your *health* route:

- /health/live - To check if the application is up and running;
- /health/ready - To check if the application is ready to serve requests;

### Metrics

The Eclipse MicroProfile Metrics allows applications to expose different metrics from their execution which is necessary to provide monitoring of essential system parameters.
Click on the route *metric* in the Openshift web console or get the value using the following command:

```sh
oc get route metric --template='{{ .spec.host }}'
```

and append the path *metrics*.
The MicroProfile Metrics specification defines three different scopes of metrics that you can check using those paths after your metric route:

- Base scope: /metrics/base - the metrics that all MicroProfile vendors have to provide;
- Vendor scope: /metrics/vendor - vendor specific metrics;
- Application scope: /metrics/application - application specific metrics;

#### Prometheus

Prometheus is a 100% open source and community-driven project that collects metrics from targets by scraping metrics HTTP endpoints.
Click on the route *ose-prometheus* in the Openshift web console or get the value using the following command:

```sh
oc get route ose-prometheus --template='{{ .spec.host }}'
```

This will open the Prometheus web console: put the value *application_getList_total* and click on the *Execute* button.
This will show you the number of invocation of the API getList used by the application.

#### Grafana

Grafana is an opensource technology used to compose observability dashboards with everything from Prometheus.
Click on the route *ose-grafana* in the Openshift web console or get the value using the following command:

```sh
oc get route ose-grafana --template='{{ .spec.host }}'
```

This will open the Grafana web console: put the value *admin* in the username and password fields and skip the page to set the new password.
Then click on Dashboards -> Manage in the left menu: you will find a *Red Hat JBoss 7.3 Cloud Ready* preloaded dashboard that shows you four metrics:

- Application GetList method execution time;
- JBoss Cloud Ready total request;
- JVM Memory heap;
- Active DataSource connection;

### OpenTracing

Distributed tracing allows you to trace the flow of a request across service boundaries.
This is particularly important in a microservices environment where a request typically flows through multiple services.
To test this feature I used Jager.

#### Jaeger

Jaeger is an open source, end-to-end distributed tracing that helps to monitor and troubleshoot transactions in complex distributed systems.
Click on the route *jaeger-all-in-one-rhel8* in the Openshift web console or get the value using the following command:

```sh
oc get route jaeger-all-in-one-rhel8 --template='{{ .spec.host }}'
```

This will open the Jaeger web console: select the value *weather-app-eap-cloud-ready* from the Service drop down list and *GET:com.redhat.example.weather.WeatherService.getList*
from the Operation drop down list.
Then click *Find Traces* button to visualize the results of the tracing.

### OpenAPI

This MicroProfile specification, called OpenAPI, aims to provide a set of Java interfaces and programming models which allow Java developers
to natively produce OpenAPI v3 documents from their JAX-RS applications.
Click on the route *weather-app-eap-cloud-ready* in the Openshift web console or get the value using the following command:

```sh
oc get route weather-app-eap-cloud-ready --template='{{ .spec.host }}'
```

and append the path *openapi* to download the YAML file that contains the OpenAPI structure of your APIs. If you want to visualize the data
in JSON format append the path *openapi?format=JSON* to the route *weather-app-eap-cloud-ready*.

I extended the specification with a UI interface that can help you the visualize the API's data and to test it.
To test it you must append the path *api/openapi-ui* to the route *weather-app-eap-cloud-ready*: in this way you will see the swagger ui interface.

### Config

This specification defines an easy to use and flexible system for application configuration.
To test it I put a file named microprofile-config.properties into the resources/META-INF directory of my application.
You can see a property named openapi.ui.copyrightBy that contains my name and surname: you will see them in the footer component of the
swagger ui interface that you already tested in the OpenAPI section.
