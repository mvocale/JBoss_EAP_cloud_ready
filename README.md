# JBoss_EAP_cloud_ready
Demo project where I explore how to realize cloud ready applications using, Jakarta EE, Microprofile and Openshift features

It contains two projects:
- A simple project, weather-app-eap, that is based on JAX-RS, JPA and Microprofile Health specification. The code is taken from the application weather-app [GitHub Pages](https://github.com/tqvarnst/weather-app) used in Katacoda JEE Openshift learning (https://www.katacoda.com/openshift/courses/middleware/middleware-javaee8) and modified to run on top of JBoss EAP 7.2.9 and Openshift 4.6.15
- A simple project, weather-app-eap-cloud-ready, that is based on JAX-RS, JPA and Microprofile Health specification migrated from JEE 8 to Jakarta EE 8 (https://jakarta.ee/). The code is taken from the application weather-app GitHub Pages used in Katacoda JEE Openshift learning (https://www.katacoda.com/openshift/courses/middleware/middleware-javaee8) and modified to use Jakarta EE 8 specification on top of JBoss EAP 7.3.5 and Openshift 4.6.15

## Install on Openshift
To install the entire demo project on Openshift, remote cluster or local Red Hat Code Ready Container environment, you can launch the deploy-openshift script:

```sh
$ ./deploy-openshift.sh
```

Remember to login to Openshift environment before launch the script.
