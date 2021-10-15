# postgresql-database-layer

This project is needed to create a custom user-developer layer that will be used to configure JBoss EAP through the Galleon framework. The project [wildfly-datasources-galleon-pack](https://github.com/jbossas/eap-datasources-galleon-pack) includes several layers to add the most common jdbc datasources (postgresql, mysql and oracle) inside the OpenShift Container Platform (OCP) but I would like to demonstrate how to customize a JBoss EAP subsystem and also show you how use a different database that is not included in the eap-datasources-galleon-pack.
