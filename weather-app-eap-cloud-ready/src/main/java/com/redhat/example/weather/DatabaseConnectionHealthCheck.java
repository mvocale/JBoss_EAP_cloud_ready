package com.redhat.example.weather;

import java.sql.DatabaseMetaData;
import java.sql.SQLException;

import javax.annotation.Resource;
import javax.enterprise.context.ApplicationScoped;
import javax.sql.DataSource;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.HealthCheckResponseBuilder;
import org.eclipse.microprofile.health.Liveness;

/**
 * Class the implements the microprofile liveness checks
 */
@Liveness
@ApplicationScoped
public class DatabaseConnectionHealthCheck implements HealthCheck {

    @Resource(lookup = "java:jboss/datasources/WeatherDS")
    private DataSource datasource;

    @Override
    public HealthCheckResponse call() {

        HealthCheckResponseBuilder responseBuilder = HealthCheckResponse.named("Database sql connection health check");
        try (var connection = datasource.getConnection()) {
            boolean isValid = connection.isValid(5);

            DatabaseMetaData metaData = connection.getMetaData();

            responseBuilder = responseBuilder
                        .withData("databaseProductName", metaData.getDatabaseProductName())
                        .withData("databaseProductVersion", metaData.getDatabaseProductVersion())
                        .withData("driverName", metaData.getDriverName())
                        .withData("driverVersion", metaData.getDriverVersion())
                        .withData("isValid", isValid);

            return responseBuilder.status(isValid).build();


        } catch(SQLException  e) {
            responseBuilder = responseBuilder
                   .withData("exceptionMessage", e.getMessage());
            return responseBuilder.down().build();
        }
    }
    
}
