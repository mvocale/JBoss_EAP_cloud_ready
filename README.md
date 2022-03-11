# JBoss_EAP_cloud_ready

Demo project where I explore how to realise cloud ready applications using, Jakarta EE, Microprofile and Openshift features

It's built on top of a simple project, weather-app-eap-cloud-ready, that is based on JAX-RS, JPA and Microprofile specifications migrated from JEE 8 to Jakarta EE 8, built using OpenJDK 11. The code is taken from the application weather-app GitHub Pages used in [Katacoda JEE Openshift learning](<https://www.katacoda.com/openshift/courses/middleware/middleware-javaee8>) and modified to use [Jakarta EE 8](<https://jakarta.ee/>) and [Microprofile 4](https://microprofile.io) specifications on top of JBoss EAP EAP XP 3, in bootable jar mode. Through the Galleon provisioning tool I set only the required subsystems, on top of Openshift 4.8. I used PostgreSQL database v. 13, and I configured the application's datasource using the [eap-datasources-galleon-pack](https://github.com/jbossas/eap-datasources-galleon-pack) feature. All the source code stages (build, resource's provisioning and deployment to Openshift) is implemented through [JKube](https://www.eclipse.org/jkube/). 
The final container image was improved using the runtime version of OpenJDK 11.

## Install on Openshift

To install the entire demo project on Openshift, remote cluster or local Red Hat Code Ready Container environment, you can launch the deploy-openshift script:

```sh
./deploy-openshift.sh
```

Remember to login to Openshift environment before launch the script.
