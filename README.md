# JBoss_EAP_cloud_ready

Demo project where I explore how to realize cloud ready applications using, Jakarta EE, Microprofile and Openshift features

It contains two projects:

- A project, postgresql-database-layer, needed to create a custom user-developer layer that will be used to configure JBoss EAP through the Galleon framework. Since I used PostgreSQL database I could have decide to provisioning my project using the eap-datasources-galleon-pack [GitHub Repo](https://github.com/jbossas/eap-datasources-galleon-pack) but I would like to demonstrate how to customize a JBoss EAP subsystem and also show you how use a different database that is not included in the eap-datasources-galleon-pack.
- A simple project, weather-app-eap-cloud-ready, that is based on JAX-RS, JPA and Microprofile specifications migrated from JEE 8 to Jakarta EE 8. The code is taken from the application weather-app GitHub Pages used in [Katacoda JEE Openshift learning](<https://www.katacoda.com/openshift/courses/middleware/middleware-javaee8>) and modified to use [Jakarta EE 8](<https://jakarta.ee/>) and [Microprofile 3](https://microprofile.io) specifications on top of JBoss EAP EAP XP 3, in bootable jar mode and through Galleon to use only the required subsystems, on top of Openshift 4.8. The final container image was improved using the runtime version of OpenJDK 11.

## Install on Openshift

To install the entire demo project on Openshift, remote cluster or local Red Hat Code Ready Container environment, you can launch the deploy-openshift script:

```sh
./deploy-openshift.sh
```

Remember to login to Openshift environment before launch the script.
